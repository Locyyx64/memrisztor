p = 5;          	% Ablakfuggveny fokszam (nem hasznalt) 
Ron = 100;              % Bekapcsolt ellenallas (Ohm)
Roff = 160*Ron;         % Kikapcsolt ellenallas (16000 Ohm)
mu = 1e-14;             % Ion mobilitas
D = 10e-9;              % Eszkoz vastagsaga
xmin = 0.05;            % Minimalis allapotvaltozo ertek
xmax = 0.9999;          % Maximalis allapotvaltozo ertek
k = mu * Ron / (D^2);   % Drift allando
x0 = 0.2;               % Kezdeti allapot (x = w/D)

%T = 3 / f;             % Teljes szimulacio (3 teljes hullam)
T = 6;
N = 10000;              % Mintak szama
deltat = T / N;         % Egy idolepes hossza
t = linspace(0, T, N);  % Idovektor letrehozasa

f =0.5;
u_m = 0.7;
u = u_m * sin(2 * pi * f * t); % Bemeneti feszultseg (u(t))

x = zeros(1, N);        % Allapotvaltozo vektora
i = zeros(1, N);        % Aram vektora
psi = zeros(1, N);      % Fluxus vektora

x(1) = x0;
psi(1) = 0;
% i = u / R_eq, ahol R_eq = Ron*x + Roff*(1-x)
i(1) = u(1) / (Ron * x(1) + Roff * (1 - x(1))); 

for n = 2:N
    psi(n) = psi(n-1) + u(n) * deltat;
    
    %window = 1 - (2 * x(n-1) - 1)^(2 * p);
    window = 1;
    
    dx = deltat*u(n-1)*(1/(1 - x(n-1)))*(k/Roff)*window;    
    x_next = x(n-1) + dx;
    
    if (x_next <= xmin) && (u(n) <= 0)
        x(n) = xmin;
    elseif (x_next >= xmax) && (u(n) >= 0)
        x(n) = xmax;
    else
        x(n) = x_next;
    end
    
    i(n) = u(n) / (Ron * x(n) + Roff * (1 - x(n)));
end

q = zeros(1, N);
for k = 2:N
    q(k) = q(k-1) + i(k) * deltat;
end

figure('Position', [100, 100, 800, 600]);

subplot(2, 2, [1, 2]); 
plot(t, u, 'b', 'LineWidth', 1.5); hold on;
plot(t, i * 1e3, 'g', 'LineWidth', 1.5);
xlabel('Ido (s)');
ylabel('Amplitudo');
title('A gerjesztes es a valasz idoben');
grid on;

subplot(2, 2, [3, 4]); 
plot(t, x, 'r', 'LineWidth', 1.5);
xlabel('Ido (s)');
ylabel('x');
legend('Feszultseg [V]', 'Aram [mA]');
title('A rendszervaltozo idoben');
grid on;

figure;
subplot(2, 2, 3);
plot(u, i * 1e3, 'k', 'LineWidth', 1.5);
xlabel('Feszultseg (V)');
ylabel('Aram (mA)');
title('i-v Hiszterezis Hurok');
grid on;

subplot(2, 2, 4);
plot( psi, q, 'm', 'LineWidth', 2);
ylabel('Toltes, q [C]');
xlabel('Fluxus, \psi [Wb]');
title('Fundamentalis \phi-q kapcsolat');
grid on;
