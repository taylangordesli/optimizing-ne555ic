% Parameters
Vin = 5; % Input voltage (volt)
V_LED = 2; % LED forward voltage drop (volt)
R_LED = 330; % LED resistance (ohm)
f_target = 1; % Target blink frequency (Hz)

% Constraint functions
nonlcon = @(x) constraints(x, Vin, V_LED, R_LED, f_target);

% Generate a range of R1, R2, and C values
R1_values = logspace(0, log10(5000), 100); % Upper limit for R1 is 5k ohm
R2_values = logspace(0, log10(7000), 100); % Upper limit for R2 is 7k ohm
C_values = logspace(-8, -2, 100); % Upper limit for C is 10mF

% Initialize matrices for storing results
Z = zeros(length(R1_values), length(R2_values));

% Calculate blink frequency for each combination of R1, R2, and C values
for i = 1:length(R1_values)
    for j = 1:length(R2_values)
        Z(i, j) = blink_frequency(R1_values(i), R2_values(j), C_values(1), Vin, V_LED, R_LED);
    end
end

% Find optimal R1, R2, and C values to achieve the target frequency
options = optimset('Display', 'off');
[x_optimal, ~] = fmincon(@(x) objective(x), [1000, 1000, C_values(1)], [], [], [], [], [1, 1, 1e-8], [5000, 7000, 1e-2], nonlcon, options);
R1_optimal = x_optimal(1);
R2_optimal = x_optimal(2);
C_optimal = x_optimal(3);

% Displaying the optimal values
fprintf('Optimal R1 Value: %.2f Ohm\n', R1_optimal);
fprintf('Optimal R2 Value: %.2f Ohm\n', R2_optimal);
fprintf('Optimal C Value: %.2e Farad\n', C_optimal);
fprintf('Optimal Blink Frequency: %.2f Hz\n', f_target);

% Generate 3D plot
figure;
surf(R1_values, R2_values, Z);
xlabel('R1 Value (Ohm)');
ylabel('R2 Value (Ohm)');
zlabel('Capacitor Value (Farad)');
title('3D Plot of R1, R2, and Capacitor for 1 Hz Output');

function [c, ceq] = constraints(x, Vin, V_LED, R_LED, f_target)
    % Nonlinear inequality constraints
    c = [];
    
    % Nonlinear equality constraints
    ceq = blink_frequency(x(1), x(2), x(3), Vin, V_LED, R_LED) - f_target;
end

function f = objective(x)
    % Objective function (set to 0, as the goal is to meet the target frequency)
    f = 0;
end

function f = blink_frequency(R1, R2, C, Vin, V_LED, R_LED)
    % Calculate blink frequency for NE555 IC LED blinker circuit
    t_high = 0.693 * (R1 + R2) * C;
    t_low = 0.693 * R2 * C;
    
    f = 1 / (t_high + t_low);
end
