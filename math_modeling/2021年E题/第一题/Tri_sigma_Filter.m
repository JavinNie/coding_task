function [D1,ind_deleted]=Tri_sigma_Filter(D0)
ind_deleted=[];
ind_ori=[1:length(D0)]';
for i=1:10
        Vpp0=max(D0)-min(D0);        
        Jump=abs(D0-mean(D0));        
        ind_del=find(Jump>3*std(D0));%3 sigma判据
        D0(ind_del)=[];        
        ind_deleted=[ind_deleted;ind_ori(ind_del)];
        ind_ori(ind_del)=[];               
        Vpp1=max(D0)-min(D0);        
        if Vpp1==Vpp0%无变化时停止
            break
        end
end
D1=D0;