%% Judgement 异常检测模型
%% 用于检测是否异常
clear
load('NET_DATA.mat');
% plot(DATA)
%% 输入输出集构建
%% 构建输入、输出
P=[[DATA_negtive.OBSdata]; [DATA_positive.OBSdata]]';%四个测试距离
T=[DATA_negtive.PNtag; DATA_positive.PNtag]';%标签,左侧，正常1，右侧异常1
RatioTT=0.85;%训练数据占比
samplenum=size(P,2);%样本数
%% 测试\训练集划分
ind_train=randperm(samplenum,ceil(samplenum*RatioTT));
P_train=P(:,ind_train);%输入，训练
T_train=T(:,ind_train);%输出，训练
P_test=P;
T_test=T;
P_test(:,ind_train)=[];%输入，测试
T_test(:,ind_train)=[];%输出，测试
%% 构建异常检测模型
net = newff( P_train,T_train ,  [20,5],{'logsig','logsig'} ) ;
%设定模型参数
net.trainParam.show = 10;
net.trainParam.epochs = 200;
net.trainParam.goal = 1e-10;
net.trainParam.lr = 0.1;

%% 模型训练
net = train(net,P_train,T_train);
judge_net=net;
save('Judge_net.mat','judge_net');
%% 模型测试
T_sim = sim(net,P_test);
%% 测试结果
figure
plot(  T_ref, '-or' )
hold on
plot( tag , '-*b');
legend('真实值','预测值')
R2 = corrcoef(T_ref,tag);
R2 = R2(1,2)^ 2;
xlabel('预测样本')
ylabel('strength')
string = {'预测结果对比';['R^2=' num2str(R2)]};
title(string)
hold off
%% 混淆矩阵绘制
plotconfusion(T_test,T_sim)
set(gca,'FontSize',20,'Fontname', 'Times New Roman');