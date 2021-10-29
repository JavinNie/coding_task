%% 第二问解答，计算十个坐标
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

DATA.OBSdata=[1320 3950 4540 5760;
    3580 2580 4610 3730;
    2930 2600 4740 4420;
    2740 2720 4670 4790;
    2980 4310 2820 4320;
    2230 3230 4910 5180;
    4520 1990 5600 3360;
    2480 3530 4180 5070;
    4220 2510 4670 3490;
    5150 2120 5800 2770;];%前五个无干扰，后五个有干扰
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
%% 异常判断，由于已知异常正常，这里可以验证异常判断模型准确率，准确率100%
load('Judge_net.mat')
P_judge=DATA.OBSdata';

T_sim=sim(judge_net,P_judge);
tag=zeros(size(T_sim));

indP=find(T_sim>0.5);%索引有用
indN=find(T_sim<=0.5);
tag(indP)=1;
tag(indN)=0;

DATA.PNtag=tag;%更新tag，p为1，n为0
%% 正常数据网络补偿，输出靶心
load('positive_net.mat')
P_positive=[DATA.Loc_Est(indP,:), DATA.OBSdata(indP,:)]';    
T_sim=sim(positive_net,P_positive);
Loc_Est1=T_sim'.*para.field;
%% 异常数据网络补偿，输出靶心
load('negtive_net.mat')
P_negtive=[DATA.Loc_Est(indN,:), DATA.OBSdata(indN,:)]';
T_sim=sim(negtive_net,P_negtive);
Loc_Est0=T_sim'.*para.field;
%% 组合正负样本数据，恢复顺序
Loc_Est_final=zeros(size(DATA.Loc_Est));
Loc_Est_final(indP,:)=Loc_Est1;
Loc_Est_final(indN,:)=Loc_Est0;
%% 回代验证，计算正常部分的距离误差
Distance_obs=DATA.OBSdata*norm(para.field);
for ii=1:5%324
    Distance_Obs=Distance_obs(ii,:);%%观测四距离，N*4
    Distance_Est= UWBToaObs(para.BsLoc,para.BsNum,Loc_Est_final(ii,:));%估计四距离
    Err_dis(ii,:)=abs(Distance_Obs-Distance_Est);
end
mean(Err_dis(:))
max(Err_dis(:))
min(Err_dis(:))