%% ��̬�켣
clear
%% �������룬��׼��ʽ����һ�������ų�����Ϣ,
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

[OBSdata,t]=fileread1_modi('����5����̬�켣����.txt',Bsnum,1,[]);
DATA.OBSdata=OBSdata;
load fitfunz
%% ����ֱ�ӹ���
Distance_obs=DATA.OBSdata;
for ii=1:size(Distance_obs,1)
     Dis_obs=fitresult(Distance_obs(ii,:));
    [LocEst(ii,:), Err_count]= UWBLocIters1(Dis_obs',para);%����е������͹۲⵽���ĸ����룬�����������С�Ĺ�������(���ϸ��¹������꣬�����ê����ĸ����룬Ȼ��ţ�ٷ�����)
end
DATA.Loc_Est=LocEst;
%% ��һ������
DATA.Loc_Est=DATA.Loc_Est./para.field;
DATA.OBSdata=DATA.OBSdata/norm(para.field);

%% �쳣���ж�
load('Judge_net.mat')
P_judge=DATA.OBSdata';
T_sim=sim(judge_net,P_judge);
tag=zeros(size(T_sim));
%��ֵ�ָ���ǩ
indP=find(T_sim>0.5);%
indN=find(T_sim<=0.5);
tag(indP)=1;
tag(indN)=0;
DATA.PNtag=tag;%����tag��pΪ1��nΪ0
%% �����������粹�����������
load('positive_net.mat')
P_positive=[DATA.Loc_Est(indP,:), DATA.OBSdata(indP,:)]';
T_sim=sim(positive_net,P_positive);
Loc_Est1=T_sim'.*para.field;
%% �쳣�������粹�����������
load('negtive_net.mat')
P_negtive=[DATA.Loc_Est(indN,:), DATA.OBSdata(indN,:)]';
T_sim=sim(negtive_net,P_negtive);
Loc_Est0=T_sim'.*para.field;
%% ��������������ݣ��ָ�˳��
Loc_Est_final=zeros(size(DATA.Loc_Est));
Loc_Est_final(indP,:)=Loc_Est1;
Loc_Est_final(indN,:)=Loc_Est0;%% �����粹��֮��Ĺ���ֵ
%% kalman�˲�
%% �����ĸ�ֵ
Distance=[];
for ii=1:size(Loc_Est_final,1)
    Distance_temp= UWBToaObs(Bsloc,Bsnum,Loc_Est_final(ii,:));%ʵ���ľ���        
    Distance=[Distance; Distance_temp];%�͹۲������Ŀ��ȣ�ÿ���ļ���ͬ
end
%% ʱ����������ʱ������ֵ
T2=t-t(1);
dt=T2(end)/500;
tseq=0:dt:T2(end);
for ii=1:Bsnum
     OBS_inter(:,ii)=interp1(T2, Distance(:,ii) ,tseq,'linear');
end
%% �������˲���
Loc_Est_KF =KF(Loc_Est_final,para)';
%% ���ƹ켣ͼ
figure;
hold on;
plot3(LocEst(:,1),LocEst(:,2),LocEst(:,3),'.-','LineWidth',2);
plot3(Loc_Est_final(:,1),Loc_Est_final(:,2),Loc_Est_final(:,3),'.-','LineWidth',2);
plot3(Loc_Est_KF(:,1),Loc_Est_KF(:,2),Loc_Est_KF(:,3),'.-','LineWidth',2);
plot3(Bsloc(:,1),Bsloc(:,2),Bsloc(:,3),'b^','LineWidth',5);
legend('ֱ�ӹ���','ֱ�ӹ���+���粹��','ֱ�ӹ���+���粹��+E-kalman�˲�','ê��λ��');
title('���й켣Ԥ��')
axis([0 5e3 0 5e3 0 3e3]);