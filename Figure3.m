%% MATLAB 代码：复现图3
% 仿真设置
t_start = 0;         % 起始时间（周）
t_end   = 52;        % 结束时间（周）
dt      = 0.5;       % 仿真步长（周）
time    = t_start:dt:t_end;  % 时间向量

% 最大标准（上限）
X_max = 10;

% 初始值（根据论文 Table 4 的状态变量初始值，单位为“分”，取近似值）
RE0 = 3.997;   % 互惠
SI0 = 3.770;   % 社会互动
DQ0 = 4.043;   % 数据质量
PBC0 = 3.327;  % 感知行为控制
TR0 = 3.947;   % 信任
SA0 = 3.995;   % 共享态度
SW0 = 3.757;   % 共享意愿

% 设定各变量的增长速率（根据论文描述，信任、共享态度、共享意愿增长较快）
r_RE  = 0.05;
r_SI  = 0.05;
r_DQ  = 0.05;
r_PBC = 0.05;
r_TR  = 0.1;
r_SA  = 0.12;
r_SW  = 0.1;
% r_TR  = 0.05;
% r_SA  = 0.05;
% r_SW  = 0.05;

% 初始化各变量随时间的存储向量
RE  = zeros(size(time));
SI  = zeros(size(time));
DQ  = zeros(size(time));
PBC = zeros(size(time));
TR  = zeros(size(time));
SA  = zeros(size(time));
SW  = zeros(size(time));

% 赋予初始值
RE(1)  = RE0;
SI(1)  = SI0;
DQ(1)  = DQ0;
PBC(1) = PBC0;
TR(1)  = TR0;
SA(1)  = SA0;
SW(1)  = SW0;

% 使用欧拉方法离散化求解逻辑斯谛增长微分方程
for i = 1:length(time)-1
    % 逻辑斯谛增长： dX/dt = r * X * (1 - X/X_max)
    RE(i+1)  = RE(i)  + r_RE  * RE(i)  * (1 - RE(i)/X_max)  * dt;
    SI(i+1)  = SI(i)  + r_SI  * SI(i)  * (1 - SI(i)/X_max)  * dt;
    DQ(i+1)  = DQ(i)  + r_DQ  * DQ(i)  * (1 - DQ(i)/X_max)  * dt;
    PBC(i+1) = PBC(i) + r_PBC * PBC(i) * (1 - PBC(i)/X_max) * dt;
    TR(i+1)  = TR(i)  + r_TR  * TR(i)  * (1 - TR(i)/X_max)  * dt;
    SA(i+1)  = SA(i)  + r_SA  * SA(i)  * (1 - SA(i)/X_max)  * dt;
    SW(i+1)  = SW(i)  + r_SW  * SW(i)  * (1 - SW(i)/X_max)  * dt;
end

% 绘制图3：各变量随时间的变化趋势
subplot(1, 2, 1)
plot(time, SW, 'y-', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('状态变量值');
title('科学数据共享意愿变化趋势');
legend('共享意愿 (SW)', 'Location', 'southwest');

subplot(1, 2, 2)
hold on
plot(time, RE, 'b-', 'LineWidth',1.5);
plot(time, SI, 'g-', 'LineWidth',1.5);
plot(time, DQ, 'c-', 'LineWidth',1.5);
plot(time, PBC, 'm-', 'LineWidth',1.5);
plot(time, TR, 'r-', 'LineWidth',1.5);
plot(time, SA, 'k-', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('状态变量值');
title('科学数据共享意愿的各影响因素变化趋势');
legend('互惠 (RE)', '社会互动 (SI)', '数据质量 (DQ)', '感知行为控制 (PBC)', ...
       '信任 (TR)', '共享态度 (SA)',  'Location', 'southeast');
grid on;
