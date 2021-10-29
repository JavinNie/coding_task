%%
%数据清洗，绘图展示

%%


clear
maindir='C:\Users\admin\Desktop\2021年E题\附件1：UWB数据集\原始数据集\';
aimdir='C:\Users\admin\Desktop\2021年E题\附件1：UWB数据集\';
subdir  = dir( maindir );

for i = length( subdir ):-1:3
    if( isequal( subdir( i ).name, '.' )||...
        isequal( subdir( i ).name, '..')||...
        ~subdir( i ).isdir)               % 如果不是目录则跳过
        continue;
    end
    subdirpath = fullfile( maindir, subdir( i ).name, '*.txt' );
    dat = dir( subdirpath );           % 子文件夹下找后缀为dat的文件
    
    sort_nat_name=sort_nat({dat.name});     %使用sort_nat进行排序

    
    for j = 1 : length( dat )
%         datpath = fullfile( maindir, subdir( i ).name, dat( j ).name);
        datpath = fullfile( maindir, subdir( i ).name, sort_nat_name{j});
        P=readtable([datpath]);
        P(1,:)=[];
        P(:,[1 3 ])=[];

        Time=table2array(P(:,1));
        TagID=cellfun(@str2num,table2array(P(:,2)));
        MID=cellfun(@str2num,table2array(P(:,3)));
        Dis=cellfun(@str2num,table2array(P(:,4)));
        ReDis=cellfun(@str2num,table2array(P(:,5)));
        Order=table2array(P(:,6));
        No=cellfun(@str2num,table2array(P(:,7)));

        ind0=find(MID==0);
        ind1=find(MID==1);
        ind2=find(MID==2);
        ind3=find(MID==3);
        
%%
        if any(Dis-ReDis)
            print(dat( j ).name)
        end
        
%%
        subplot(2,2,1)
        ind=ind0;
        D0=Dis(ind);
        plot(D0);
        hold on
        [D0,ind_deleted]=Tri_sigma_Filter(D0);        
        plot(D0);
        hold off        
        title(num2str(max(Dis(ind0))-min(Dis(ind0))))

        subplot(2,2,2)
        ind=ind1;
        D0=Dis(ind);
        plot(D0);
        hold on
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        plot(D0);
        hold off
        title(num2str(max(Dis(ind1))-min(Dis(ind1))))
        
        subplot(2,2,3)
        ind=ind2;
        D0=Dis(ind);
        plot(D0);
        hold on
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        plot(D0);
        hold off
        title(num2str(max(Dis(ind2))-min(Dis(ind2))))
        
        subplot(2,2,4)
        ind=ind3;
        D0=Dis(ind);
        plot(D0);
        hold on
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        plot(D0);
        hold off
        title(num2str(max(Dis(ind3))-min(Dis(ind3))))
        
        sgtitle(sort_nat_name{j});
        pause(0.15)
% % 注意文件名
%         saveas(gcf,[aimdir, subdir( i ).name,'picture\',sort_nat_name{j},'.png']);

%%
    end
end

