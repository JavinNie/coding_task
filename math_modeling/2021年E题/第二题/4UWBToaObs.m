function Res = UWBToaObs(BsLoc,BsNum,TargetLoc)
%% ����е㵽ê�����
Res = zeros(1,BsNum);
for ii=1:BsNum
     Res(ii) = norm(BsLoc(ii,:)-TargetLoc); 
end
end
 