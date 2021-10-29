%%
%数据清洗，且写入文件

%%

clear

%         datpath = fullfile( maindir, subdir( i ).name, dat( j ).name);
        datpath ='附件5：动态轨迹数据.txt';
        P=readtable([datpath]);
        
        header=P(1,:);
        P(1,:)=[];
%         P(:,[1 3 ])=[];

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
   
%更新删除索引，根据值异常点删除
        ind=ind0;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        ind_del=[ind_del; ind_deleted];
   
        ind=ind1;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        ind_del=[ind_del; ind_deleted];
        
        ind=ind2;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        ind_del=[ind_del; ind_deleted];
        
        ind=ind3;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);       
        ind_del=[ind_del; ind_deleted];
%         删除值异常的索引
        ind_ori(:,ind_del)=[];
  
        t0=Time(ind0);        
        t1=Time(ind1);        
        t2=Time(ind2);        
        t3=Time(ind3);
        
        tt=[t0,t1,t2,t3];
        
        tt(:,ind_del)=[];
        
        t=round(mean(tt,2));        
        
        indtime=find(diff(t)<0);
        
        
           
%更新删除索引，根据时间异常点删除
        ind=ind0;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        ind_del=[ind_del; ind_deleted];
   
        ind=ind1;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        ind_del=[ind_del; ind_deleted];
        
        ind=ind2;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        ind_del=[ind_del; ind_deleted];
        
        ind=ind3;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);       
        ind_del=[ind_del; ind_deleted];
%         删除时间异常的索引
        ind_ori(:,ind_del)=[];
        
        
        ind_ori=reshape(ind_ori,1,numel(ind_ori));
        
         P=[header;P(ind_ori,:)];
         
         
% % 注意文件名
        a=split(sort_nat_name{j},'.');
        
%         filename= [[a{1} '.' a{2}],'.txt'];
%         writetable(P, filename,'WriteVariableNames',false);


