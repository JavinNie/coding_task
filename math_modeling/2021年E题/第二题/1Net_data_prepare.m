%% 模型需要的数据准备

clear

Bsnum=4;
Bsloc=[0 0 1300;5000 0 1700;0 5000 1700;5000 5000 1300];
field=[5000,5000,3000];

para.Thr = 10;
para.DataLen=1;
para.BsNum=Bsnum;
para.BsLoc=Bsloc;
para.MaxIters=30;
para.xinit = mean(Bsloc,1);
para.dRef=2500;%中间，5000边长
para.field=field;

locreal=locrealread('Tag坐标信息.txt')*10;%%%后面可以不用乘了
locnum=size(locreal,1);

%% 数据读取，得到四个距离的观察值和实际值

tic
%% 异常数据读取
filedir='异常数据';
Distance_obs_negtive=[];
Distance_GT_negtive=[];
Loc_Real_negtive=[];
for ii=1:locnum%324
    filename2=[num2str(ii) '.异常.txt'];    
    [outres0,t]=fileread1(fullfile(filedir,filename2),Bsnum,1,[]);
    Distance_obs_negtive=[Distance_obs_negtive;outres0];%%观测四距离，N*4
    Distance_GT_temp= UWBToaObs(Bsloc,Bsnum,locreal(ii,:));%实际四距离        
    Distance_GT_negtive=[Distance_GT_negtive; repmat(Distance_GT_temp,[size(outres0,1),1])];%和观测距离数目相等，每个文件相同
    Loc_Real_negtive=[Loc_Real_negtive;repmat(locreal(ii,:),[size(outres0,1),1])];
end
toc
DATA_negtive.OBSdata=Distance_obs_negtive;%观测距离
DATA_negtive.GTdata=Distance_GT_negtive;%真实距离
DATA_negtive.PNtag=zeros(size(Distance_GT_negtive,1),1);%0代表有异常，标签
DATA_negtive.Loc_Real=Loc_Real_negtive;%真实坐标

tic
%% 正常数据读取
filedir='正常数据';
Distance_obs_positive=[];
Distance_GT_positive=[];
Loc_Real_positive=[];
for ii=1:locnum%324
    filename2=[num2str(ii) '.正常.txt'];    
    [outres0,t]=fileread1(fullfile(filedir,filename2),Bsnum,1,[]);
    Distance_obs_positive=[Distance_obs_positive;outres0];%%观测四距离，N*4
    Distance_GT_temp= UWBToaObs(Bsloc,Bsnum,locreal(ii,:));%实际四距离        
    Distance_GT_positive=[Distance_GT_positive; repmat(Distance_GT_temp,[size(outres0,1),1])];%和观测距离数目相等，每个文件相同
    Loc_Real_positive=[Loc_Real_positive;repmat(locreal(ii,:),[size(outres0,1),1])];
end
toc
DATA_positive.OBSdata=Distance_obs_positive;%观测距离
DATA_positive.GTdata=Distance_GT_positive;%真实距离
DATA_positive.PNtag=ones(size(Distance_GT_positive,1),1);%1代表有正常
DATA_positive.Loc_Real=Loc_Real_positive;%真实坐标

%% 粗略估计靶心坐标
tic
load('fitfunz.mat')%拟合函数加载
%% 正常靶心估计
parfor ii=1:size(DATA_positive.OBSdata,1)%324
    Dis_obs=fitresult(DATA_positive.OBSdata(ii,:));
    [Loc_Est(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%输入靶点的坐标和观测到的四个距离，迭代出误差最小的估计坐标(不断更新估计坐标，计算和锚点的四个距离，然后牛顿法收敛)
     Err_curve(ii,:)=Err_count(end,:);
end
DATA_positive.Loc_Est=Loc_Est;%正常坐标估计
DATA_positive.min_Err=Err_curve;
clear Loc_Est

%% 异常靶心估计
parfor ii=1:size(DATA_negtive.OBSdata,1)%324
    Dis_obs=fitresult(DATA_negtive.OBSdata(ii,:));%没有fit的数据
    [Loc_Est(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%输入靶点的坐标和观测到的四个距离，迭代出误差最小的估计坐标(不断更新估计坐标，计算和锚点的四个距离，然后牛顿法收敛)
     Err_curve(ii,:)=Err_count(end,:);
end
DATA_negtive.Loc_Est=Loc_Est;%异常坐标估计
DATA_negtive.min_Err=Err_curve;
toc

%% 归一化
DATA_positive=normalization(DATA_positive,para);
DATA_negtive=normalization(DATA_negtive,para);

save('NET_DATA.mat','DATA_positive','DATA_negtive','para');%用于做异常判断足够了
