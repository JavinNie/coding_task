%% �ڶ��ʽ�𣬼���ʮ������
clear
%% �������룬��׼��ʽ����һ�������ų�����Ϣ
Bsnum=4;
Bsloc=[0 0 1300;5000 0 1700;0 5000 1700;5000 5000 1300];
para.Thr = 100;
para.DataLen=1;
para.BsNum=Bsnum;
para.BsLoc=Bsloc;
para.MaxIters=100;
para.xinit = mean(Bsloc,1);
para.dRef=2500;
para.field=[5000,5000,3000];

DATA.OBSdata=[1320 3950 4540 5760;
    3580 2580 4610 3730;
    2930 2600 4740 4420;
    2740 2720 4670 4790;
    2980 4310 2820 4320;
    2230 3230 4910 5180;
    4520 1990 5600 3360;
    2480 3530 4180 5070;
    4220 2510 4670 3490;
    5150 2120 5800 2770;];%ǰ����޸��ţ�������и���
DATA.PNtag=[ones(1,5),zeros(1,5)];
load fitfunz
%% ����ֱ�ӹ���
Distance_obs=DATA.OBSdata;
for ii=1:size(Distance_obs,1)
     Dis_obs=fitresult(Distance_obs(ii,:));
%     Dis_obs=Distance_obs(ii,:);
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%����е������͹۲⵽���ĸ����룬�����������С�Ĺ�������(���ϸ��¹������꣬�����ê����ĸ����룬Ȼ��ţ�ٷ�����)
end
DATA.Loc_Est=LocEst;
%% ��һ������
DATA.Loc_Est=DATA.Loc_Est./para.field;
DATA.OBSdata=DATA.OBSdata/norm(para.field);
%% �쳣�жϣ�������֪�쳣���������������֤�쳣�ж�ģ��׼ȷ�ʣ�׼ȷ��100%
load('Judge_net.mat')
P_judge=DATA.OBSdata';

T_sim=sim(judge_net,P_judge);
tag=zeros(size(T_sim));

indP=find(T_sim>0.5);%��������
indN=find(T_sim<=0.5);
tag(indP)=1;
tag(indN)=0;

DATA.PNtag=tag;%����tag��pΪ1��nΪ0
%% �����������粹�����������
load('positive_net.mat')
P_positive=[DATA.Loc_Est(indP,:), DATA.OBSdata(indP,:)]';    
T_sim=sim(positive_net,P_positive);
Loc_Est1=T_sim'.*para.field;
%% �쳣�������粹�����������
load('negtive_net.mat')
P_negtive=[DATA.Loc_Est(indN,:), DATA.OBSdata(indN,:)]';
T_sim=sim(negtive_net,P_negtive);
Loc_Est0=T_sim'.*para.field;
%% ��������������ݣ��ָ�˳��
Loc_Est_final=zeros(size(DATA.Loc_Est));
Loc_Est_final(indP,:)=Loc_Est1;
Loc_Est_final(indN,:)=Loc_Est0;
%% �ش���֤�������������ֵľ������
Distance_obs=DATA.OBSdata*norm(para.field);
for ii=1:5%324
    Distance_Obs=Distance_obs(ii,:);%%�۲��ľ��룬N*4
    Distance_Est= UWBToaObs(para.BsLoc,para.BsNum,Loc_Est_final(ii,:));%�����ľ���
    Err_dis(ii,:)=abs(Distance_Obs-Distance_Est);
end
mean(Err_dis(:))
max(Err_dis(:))
min(Err_dis(:))