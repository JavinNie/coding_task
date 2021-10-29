function DATA_N=normalization(DATA,para)

% DATA.OBSdata%观测距离
% DATA.GTdata%真实距离
% DATA.PNtag%1代表有正常
% DATA.Loc_Real%真实坐标
% DATA.Loc_Est%估计坐标

DATA_N=DATA;
%% 坐标归一化；
DATA_N.Loc_Real=DATA.Loc_Real./para.field;%真实坐标
DATA_N.Loc_Est=DATA.Loc_Est./para.field;%估计坐标

%% 距离归一化
DATA_N.GTdata=DATA.GTdata/norm(para.field);%归一化，真实四距离
DATA_N.OBSdata=DATA.OBSdata/norm(para.field);%观测距离
%% 标签不变
DATA_N.PNtag=DATA.PNtag;
DATA_N.min_Err=DATA_N.min_Err;%最小误差 /距离之和吧








