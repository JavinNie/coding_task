function Res = UWBToaObs(BsLoc,BsNum,TargetLoc)
%% 计算靶点到锚点距离
Res = zeros(1,BsNum);
for ii=1:BsNum
     Res(ii) = norm(BsLoc(ii,:)-TargetLoc); 
end
end
 