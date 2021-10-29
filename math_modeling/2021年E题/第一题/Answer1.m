%% 数据清洗，且写入新文件
clear
maindir='C:\Users\admin\Desktop\2021年E题\附件1：UWB数据集\原始数据集\';
aimdir='C:\Users\admin\Desktop\2021年E题\附件1：UWB数据集\';
subdir  = dir( maindir );
for i = length( subdir ):-1:3%4，正常，3，异常
    
    if( isequal( subdir( i ).name, '.' )||...
        isequal( subdir( i ).name, '..')||...
        ~subdir( i ).isdir)               % 如果不是目录则跳过
        continue;
    end
    subdirpath = fullfile( maindir, subdir( i ).name, '*.txt' );
    dat = dir( subdirpath );           % 子文件夹下找后缀为txt的文件
    sort_nat_name=sort_nat({dat.name});     %使用sort_nat进行排序
    for j = 1 : length( dat )
        %% 下述判断选择题目要求的四个特定文件，若注释则遍历所有文件        
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
%创建原始索引
        ind_ori=[1:length(Dis)];       
        ind_ori=reshape(ind_ori,4,length(Dis)/4);
%创建待删除的索引
        ind_del=[];
        
 %% 找到值异常的点，3sigma准则，Tri_sigma_Filter滤波函数
%更新删除索引，根据值异常点删除
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
  %% 找到值相同相似的点   
        D0=Dis(ind0);        
        D1=Dis(ind1);        
        D2=Dis(ind2);        
        D3=Dis(ind3);
        
        DD0=abs(diff(D0));
        DD1=abs(diff(D1));
        DD2=abs(diff(D2));
        DD3=abs(diff(D3));
        
        thres=8;%相似阈值
        ind_del_time=find(DD0<=thres & DD1<=thres &DD2<=thres &DD3<=thres);
        ind_del_same=find(DD0==0 & DD1==0 &DD2==0 &DD3==0);

%% 删除值异常的索引和值相同相似的索引
        ind_ori(:,[ind_del_value;ind_del_time])=[];

%% 统计清洗相关数据
        num_sample(i,j)=size(ind_ori,2);%剩余样本数
        
        num_neg(i,j)=length(ind_del_value);%异常值删除数目     
        num_same(i,j)=length(ind_del_same);%相同值删除数目 
        num_near(i,j)=length(ind_del_time)-num_same(i,j);%%相似值删除数目 
     
%% 重新建表，以待写入
        ind_ori=reshape(ind_ori,1,numel(ind_ori));        
         P=[header;P(ind_ori,:)];
         
         
        %% 被清洗样本的索引
        ind_del=[ind_del_value;ind_del_time];
        ind_del=unique(ind_del);

        ind_ALL=[1:length(D3)];
        ind_reserve=setdiff(ind_ALL,ind_del);
         %% 绘图                  
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
        legend('清洗前','清洗后')
        
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
         
        sgtitle([sort_nat_name{j} ' -- '  '剩余样本:' num2str(length(ind_reserve))]);
        pause(0.1)
        saveas(gcf,[sort_nat_name{j},'.png']);
         
%% 写回文件，注意文件名
        a=split(sort_nat_name{j},'.');        
        filename= [[a{1} '.' a{2}],'.txt'];
        writetable(P, filename,'WriteVariableNames',false);
%%
    end
end

%% 清洗情况统计输出（异常，相同，相似），无缺失
sum(num_neg,2)
sum(num_same,2)
sum(num_near,2)

figure
hold on
plot(num_sample(4,:),'LineWidth',2)%正常
plot(num_sample(3,:),'LineWidth',2)%异常
legend('无干扰','有干扰')
xlabel('文件编号')
ylabel('剩余样本数')
title('数据清洗后各文件的剩余样本数')
hold off
axis([-1,340,0,500])
set(gca,'FontSize',15);
