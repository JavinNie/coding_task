%% ģ����Ҫ������׼��

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
para.dRef=2500;%�м䣬5000�߳�
para.field=field;

locreal=locrealread('Tag������Ϣ.txt')*10;%%%������Բ��ó���
locnum=size(locreal,1);

%% ���ݶ�ȡ���õ��ĸ�����Ĺ۲�ֵ��ʵ��ֵ

tic
%% �쳣���ݶ�ȡ
filedir='�쳣����';
Distance_obs_negtive=[];
Distance_GT_negtive=[];
Loc_Real_negtive=[];
for ii=1:locnum%324
    filename2=[num2str(ii) '.�쳣.txt'];    
    [outres0,t]=fileread1(fullfile(filedir,filename2),Bsnum,1,[]);
    Distance_obs_negtive=[Distance_obs_negtive;outres0];%%�۲��ľ��룬N*4
    Distance_GT_temp= UWBToaObs(Bsloc,Bsnum,locreal(ii,:));%ʵ���ľ���        
    Distance_GT_negtive=[Distance_GT_negtive; repmat(Distance_GT_temp,[size(outres0,1),1])];%�͹۲������Ŀ��ȣ�ÿ���ļ���ͬ
    Loc_Real_negtive=[Loc_Real_negtive;repmat(locreal(ii,:),[size(outres0,1),1])];
end
toc
DATA_negtive.OBSdata=Distance_obs_negtive;%�۲����
DATA_negtive.GTdata=Distance_GT_negtive;%��ʵ����
DATA_negtive.PNtag=zeros(size(Distance_GT_negtive,1),1);%0�������쳣����ǩ
DATA_negtive.Loc_Real=Loc_Real_negtive;%��ʵ����

tic
%% �������ݶ�ȡ
filedir='��������';
Distance_obs_positive=[];
Distance_GT_positive=[];
Loc_Real_positive=[];
for ii=1:locnum%324
    filename2=[num2str(ii) '.����.txt'];    
    [outres0,t]=fileread1(fullfile(filedir,filename2),Bsnum,1,[]);
    Distance_obs_positive=[Distance_obs_positive;outres0];%%�۲��ľ��룬N*4
    Distance_GT_temp= UWBToaObs(Bsloc,Bsnum,locreal(ii,:));%ʵ���ľ���        
    Distance_GT_positive=[Distance_GT_positive; repmat(Distance_GT_temp,[size(outres0,1),1])];%�͹۲������Ŀ��ȣ�ÿ���ļ���ͬ
    Loc_Real_positive=[Loc_Real_positive;repmat(locreal(ii,:),[size(outres0,1),1])];
end
toc
DATA_positive.OBSdata=Distance_obs_positive;%�۲����
DATA_positive.GTdata=Distance_GT_positive;%��ʵ����
DATA_positive.PNtag=ones(size(Distance_GT_positive,1),1);%1����������
DATA_positive.Loc_Real=Loc_Real_positive;%��ʵ����

%% ���Թ��ư�������
tic
load('fitfunz.mat')%��Ϻ�������
%% �������Ĺ���
parfor ii=1:size(DATA_positive.OBSdata,1)%324
    Dis_obs=fitresult(DATA_positive.OBSdata(ii,:));
    [Loc_Est(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%����е������͹۲⵽���ĸ����룬�����������С�Ĺ�������(���ϸ��¹������꣬�����ê����ĸ����룬Ȼ��ţ�ٷ�����)
     Err_curve(ii,:)=Err_count(end,:);
end
DATA_positive.Loc_Est=Loc_Est;%�����������
DATA_positive.min_Err=Err_curve;
clear Loc_Est

%% �쳣���Ĺ���
parfor ii=1:size(DATA_negtive.OBSdata,1)%324
    Dis_obs=fitresult(DATA_negtive.OBSdata(ii,:));%û��fit������
    [Loc_Est(ii,:), Err_count]= UWBLocIters(Dis_obs',para);%����е������͹۲⵽���ĸ����룬�����������С�Ĺ�������(���ϸ��¹������꣬�����ê����ĸ����룬Ȼ��ţ�ٷ�����)
     Err_curve(ii,:)=Err_count(end,:);
end
DATA_negtive.Loc_Est=Loc_Est;%�쳣�������
DATA_negtive.min_Err=Err_curve;
toc

%% ��һ��
DATA_positive=normalization(DATA_positive,para);
DATA_negtive=normalization(DATA_negtive,para);

save('NET_DATA.mat','DATA_positive','DATA_negtive','para');%�������쳣�ж��㹻��
