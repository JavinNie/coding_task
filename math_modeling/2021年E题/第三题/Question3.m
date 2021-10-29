clear
%% 数据输入，标准格式，归一化，带着场景信息
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
    1620 3950 2580 4440];%前五个无干扰，后五个有干扰
para.field=[5000,3000,3000];%%%换场景范围，归一化依据
DATA.PNtag=[ones(1,5),zeros(1,5)];
load fitfunz
%% 靶心直接估计
Distance_obs=DATA.OBSdata;
for ii=1:size(Distance_obs,1)
     Dis_obs=fitresult(Distance_obs(ii,:));
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%输入靶点的坐标和观测到的四个距离，迭代出误差最小的估计坐标(不断更新估计坐标，计算和锚点的四个距离，然后牛顿法收敛)
end
DATA.Loc_Est=LocEst;
%% 归一化数据
DATA.Loc_Est=DATA.Loc_Est./para.field;
DATA.OBSdata=DATA.OBSdata/norm(para.field);
%% 正常异常数据划分
indN=[1:10];
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
Loc_Est_final(indN,:)=Loc_Est0;
%% 回代正常的计算误差
Distance_obs=DATA.OBSdata*norm(para.field);
for ii=1:5%324
    Distance_Obs=Distance_obs(ii,:);%%观测四距离，N*4
    Distance_Est= UWBToaObs(para.BsLoc,para.BsNum,Loc_Est_final(ii,:));%估计四距离
    Err_dis(ii,:)=abs(Distance_Obs-Distance_Est);
end
mean(Err_dis(:))
max(Err_dis(:))
min(Err_dis(:))