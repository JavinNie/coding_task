function [Xres,Err_count] = UWBLocIters(Obs,para)
%% GN��Ԥ���е�����
Thr = para.Thr; 
DataLen = para.DataLen; 
BsNum = para.BsNum;
BsLoc = para.BsLoc;  %ê������
dRef = para.dRef;
Xres = zeros(DataLen,3); 
Xinit = para.xinit;
MaxIters = para.MaxIters;
Err_count=[];
ErrLast=0;
unchange_count=0;
for ii=1:DataLen%��һ��
    X = Xinit;
    ObsX = Obs(ii,:);%��ii������ĸ�����
    for it=1:MaxIters%����25��
        %���������ê�����꣬ê����Ŀ��X�ǰе㡿�����м��ʼλ�ÿ�ʼ������ֵ�ǵ��ĸ�ê��ľ���
        ObsE = UWBToaObs(BsLoc,BsNum,X);    
%         %�������۲⵽���ĸ���������µ���ĸ�����
      Err = ObsX-ObsE;
        
        Err_count=[Err_count;abs(Err)];
        %�ĸ�����ֵ���ֱ���xyz���������ϵ�΢��ֵ����4*3��
        J = Jcal(BsNum,X,BsLoc);
        dX = (J'*J)^(-1)*J'*Err';        
        X = X+dX';        
        %% ��ֹ����1��������û�б仯������ֹ
        if (abs(ErrLast-sum(abs(Err)))>1)
            unchange_count=0;
        else
            unchange_count=unchange_count+1;
        end
        if(unchange_count>3)
            break;
        end
        %% ��ֹ����2����λ���֮��С����ֵ������ֹ
        if (sum(abs(Err))<Thr)
            break;
        end        
        ErrLast=sum(abs(Err));
        %% ��ֹ����3����������������������ֹ
    end    
    Xres(ii,:) = X;%�������°е�λ��
end
end

%�ſɱȾ�������
function J = Jcal(bsNum,loc,BsLoc)%��΢��ֵ
J = zeros(bsNum,3);
dd = 0.01;
%���ذе㵽�ĸ�ê��ľ���
Res0 = UWBToaObs(BsLoc,bsNum,loc);
%�е�����ά�ȣ��ֱ�ȡһ����С����ֵ��Ȼ�����㣬���ĸ�ê��ľ���
Resx1 = UWBToaObs(BsLoc,bsNum,loc+[dd 0 0]);
Resy1 = UWBToaObs(BsLoc,bsNum,loc+[0 dd 0]);
Resz1 = UWBToaObs(BsLoc,bsNum,loc+[0 0 dd]);

%���Ը��������õ������ĸ�����ֵ�ֱ���xyz���������ϵ�΢��ֵ
J(:,1)=(Resx1-Res0)'/dd;
J(:,2)=(Resy1-Res0)'/dd;
J(:,3)=(Resz1-Res0)'/dd;

end