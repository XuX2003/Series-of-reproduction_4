%% 图5：复现感知行为控制与共享意愿变化及其变化率（两方案对比）
% 仿真时间参数
t_start = 0;
t_end   = 52;
dt      = 0.5;
time    = t_start:dt:t_end;
X_max   = 50;

% 设定参数
r_PBC = 0.05;   % 感知行为控制增长速率
r_SW  = 0.1;    % 共享意愿增长速率

% 其它变量初始值（SW初始值保持相同，取文中值）
SW0 = 3.757;

% 情境1：方案一，PBC初始值设为5
PBC0_A = 5;
% 情境2：方案二，PBC初始值设为1
PBC0_B = 1;

% 初始化两方案的 PBC 与 SW 数值
PBC_A = zeros(size(time));
PBC_B = zeros(size(time));
SW_A  = zeros(size(time));
SW_B  = zeros(size(time));

PBC_A(1) = PBC0_A;
PBC_B(1) = PBC0_B;
SW_A(1)  = SW0;
SW_B(1)  = SW0;

% 欧拉法求解 PBC 和 SW 的动态方程
for i = 1:length(time)-1
    % PBC 动态：逻辑斯谛增长
    PBC_A(i+1) = PBC_A(i) + r_PBC * PBC_A(i) * (1 - PBC_A(i)/X_max) * dt;
    PBC_B(i+1) = PBC_B(i) + r_PBC * PBC_B(i) * (1 - PBC_B(i)/X_max) * dt;
    
    % SW 动态：受 PBC 直接影响
    SW_A(i+1) = SW_A(i) + r_SW * PBC_A(i) * (1 - SW_A(i)/X_max) * dt;
    SW_B(i+1) = SW_B(i) + r_SW * PBC_B(i) * (1 - SW_B(i)/X_max) * dt;
end

% 计算 PBC 和 SW 的变化率（差分近似）
dPBC_A = diff(PBC_A) / dt;
dPBC_B = diff(PBC_B) / dt;
dSW_A  = diff(SW_A)  / dt;
dSW_B  = diff(SW_B)  / dt;
time_diff = time(1:end-1);

% 绘制图5：四个子图对比（值和变化率）
% 子图1：PBC 变化率随时间变化
subplot(2,2,1);
plot(time_diff, dPBC_A, 'r-', 'LineWidth',1.5); hold on;
plot(time_diff, dPBC_B, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('ΔPBC/dt');
title('PBC 变化率对比');
legend('方案一','方案二','Location','northeast');
grid on;

% 子图2：PBC 值随时间变化
subplot(2,2,2);
plot(time, PBC_A, 'r-', 'LineWidth',1.5); hold on;
plot(time, PBC_B, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('感知行为控制 (PBC)');
title('PBC 数值对比');
legend('方案一 (PBC0=5)','方案二 (PBC0=1)','Location','southeast');
grid on;

% 子图3：SW 变化率随时间变化
subplot(2,2,3);
plot(time_diff, dSW_A, 'r-', 'LineWidth',1.5); hold on;
plot(time_diff, dSW_B, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('ΔSW/dt');
title('SW 变化率对比');
legend('方案一','方案二','Location','northeast');
grid on;

% 子图4：SW 值随时间变化
subplot(2,2,4);
plot(time, SW_A, 'r-', 'LineWidth',1.5); hold on;
plot(time, SW_B, 'b--', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('共享意愿 (SW)');
title('SW 数值对比');
legend('方案一','方案二','Location','southeast');
grid on;