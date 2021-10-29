%异常数据补偿网络
%% 
clear
load('NET_DATA.mat');
% plot(DATA)
%% 构建，划分输入，输出
P=[DATA_negtive.Loc_Est ,DATA_negtive.OBSdata]';%估计靶点三坐标，实测四距离，N*7
T=[DATA_negtive.Loc_Real]';%误差估计量
RatioTT=0.85;%训练数据占比
samplenum=size(P,2);%样本数
%% 测试\训练集划分
ind_train=randperm(samplenum,ceil(samplenum*RatioTT));
P_train=P(:,ind_train);%输入，训练
T_train=T(:,ind_train);%输出，训练

ind_test=setdiff([1:samplenum],ind_train);  
P_test=P(:,ind_test);%输入，测试
T_test=T(:,ind_test);%输出，测试

%% 构建BP网络
%设定参数网络参数
net = newff(P_train,T_train,20);   %隐含层为20个神经元
net.trainParam.epochs = 20;
net.trainParam.goal = 1e-7;
net.trainParam.lr = 0.1;

%% 网络训练
net = train(net,P_train,T_train);
negtive_net=net;
% save('negtive_net.mat','negtive_net');
%% 网络测试
T_sim = sim(net,P_test);
% T_sim = sim(net,P_train);

%% 画出误差图
figure
for ii=1:4
    subplot(4,1,ii)
    plot(  T_test(ii,:), '-or' )
    hold on
    plot( T_sim(ii,:) , '-*b');
    legend('真实值','预测值')
    R2 = corrcoef(T_sim(ii,:),T_test(ii,:));
    R2 = R2(1,2)^ 2;
    xlabel('预测样本')
    ylabel('strength')
    string = {'BP网络预测结果对比';['R^2=' num2str(R2)]};
    title(string)
end

%% 计算直接输出靶点坐标的平均误差
LocEst=T_sim'.*para.field;
Loc_real_test=T_test'.*para.field;
load('fitfunz.mat')%拟合函数加载
for ii=1:size(Distance_obs,1)%324
    [err1(ii,:),err2(ii),err3(ii)]=errcal(LocEst(ii,:),Loc_real_test(ii,:));%计算一维、二维和三维误差，估计坐标和实际坐标
end
Err1=mean(err1,1)
Err2=mean(err2)
Err3=mean(err3)

%% 计算补偿之后的平均误差
Distance_obs=T_sim'*norm(para.field);
Loc_real_test=T_test'.*para.field;
load('fitfunz.mat')%拟合函数加载
for ii=1:size(Distance_obs,1)%324
     Dis_obs=fitresult(Distance_obs(ii,:));
    Dis_obs=Distance_obs(ii,:);
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%输入靶点的坐标和观测到的四个距离，迭代出误差最小的估计坐标(不断更新估计坐标，计算和锚点的四个距离，然后牛顿法收敛)
    Err_curve(ii,:)=Err_count(end,:);
    [err1(ii,:),err2(ii),err3(ii)]=errcal(LocEst(ii,:),Loc_real_test(ii,:));%计算一维、二维和三维误差，估计坐标和实际坐标
end
Err1=mean(err1,1)
Err2=mean(err2)
Err3=mean(err3)

%% 计算原本的平均误差
Distance_obs=DATA_negtive.OBSdata*norm(para.field);
Loc_real_test=DATA_negtive.Loc_Real.*para.field;
load('fitfunz.mat')%拟合函数加载
for ii=1:size(Distance_obs,1)%324
     Dis_obs=fitresult(Distance_obs(ii,:));
%     Dis_obs=Distance_obs(ii,:);
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%输入靶点的坐标和观测到的四个距离，迭代出误差最小的估计坐标(不断更新估计坐标，计算和锚点的四个距离，然后牛顿法收敛)
    Err_curve(ii,:)=Err_count(end,:);
    [err1(ii,:),err2(ii),err3(ii)]=errcal(LocEst(ii,:),Loc_real_test(ii,:));%计算一维、二维和三维误差，估计坐标和实际坐标
end
Err1=mean(err1,1)
Err2=mean(err2)
Err3=mean(err3)

  