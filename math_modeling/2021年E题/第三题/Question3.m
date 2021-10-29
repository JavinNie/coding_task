clear
%% �������룬��׼��ʽ����һ�������ų�����Ϣ
Bsnum=4;
Bsloc=[0 0 1200;
    5000 0 1600;
    0 3000 1600;
    5000 3000 1200];
para.Thr = 100;
para.DataLen=1;
para.BsNum=Bsnum;
para.BsLoc=Bsloc;
para.MaxIters=100;
para.xinit = mean(Bsloc,1);
para.dRef=2500;

DATA.OBSdata=[4220  2580 3730 1450;
    4500 1940 4420 1460;
    3550 2510 3410 2140;
    3300 3130 2900 2790;
    720 4520 3050 5380;
    5100 2220 4970 800;
    2900 3210 3140 2890;
    2380 3530 2320 3760;
    2150 3220 3140 3640;
    1620 3950 2580 4440];%ǰ����޸��ţ�������и���
para.field=[5000,3000,3000];%%%��������Χ����һ������
DATA.PNtag=[ones(1,5),zeros(1,5)];
load fitfunz
%% ����ֱ�ӹ���
Distance_obs=DATA.OBSdata;
for ii=1:size(Distance_obs,1)
     Dis_obs=fitresult(Distance_obs(ii,:));
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%����е������͹۲⵽���ĸ����룬�����������С�Ĺ�������(���ϸ��¹������꣬�����ê����ĸ����룬Ȼ��ţ�ٷ�����)
end
DATA.Loc_Est=LocEst;
%% ��һ������
DATA.Loc_Est=DATA.Loc_Est./para.field;
DATA.OBSdata=DATA.OBSdata/norm(para.field);
%% �����쳣���ݻ���
indN=[1:10];
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
Loc_Est_final(indN,:)=Loc_Est0;
%% �ش������ļ������
Distance_obs=DATA.OBSdata*norm(para.field);
for ii=1:5%324
    Distance_Obs=Distance_obs(ii,:);%%�۲��ľ��룬N*4
    Distance_Est= UWBToaObs(para.BsLoc,para.BsNum,Loc_Est_final(ii,:));%�����ľ���
    Err_dis(ii,:)=abs(Distance_Obs-Distance_Est);
end
mean(Err_dis(:))
max(Err_dis(:))
min(Err_dis(:))