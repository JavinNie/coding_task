%% �����ж����޸��ţ�����ѵ���õ��ж�ģ��

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

DATA.OBSdata=[2940 4290 2840 4190;
    5240 5360 2040 2940;
    4800 2610 4750 2550;
    5010 4120 3810 2020;
    2840 4490 2860 4190;
    5010 5320 1990 2930;
    5050 3740 3710 2070;
    5050 4110 3710 2110;
    4840 2600 4960 2700;
    2740 2720 4670 4790];
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
%% �����������жϣ���֪�쳣����������������֤����
load('Judge_net.mat')
P_judge=DATA.OBSdata';
T_sim=sim(judge_net,P_judge);
tag=zeros(size(T_sim));
%��ֵ���ֱ�ǩ
indP=find(T_sim>0.5);%����
indN=find(T_sim<=0.5);
tag(indP)=1;
tag(indN)=0;
DATA.PNtag=tag%����tag��pΪ1��nΪ0