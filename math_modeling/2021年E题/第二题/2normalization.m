function DATA_N=normalization(DATA,para)

% DATA.OBSdata%�۲����
% DATA.GTdata%��ʵ����
% DATA.PNtag%1����������
% DATA.Loc_Real%��ʵ����
% DATA.Loc_Est%��������

DATA_N=DATA;
%% �����һ����
DATA_N.Loc_Real=DATA.Loc_Real./para.field;%��ʵ����
DATA_N.Loc_Est=DATA.Loc_Est./para.field;%��������

%% �����һ��
DATA_N.GTdata=DATA.GTdata/norm(para.field);%��һ������ʵ�ľ���
DATA_N.OBSdata=DATA.OBSdata/norm(para.field);%�۲����
%% ��ǩ����
DATA_N.PNtag=DATA.PNtag;
DATA_N.min_Err=DATA_N.min_Err;%��С��� /����֮�Ͱ�








