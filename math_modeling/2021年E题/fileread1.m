% ×Ô¶¨Òå
function     [outres,t]=fileread1(filename,Bsnum,rowstart,dec);

        P=readtable([filename]);
        
        header=P(1,:);
        P=P(rowstart+1:end,:);
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
        

        D0=Dis(ind0);        
        D1=Dis(ind1);        
        D2=Dis(ind2);        
        D3=Dis(ind3);
        outres=[D0,D1,D2,D3];

        
        t0=Time(ind0);        
        t1=Time(ind1);        
        t2=Time(ind2);        
        t3=Time(ind3);
        
        tt=[t0,t1,t2,t3];
        t=round(mean(tt,2));