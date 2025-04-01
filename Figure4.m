%% MATLAB代码：复现图4——不同信任速率情境下的仿真
% 仿真时间参数
t_start = 0;      % 起始时间（周）
t_end   = 52;     % 结束时间（周）
dt      = 0.5;    % 仿真步长（周）
time    = t_start:dt:t_end;  % 时间向量
X_max   = 10;     % 变量上限

% 基础参数（基准情境，参考图3）
TR0_base = 3.947;  % 信任初始值基准
SA0 = 3.995;       % 共享态度初始值
SW0 = 3.757;       % 共享意愿初始值

r_TR_base = 0.1;  % 信任增长速率基准
r_SA = 0.12;       % 共享态度增长速率（依赖于信任）
r_SW = 0.1;       % 共享意愿增长速率（依赖于共享态度）

% 情境1：方案一 —— 提升信任影响50%，初始信任降低30%
r_TR_1 = 1.5 * r_TR_base;           % 信任速率提升50%
TR0_1 = 0.7 * TR0_base;             % 初始信任降低30%

% 情境2：方案二 —— 降低信任影响50%，初始信任提高30%
r_TR_2 = 0.5 * r_TR_base;           % 信任速率降低50%
TR0_2 = 1.3 * TR0_base;             % 初始信任提高30%

% 初始化情境1各变量
TR1 = zeros(size(time));
SA1 = zeros(size(time));
SW1 = zeros(size(time));
TR1(1) = TR0_1;
SA1(1) = SA0;
SW1(1) = SW0;

% 初始化情境2各变量
TR2 = zeros(size(time));
SA2 = zeros(size(time));
SW2 = zeros(size(time));
TR2(1) = TR0_2;
SA2(1) = SA0;
SW2(1) = SW0;

% 离散化求解：采用欧拉法
for i = 1:length(time)-1
    % 情境1信任动态：dTR/dt = r_TR_1 * TR1*(1 - TR1/X_max)
    TR1(i+1) = TR1(i) + r_TR_1 * TR1(i) * (1 - TR1(i)/X_max) * dt;
    % 情境1共享态度：受信任直接影响
    SA1(i+1) = SA1(i) + r_SA * TR1(i) * (1 - SA1(i)/X_max) * dt;
    % 情境1共享意愿：受共享态度直接影响
    SW1(i+1) = SW1(i) + r_SW * SA1(i) * (1 - SW1(i)/X_max) * dt;
    
    % 情境2信任动态
    TR2(i+1) = TR2(i) + r_TR_2 * TR2(i) * (1 - TR2(i)/X_max) * dt;
    % 情境2共享态度：受信任直接影响
    SA2(i+1) = SA2(i) + r_SA * TR2(i) * (1 - SA2(i)/X_max) * dt;
    % 情境2共享意愿：受共享态度直接影响
    SW2(i+1) = SW2(i) + r_SW * SA2(i) * (1 - SW2(i)/X_max) * dt;
end

% 计算信任变化率（差分近似：ΔTR/dt）
dTR1 = diff(TR1) / dt;
dTR2 = diff(TR2) / dt;
time_diff = time(1:end-1);  % 变化率对应的时间点

% 绘图：比较情境1与情境2的信任、共享态度、共享意愿变化
figure;

% 绘制信任变化量
subplot(2, 2, 1);
plot(time_diff, dTR1, 'r-', 'LineWidth',1.5); hold on;
plot(time_diff, dTR2, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('信任变化率 (ΔTR/dt)');
title('信任变化率对比');
legend('方案一','方案二','Location','northeast');
grid on;

% 绘制信任比较
subplot(2, 2, 2);
plot(time, TR1, 'r-', 'LineWidth',1.5); hold on;
plot(time, TR2, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)'); ylabel('信任 (TR)');
title('不同信任速率下的信任变化');
legend('方案一','方案二','Location','southeast');
grid on;

% 绘制共享态度比较
subplot(2, 2, 3);
plot(time, SA1, 'r-', 'LineWidth',1.5); hold on;
plot(time, SA2, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)'); ylabel('共享态度 (SA)');
title('不同信任速率下的共享态度变化');
legend('方案一','方案二','Location','southeast');
grid on;

% 绘制共享意愿比较
subplot(2, 2, 4);
plot(time, SW1, 'r-', 'LineWidth',1.5); hold on;
plot(time, SW2, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)'); ylabel('共享意愿 (SW)');
title('不同信任速率下的共享意愿变化');
legend('方案一','方案二','Location','southeast');
grid on;
