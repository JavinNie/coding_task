function [Xres,Err_count] = UWBLocIters(Obs,para)
%% GN法预估靶点坐标
Thr = para.Thr; 
DataLen = para.DataLen; 
BsNum = para.BsNum;
BsLoc = para.BsLoc;  %锚点坐标
dRef = para.dRef;
Xres = zeros(DataLen,3); 
Xinit = para.xinit;
MaxIters = para.MaxIters;
Err_count=[];
ErrLast=0;
unchange_count=0;
for ii=1:DataLen%就一行
    X = Xinit;
    ObsX = Obs(ii,:);%第ii个点的四个距离
    for it=1:MaxIters%迭代25轮
        %输入参数【锚点坐标，锚点数目，X是靶点】，从中间初始位置开始，返回值是到四个锚点的距离
        ObsE = UWBToaObs(BsLoc,BsNum,X);    
%         %计算误差，观测到的四个距离和最新点的四个距离
      Err = ObsX-ObsE;
        
        Err_count=[Err_count;abs(Err)];
        %四个距离值。分别在xyz三个方向上的微分值，【4*3】
        J = Jcal(BsNum,X,BsLoc);
        dX = (J'*J)^(-1)*J'*Err';        
        X = X+dX';        
        %% 终止条件1：三步都没有变化，则终止
        if (abs(ErrLast-sum(abs(Err)))>1)
            unchange_count=0;
        else
            unchange_count=unchange_count+1;
        end
        if(unchange_count>3)
            break;
        end
        %% 终止条件2：三位误差之和小于阈值，则终止
        if (sum(abs(Err))<Thr)
            break;
        end        
        ErrLast=sum(abs(Err));
        %% 终止条件3：超出最大迭代次数，则终止
    end    
    Xres(ii,:) = X;%迭代更新靶点位置
end
end

%雅可比矩阵生成
function J = Jcal(bsNum,loc,BsLoc)%求微分值
J = zeros(bsNum,3);
dd = 0.01;
%返回靶点到四个锚点的距离
Res0 = UWBToaObs(BsLoc,bsNum,loc);
%靶点三个维度，分别取一个很小的增值，然后再算，到四个锚点的距离
Resx1 = UWBToaObs(BsLoc,bsNum,loc+[dd 0 0]);
Resy1 = UWBToaObs(BsLoc,bsNum,loc+[0 dd 0]);
Resz1 = UWBToaObs(BsLoc,bsNum,loc+[0 0 dd]);

%除以干扰量，得到的是四个距离值分别在xyz三个方向上的微分值
J(:,1)=(Resx1-Res0)'/dd;
J(:,2)=(Resy1-Res0)'/dd;
J(:,3)=(Resz1-Res0)'/dd;

end