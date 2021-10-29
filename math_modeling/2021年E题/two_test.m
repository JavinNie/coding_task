%%
%׼�����ݼ�������ѵ��elm

%%

clear
maindir='C:\Users\admin\Desktop\2021��E��\����1��UWB���ݼ�\ԭʼ���ݼ�\';
aimdir='C:\Users\admin\Desktop\2021��E��\����1��UWB���ݼ�\';
subdir  = dir( maindir );

for i = length( subdir ):-1:3
    if( isequal( subdir( i ).name, '.' )||...
        isequal( subdir( i ).name, '..')||...
        ~subdir( i ).isdir)               % �������Ŀ¼������
        continue;
    end
    subdirpath = fullfile( maindir, subdir( i ).name, '*.txt' );
    dat = dir( subdirpath );           % ���ļ������Һ�׺Ϊdat���ļ�
    
    sort_nat_name=sort_nat({dat.name});     %ʹ��sort_nat��������

    
    for j = 1 : length( dat )
%         datpath = fullfile( maindir, subdir( i ).name, dat( j ).name);
        datpath = fullfile( maindir, subdir( i ).name, sort_nat_name{j});
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
        ind_ori=[1:length(Dis)];       
        ind_ori=reshape(ind_ori,4,length(Dis)/4);

        ind_del=[];
        
        ind=ind0;
        D0=Dis(ind);
        [D0,ind_deleted]=Tri_sigma_Filter(D0);
        ind_del=[ind_del; ind_deleted];
%          4*(ind_deleted-1)+1:4*ind_deleted
        
        
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
        
        ind_ori(:,ind_del)=[];
        
        ind_ori=reshape(ind_ori,1,numel(ind_ori));
        
         P=[header;P(ind_ori,:)];
         
         
% % ע���ļ���
        a=split(sort_nat_name{j},'.');
        
        filename= [[a{1} '.' a{2}],'.xlsx'];
        writetable(P, filename);
%%
    end
end

