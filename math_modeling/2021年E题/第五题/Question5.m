%% 动态轨迹
clear
%% 数据输入，标准格式，归一化，带着场景信息,
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

[OBSdata,t]=fileread1_modi('附件5：动态轨迹数据.txt',Bsnum,1,[]);
DATA.OBSdata=OBSdata;
load fitfunz
%% 靶心直接估计
Distance_obs=DATA.OBSdata;
for ii=1:size(Distance_obs,1)
     Dis_obs=fitresult(Distance_obs(ii,:));
    [LocEst(ii,:), Err_count]= UWBLocIters1(Dis_obs',para);%输入靶点的坐标和观测到的四个距离，迭代出误差最小的估计坐标(不断更新估计坐标，计算和锚点的四个距离，然后牛顿法收敛)
end
DATA.Loc_Est=LocEst;
%% 归一化数据
DATA.Loc_Est=DATA.Loc_Est./para.field;
DATA.OBSdata=DATA.OBSdata/norm(para.field);

%% 异常点判断
load('Judge_net.mat')
P_judge=DATA.OBSdata';
T_sim=sim(judge_net,P_judge);
tag=zeros(size(T_sim));
%阈值分隔标签
indP=find(T_sim>0.5);%
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
Loc_Est_final(indN,:)=Loc_Est0;%% 神经网络补偿之后的估计值
%% kalman滤波
%% 计算四个值
Distance=[];
for ii=1:size(Loc_Est_final,1)
    Distance_temp= UWBToaObs(Bsloc,Bsnum,Loc_Est_final(ii,:));%实际四距离        
    Distance=[Distance; Distance_temp];%和观测距离数目相等，每个文件相同
end
%% 时间连续，等时间间隔插值
T2=t-t(1);
dt=T2(end)/500;
tseq=0:dt:T2(end);
for ii=1:Bsnum
     OBS_inter(:,ii)=interp1(T2, Distance(:,ii) ,tseq,'linear');
end
%% 卡尔曼滤波器
Loc_Est_KF =KF(Loc_Est_final,para)';
%% 绘制轨迹图
figure;
hold on;
plot3(LocEst(:,1),LocEst(:,2),LocEst(:,3),'.-','LineWidth',2);
plot3(Loc_Est_final(:,1),Loc_Est_final(:,2),Loc_Est_final(:,3),'.-','LineWidth',2);
plot3(Loc_Est_KF(:,1),Loc_Est_KF(:,2),Loc_Est_KF(:,3),'.-','LineWidth',2);
plot3(Bsloc(:,1),Bsloc(:,2),Bsloc(:,3),'b^','LineWidth',5);
legend('直接估计','直接估计+网络补偿','直接估计+网络补偿+E-kalman滤波','锚点位置');
title('运行轨迹预测')
axis([0 5e3 0 5e3 0 3e3]);