%% ������ϴ����д�����ļ�
clear
maindir='C:\Users\admin\Desktop\2021��E��\����1��UWB���ݼ�\ԭʼ���ݼ�\';
aimdir='C:\Users\admin\Desktop\2021��E��\����1��UWB���ݼ�\';
subdir  = dir( maindir );
for i = length( subdir ):-1:3%4��������3���쳣
    
    if( isequal( subdir( i ).name, '.' )||...
        isequal( subdir( i ).name, '..')||...
        ~subdir( i ).isdir)               % �������Ŀ¼������
        continue;
    end
    subdirpath = fullfile( maindir, subdir( i ).name, '*.txt' );
    dat = dir( subdirpath );           % ���ļ������Һ�׺Ϊtxt���ļ�
    sort_nat_name=sort_nat({dat.name});     %ʹ��sort_nat��������
    for j = 1 : length( dat )
        %% �����ж�ѡ����ĿҪ����ĸ��ض��ļ�����ע������������ļ�        
        if (i==4 & j==24)| (i==4 & j==109) |(i==3 & j==1)|(i==3 & j==100)
            disp([subdir( i ).name, sort_nat_name{j}])
        else
            continue
        end
        datpath = fullfile( maindir, subdir( i ).name, sort_nat_name{j});
        P=readtable([datpath]);
        
        header=P(1,:);
        P(1,:)=[];

        Time=table2array(P(:,2));
        TagID=cellfun(@str2num,table2array(P(:,4)));
        MID=cellfun(@str2num,table2array(P(:,5)));
        Dis=cellfun(@str2num,table2array(P(:,6)));
        ReDis=cellfun(@str2num,table2array(P(:,7)));
        Order=table2array(P(:,8));
        No=cellfun(@str2num,table2array(P(:,9)));

        ind0=find(MID==0);
        ind1=find(MID==1);
        ind2=find(MID==2);
        ind3=find(MID==3);
        
%%
        if any(Dis-ReDis)
            print(dat( j ).name)
        end        
%%
%����ԭʼ����
        ind_ori=[1:length(Dis)];       
        ind_ori=reshape(ind_ori,4,length(Dis)/4);
%������ɾ��������
        ind_del=[];
        
 %% �ҵ�ֵ�쳣�ĵ㣬3sigma׼��Tri_sigma_Filter�˲�����
%����ɾ������������ֵ�쳣��ɾ��
        ind=ind0;
        [~,ind_deleted]=Tri_sigma_Filter(Dis(ind));
        ind_del=[ind_del; ind_deleted];
   
        ind=ind1;
        [~,ind_deleted]=Tri_sigma_Filter(Dis(ind));
        ind_del=[ind_del; ind_deleted];
        
        ind=ind2;
        [~,ind_deleted]=Tri_sigma_Filter(Dis(ind));
        ind_del=[ind_del; ind_deleted];
        
        ind=ind3;
        [~,ind_deleted]=Tri_sigma_Filter(Dis(ind));       
        ind_del=[ind_del; ind_deleted];
        
        ind_del_value=unique(ind_del);
  %% �ҵ�ֵ��ͬ���Ƶĵ�   
        D0=Dis(ind0);        
        D1=Dis(ind1);        
        D2=Dis(ind2);        
        D3=Dis(ind3);
        
        DD0=abs(diff(D0));
        DD1=abs(diff(D1));
        DD2=abs(diff(D2));
        DD3=abs(diff(D3));
        
        thres=8;%������ֵ
        ind_del_time=find(DD0<=thres & DD1<=thres &DD2<=thres &DD3<=thres);
        ind_del_same=find(DD0==0 & DD1==0 &DD2==0 &DD3==0);

%% ɾ��ֵ�쳣��������ֵ��ͬ���Ƶ�����
        ind_ori(:,[ind_del_value;ind_del_time])=[];

%% ͳ����ϴ�������
        num_sample(i,j)=size(ind_ori,2);%ʣ��������
        
        num_neg(i,j)=length(ind_del_value);%�쳣ֵɾ����Ŀ     
        num_same(i,j)=length(ind_del_same);%��ֵͬɾ����Ŀ 
        num_near(i,j)=length(ind_del_time)-num_same(i,j);%%����ֵɾ����Ŀ 
     
%% ���½����Դ�д��
        ind_ori=reshape(ind_ori,1,numel(ind_ori));        
         P=[header;P(ind_ori,:)];
         
         
        %% ����ϴ����������
        ind_del=[ind_del_value;ind_del_time];
        ind_del=unique(ind_del);

        ind_ALL=[1:length(D3)];
        ind_reserve=setdiff(ind_ALL,ind_del);
         %% ��ͼ                  
         L1=1;
         L2=0.9;
         
        subplot(2,2,1)
        ind=ind0;
        D0=Dis(ind);
        plot(D0,'LineWidth',L1);
        hold on
        plot(ind_reserve,D0(ind_reserve),'LineWidth',L2);
        hold off        
        title('A0')

        subplot(2,2,2)
        ind=ind1;
        D0=Dis(ind);
        plot(D0,'LineWidth',L1);
        hold on
        plot(ind_reserve,D0(ind_reserve),'LineWidth',L2);
        hold off               
        title('A1')
        legend('��ϴǰ','��ϴ��')
        
        subplot(2,2,3)
        ind=ind2;
        D0=Dis(ind);
        plot(D0,'LineWidth',L1);
        hold on
        plot(ind_reserve,D0(ind_reserve),'LineWidth',L2);
        hold off             
        title('A2')
        
        subplot(2,2,4)
        ind=ind3;
        D0=Dis(ind);
        plot(D0,'LineWidth',L1);
        hold on
        plot(ind_reserve,D0(ind_reserve),'LineWidth',L2);
        hold off             
        title('A3')
         
        sgtitle([sort_nat_name{j} ' -- '  'ʣ������:' num2str(length(ind_reserve))]);
        pause(0.1)
        saveas(gcf,[sort_nat_name{j},'.png']);
         
%% д���ļ���ע���ļ���
        a=split(sort_nat_name{j},'.');        
        filename= [[a{1} '.' a{2}],'.txt'];
        writetable(P, filename,'WriteVariableNames',false);
%%
    end
end

%% ��ϴ���ͳ��������쳣����ͬ�����ƣ�����ȱʧ
sum(num_neg,2)
sum(num_same,2)
sum(num_near,2)

figure
hold on
plot(num_sample(4,:),'LineWidth',2)%����
plot(num_sample(3,:),'LineWidth',2)%�쳣
legend('�޸���','�и���')
xlabel('�ļ����')
ylabel('ʣ��������')
title('������ϴ����ļ���ʣ��������')
hold off
axis([-1,340,0,500])
set(gca,'FontSize',15);
