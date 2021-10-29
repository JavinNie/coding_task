% GPS精度为1m、气压计精度为0.5m，加速度计的精度为 1cm/s^2
% 无人机按照螺旋线飞行，半径为 20m，螺距为40m，100s完成一圈飞行
% 数据采集频率为 10Hz
%  
% clear all
function Loc_Est_KF =KF(Loc_Est_inter,para)
 
D = 3;                          % 维度，可取 1,2,3
 
N =size(Loc_Est_inter,1);                 % 采样点数
 
A = eye(D);                     % 状态转移矩阵，和上一时刻状态没有换算，故取 D阶单位矩阵
A(1,2)=100;
A(2,3)=100;
x = zeros(D, N);                % 存储滤波后的数据
% z = ones(D, N);                 % 存储滤波前的数据
x(:, 1) = Loc_Est_inter(1,:)';            % 初始值设为 1（可为任意数）
P = eye(D);                     % 初始值为 1（可为非零任意数），取 D阶单位矩阵
      

Q = 5*eye(D);                % 过程噪声协方差，估计一个
R = 5*eye(3);                  % 测量噪声协方差，精度为多少取多少
 
k = 1;                          % 采样点计数
 
% 三维 x,y,z方向，GPS和气压计
% true3D = [r * cos(w*t0); r * sin(w*t0); t0 * 0.4];

 
for t = 1:size(Loc_Est_inter,1)
    k = k + 1;                  
    x(:,k) = A * x(:,k-1);      % 卡尔曼公式1
    P = A * P * A' + Q;         % 卡尔曼公式2
    H = eye(D);
    K = P*H' * inv(H*P*H' + R); % 卡尔曼公式3
                               % 三维 x,y,z 方向
    z(:,k) =Loc_Est_inter(t,:)';%滤波器前数据

    x(:,k) = x(:,k) + K * (z(:,k)-H*x(:,k));    % 卡尔曼公式4
    P = (eye(D)-K*H) * P;                       % 卡尔曼公式5
end
    Loc_Est_KF=x;
    %% 三维情况
%     figure
%     plot3(z(1,:),z(2,:),z(3,:),'b.');           % 绘制滤波前数据
%     axis('equal');grid on;hold on               % 坐标等距、继续绘图、添加网格
%     plot3(x(1,:),x(2,:),x(3,:),'r.');           % 绘制滤波后数据
%     plot3(true3D(1,:), true3D(2,:), true3D(3,:));% 绘制滤波后数据
%     legend('滤波前','滤波后','理想值');           % 绘制真实值
%     xlabel('x方向: m');
%     ylabel('y方向: m');
%     zlabel('高度: m');hold off;
