% 1. FÁZIS: Paraméterek megadása

p = 5;                  % Joglekar ablakfüggvény kitevője
%ez nem lett felhasználva


Ron = 100;              % Bekapcsolt ellenállás (Ohm)
Roff = 160*Ron;         % Kikapcsolt ellenállás (16000 Ohm)
mu = 1e-14;             % Ion mobilitás
D = 10e-9;              % Eszköz vastagsága
xmin = 0.05;            % Minimális állapotváltozó érték
xmax = 0.9999;          % Maximális állapotváltozó érték
k = mu * Ron / (D^2);   % Drift állandó
x0 = 0.2;               % Kezdeti állapot (x = w/D)




% Szimuláció hossza és lépésköze
%T = 3 / f;                 % Teljes szimulációs idő másodpercben (3 teljes hullám)
T = 6;
N = 10000;              % Minták száma
deltat = T / N;         % Egy időlépés hossza
t = linspace(0, T, N);  % Idővektor létrehozása

% Gerjesztő feszültség (Soft-switching: 0.5 Hz, 0.7 V amplitúdó)
f =0.5;
u_m = 0.7;
u = u_m * sin(2 * pi * f * t); % Bemeneti feszültség (u(t))

% Vektorok előkészítése a memóriában (gyorsabb futás)
x = zeros(1, N);        % Állapotváltozó vektora
i = zeros(1, N);        % Áram vektora
psi = zeros(1, N);      % Fluxus vektora

% 2. FÁZIS: Kezdeti állapot beállítása
x(1) = x0;
psi(1) = 0;
% i = u / R_eq, ahol R_eq = Ron*x + Roff*(1-x)
i(1) = u(1) / (Ron * x(1) + Roff * (1 - x(1))); 

% 3. FÁZIS: A fő algoritmus ciklusa
for n = 2:N
    % Fluxus számítása futó integrállal
    psi(n) = psi(n-1) + u(n) * deltat;
    
    % A nemlineáris Joglekar ablakfüggvény - nem lett implementálva!
    %window = 1 - (2 * x(n-1) - 1)^(2 * p);
    window = 1;
    
    % Változás kiszámítása
    % A képlet: dx = dt * u * (1/(1-x)) * (k/Roff) * window
    dx = deltat * u(n-1) * (1 / (1 - x(n-1))) * (k / Roff) * window;
    
    % A következő állapot ideiglenes értéke
    x_next = x(n-1) + dx;
    
    % Hard-switching feltételek a határokhoz
    if (x_next <= xmin) && (u(n) <= 0)
        x(n) = xmin;
    elseif (x_next >= xmax) && (u(n) >= 0)
        x(n) = xmax;
    else
        x(n) = x_next;
    end
    
    % Az áram kiszámítása a már rögzített új állapothoz
    i(n) = u(n) / (Ron * x(n) + Roff * (1 - x(n)));
end

% A töltés (q) kiszámítása az áram (i) numerikus integrálásával (kumulatív összegzéssel)
q = zeros(1, N);
for k = 2:N
    q(k) = q(k-1) + i(k) * deltat;
end

% Új grafikon ablak a fundamentális kapcsolat igazolására
%figure;



% 4. FÁZIS: Grafikonok kirajzolása
figure('Position', [100, 100, 800, 600]);

% 1. panel: Feszültség és Áram időfüggvénye
subplot(2, 2, [1, 2]); 
plot(t, u, 'b', 'LineWidth', 1.5); hold on;
plot(t, i * 1e3, 'g', 'LineWidth', 1.5);
xlabel('Idő (s)');
ylabel('Amplitúdó');
legend('Feszültség [V]', 'Áram [mA]');
title('A gerjesztés és a válasz időben');
grid on;


subplot(2, 2, [3, 4]); 
plot(t, x, 'r', 'LineWidth', 1.5);
xlabel('Idő (s)');
ylabel('x');
%legend('Feszültség [V]', 'Áram [mA]');
title('A rendszerváltozó időben');
grid on;


figure;
% 2. panel: Feszültség-Áram hiszterézis
subplot(2, 2, 3);
plot(u, i * 1e3, 'k', 'LineWidth', 1.5);
xlabel('Feszültség (V)');
ylabel('Áram (mA)');
title('i-v Hiszterézis Hurok');
grid on;

% 3. panel: Állapotváltozó a fluxus függvényében
subplot(2, 2, 4);
plot( psi, q, 'm', 'LineWidth', 2);
ylabel('Töltés, q [C]');
xlabel('Fluxus, \psi [Wb]');
title('Fundamentális \phi-q kapcsolat');
grid on;