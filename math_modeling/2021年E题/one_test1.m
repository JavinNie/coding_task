clear
maindir='C:\Users\admin\Desktop\2021��E��\����1��UWB���ݼ�\ԭʼ���ݼ�\';
aimdir='C:\Users\admin\Desktop\2021��E��\����1��UWB���ݼ�\';
subdir  = dir( maindir );

for i = 3:length( subdir )
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
        
        
        ind=ind0;
        D0=Dis(ind);
        plot(D0);
        hold on
        Ds0= smooth(Dis(ind),8);
        Jump=abs(Ds0-D0);
        ind_del=find(Jump>3*mean(Jump));
        D0(ind_del)=[];
        plot(D0);
        hold off
%%

        subplot(2,2,1)
        plot(Dis(ind0))
        title(num2str(max(Dis(ind0))-min(Dis(ind0))))

        subplot(2,2,2)
        plot(Dis(ind1))
        title(num2str(max(Dis(ind1))-min(Dis(ind1))))
        
        subplot(2,2,3)
        plot(Dis(ind2))
        title(num2str(max(Dis(ind2))-min(Dis(ind2))))
        
        subplot(2,2,4)
        plot(Dis(ind3))
        title(num2str(max(Dis(ind3))-min(Dis(ind3))))
%         

% Ѱ�ҷ���ж��쳣�����ֵ��ȡ����ֵ�ı�׼
        sgtitle(sort_nat_name{i});
%         sgtitle(dat( j ).name);   
% % % ע���ļ���
%         saveas(gcf,[aimdir, subdir( i ).name,'picture\',sort_nat_name{j},'.png']);
% %         saveas(gcf,[aimdir, subdir( i ).name,'picture\',dat( j ).name,'.png']);
        pause(0.1)
%%
 

    end
end

