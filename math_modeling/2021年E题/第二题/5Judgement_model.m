%% Judgement �쳣���ģ��
%% ���ڼ���Ƿ��쳣
clear
load('NET_DATA.mat');
% plot(DATA)
%% �������������
%% �������롢���
P=[[DATA_negtive.OBSdata]; [DATA_positive.OBSdata]]';%�ĸ����Ծ���
T=[DATA_negtive.PNtag; DATA_positive.PNtag]';%��ǩ,��࣬����1���Ҳ��쳣1
RatioTT=0.85;%ѵ������ռ��
samplenum=size(P,2);%������
%% ����\ѵ��������
ind_train=randperm(samplenum,ceil(samplenum*RatioTT));
P_train=P(:,ind_train);%���룬ѵ��
T_train=T(:,ind_train);%�����ѵ��
P_test=P;
T_test=T;
P_test(:,ind_train)=[];%���룬����
T_test(:,ind_train)=[];%���������
%% �����쳣���ģ��
net = newff( P_train,T_train ,  [20,5],{'logsig','logsig'} ) ;
%�趨ģ�Ͳ���
net.trainParam.show = 10;
net.trainParam.epochs = 200;
net.trainParam.goal = 1e-10;
net.trainParam.lr = 0.1;

%% ģ��ѵ��
net = train(net,P_train,T_train);
judge_net=net;
save('Judge_net.mat','judge_net');
%% ģ�Ͳ���
T_sim = sim(net,P_test);
%% ���Խ��
figure
plot(  T_ref, '-or' )
hold on
plot( tag , '-*b');
legend('��ʵֵ','Ԥ��ֵ')
R2 = corrcoef(T_ref,tag);
R2 = R2(1,2)^ 2;
xlabel('Ԥ������')
ylabel('strength')
string = {'Ԥ�����Ա�';['R^2=' num2str(R2)]};
title(string)
hold off
%% �����������
plotconfusion(T_test,T_sim)
set(gca,'FontSize',20,'Fontname', 'Times New Roman');