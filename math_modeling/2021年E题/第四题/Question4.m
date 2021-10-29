%% 自行判断有无干扰，调用训练好的判断模型

clear
%% 数据输入，标准格式，归一化，带着场景信息
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
%% 靶心直接估计
Distance_obs=DATA.OBSdata;
for ii=1:size(Distance_obs,1)
     Dis_obs=fitresult(Distance_obs(ii,:));
%     Dis_obs=Distance_obs(ii,:);
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%输入靶点的坐标和观测到的四个距离，迭代出误差最小的估计坐标(不断更新估计坐标，计算和锚点的四个距离，然后牛顿法收敛)
end
DATA.Loc_Est=LocEst;
%% 归一化数据
DATA.Loc_Est=DATA.Loc_Est./para.field;
DATA.OBSdata=DATA.OBSdata/norm(para.field);
%% 二三问网络判断，已知异常正常，可以用于验证网络
load('Judge_net.mat')
P_judge=DATA.OBSdata';
T_sim=sim(judge_net,P_judge);
tag=zeros(size(T_sim));
%阈值二分标签
indP=find(T_sim>0.5);%索引
indN=find(T_sim<=0.5);
tag(indP)=1;
tag(indN)=0;
DATA.PNtag=tag%更新tag，p为1，n为0