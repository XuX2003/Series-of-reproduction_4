%% 复现图6：不同初始共享意愿条件下的动态变化
% 仿真参数
t_start = 0;
t_end   = 52;
dt      = 0.5;
time    = t_start:dt:t_end;
X_max   = 10;  % 共享意愿上限
r_SW    = 0.1; % 共享意愿增长速率

% 方案设定（不同初始共享意愿）
SW0_A = 1;  % 方案一：共享意愿较低
SW0_B = 3;  % 方案二：共享意愿中等
SW0_C = 5;  % 方案三：共享意愿较高

% 初始化共享意愿矩阵
SW_A = zeros(size(time));
SW_B = zeros(size(time));
SW_C = zeros(size(time));

SW_A(1) = SW0_A;
SW_B(1) = SW0_B;
SW_C(1) = SW0_C;

% 欧拉法计算共享意愿动态
for i = 1:length(time)-1
    SW_A(i+1) = SW_A(i) + r_SW * SW_A(i) * (1 - SW_A(i)/X_max) * dt;
    SW_B(i+1) = SW_B(i) + r_SW * SW_B(i) * (1 - SW_B(i)/X_max) * dt;
    SW_C(i+1) = SW_C(i) + r_SW * SW_C(i) * (1 - SW_C(i)/X_max) * dt;
end

% 计算共享意愿变化率（差分近似）
dSW_A = diff(SW_A) / dt;
dSW_B = diff(SW_B) / dt;
dSW_C = diff(SW_C) / dt;
time_diff = time(1:end-1);  % 变化率对应时间点

% 绘制图6

% 共享意愿变化率随时间变化
subplot(2,1,1);
plot(time_diff, dSW_A, 'r-', 'LineWidth',1.5); hold on;
plot(time_diff, dSW_B, 'g--', 'LineWidth',1.5);
plot(time_diff, dSW_C, 'b-.', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('共享意愿变化率 (ΔSW/dt)');
title('不同初始条件下共享意愿变化率');
legend('方案一','方案二','方案三','Location','northeast');
grid on;

% 共享意愿随时间变化
subplot(2,1,2);
plot(time, SW_A, 'r-', 'LineWidth',1.5); hold on;
plot(time, SW_B, 'g--', 'LineWidth',1.5);
plot(time, SW_C, 'b-.', 'LineWidth',1.5);
xlabel('时间 (周)');
ylabel('共享意愿 (SW)');
title('不同初始条件下的共享意愿变化');
legend('方案一 (SW0=1)','方案二 (SW0=3)','方案三 (SW0=5)','Location','southeast');
grid on;