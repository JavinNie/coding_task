%�쳣���ݲ�������
%% 
clear
load('NET_DATA.mat');
% plot(DATA)
%% �������������룬���
P=[DATA_negtive.Loc_Est ,DATA_negtive.OBSdata]';%���ưе������꣬ʵ���ľ��룬N*7
T=[DATA_negtive.Loc_Real]';%��������
RatioTT=0.85;%ѵ������ռ��
samplenum=size(P,2);%������
%% ����\ѵ��������
ind_train=randperm(samplenum,ceil(samplenum*RatioTT));
P_train=P(:,ind_train);%���룬ѵ��
T_train=T(:,ind_train);%�����ѵ��

ind_test=setdiff([1:samplenum],ind_train);  
P_test=P(:,ind_test);%���룬����
T_test=T(:,ind_test);%���������

%% ����BP����
%�趨�����������
net = newff(P_train,T_train,20);   %������Ϊ20����Ԫ
net.trainParam.epochs = 20;
net.trainParam.goal = 1e-7;
net.trainParam.lr = 0.1;

%% ����ѵ��
net = train(net,P_train,T_train);
negtive_net=net;
% save('negtive_net.mat','negtive_net');
%% �������
T_sim = sim(net,P_test);
% T_sim = sim(net,P_train);

%% �������ͼ
figure
for ii=1:4
    subplot(4,1,ii)
    plot(  T_test(ii,:), '-or' )
    hold on
    plot( T_sim(ii,:) , '-*b');
    legend('��ʵֵ','Ԥ��ֵ')
    R2 = corrcoef(T_sim(ii,:),T_test(ii,:));
    R2 = R2(1,2)^ 2;
    xlabel('Ԥ������')
    ylabel('strength')
    string = {'BP����Ԥ�����Ա�';['R^2=' num2str(R2)]};
    title(string)
end

%% ����ֱ������е������ƽ�����
LocEst=T_sim'.*para.field;
Loc_real_test=T_test'.*para.field;
load('fitfunz.mat')%��Ϻ�������
for ii=1:size(Distance_obs,1)%324
    [err1(ii,:),err2(ii),err3(ii)]=errcal(LocEst(ii,:),Loc_real_test(ii,:));%����һά����ά����ά�����������ʵ������
end
Err1=mean(err1,1)
Err2=mean(err2)
Err3=mean(err3)

%% ���㲹��֮���ƽ�����
Distance_obs=T_sim'*norm(para.field);
Loc_real_test=T_test'.*para.field;
load('fitfunz.mat')%��Ϻ�������
for ii=1:size(Distance_obs,1)%324
     Dis_obs=fitresult(Distance_obs(ii,:));
    Dis_obs=Distance_obs(ii,:);
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%����е������͹۲⵽���ĸ����룬�����������С�Ĺ�������(���ϸ��¹������꣬�����ê����ĸ����룬Ȼ��ţ�ٷ�����)
    Err_curve(ii,:)=Err_count(end,:);
    [err1(ii,:),err2(ii),err3(ii)]=errcal(LocEst(ii,:),Loc_real_test(ii,:));%����һά����ά����ά�����������ʵ������
end
Err1=mean(err1,1)
Err2=mean(err2)
Err3=mean(err3)

%% ����ԭ����ƽ�����
Distance_obs=DATA_negtive.OBSdata*norm(para.field);
Loc_real_test=DATA_negtive.Loc_Real.*para.field;
load('fitfunz.mat')%��Ϻ�������
for ii=1:size(Distance_obs,1)%324
     Dis_obs=fitresult(Distance_obs(ii,:));
%     Dis_obs=Distance_obs(ii,:);
    [LocEst(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%����е������͹۲⵽���ĸ����룬�����������С�Ĺ�������(���ϸ��¹������꣬�����ê����ĸ����룬Ȼ��ţ�ٷ�����)
    Err_curve(ii,:)=Err_count(end,:);
    [err1(ii,:),err2(ii),err3(ii)]=errcal(LocEst(ii,:),Loc_real_test(ii,:));%����һά����ά����ά�����������ʵ������
end
Err1=mean(err1,1)
Err2=mean(err2)
Err3=mean(err3)

  