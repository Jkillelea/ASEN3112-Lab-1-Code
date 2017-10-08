clear; clc; close all;

%% constants %%
Re = 3/8;              % external radius    | inches
t  = 1/16;             % thickness          | inches
L  = 1;                % exensometer length | inches
G  = 3.75 * 10^6;      % shear modulus      | psi
Ri = Re - t;           % inner radius       | inches
R_avg = 0.5*(Re + Ri); % average radius     | inches

% grab filenames
files = dir('data/*.csv');

for i = 1:length(files)
  fname = files(i).name;

  % load data
  data   = csvread(strcat('data/', fname), 3, 0);
  gamma  = deg2rad(data(:, 2));
  torque = data(:, 4);

  % calculation for phi differs between the two tests
  if strcmp(fname, '400inlb-solid.csv') % solid bar
    phi = gamma .* L / Re;
    J   = 0.5 * pi * (Re^4 - Ri^4);
    theory_gamma = (torque*Re) ./ (G*J); % theoretical gamma
    plot_title = 'Solid Bar';
  else % slotted bar
    phi = gamma .* L / t;
    b   = 2 * pi * R_avg;  % height of unrolled cross section (t is thickness)
    J   = (1/3) * b * t^3; % b/t = 34.558, so alpha = beta = 1/3
    theory_gamma = (torque*t) ./ (G*J); % theoretical gamma
    plot_title = 'Slotted Bar';
  end

  % should be semi-constant
  GJ = torque .* L ./ phi;
  theory_GJ = G * J;



  % print stuff out
  disp(['=====', fname, '===='])
  disp('Torque & Predicted $\gamma$ & Actual $\gamma$ & Predicted GJ & Actual GJ')
  for i = 10:round(length(torque)/5):length(torque)
    fprintf('%f & %f & %f & %f & %f \\hline \n', ...
            torque(i), ...
            theory_gamma(i), ...
            gamma(i), ...
            theory_GJ, ...
            GJ(i) ...
    );
  end

  % make some plots
  lw = 2; % line width
  figure; hold on;
  plot(torque, gamma*10^6, 'LineWidth', lw);
  plot(torque, theory_gamma*10^6, 'LineWidth', lw);
  title([plot_title, ', \gamma']);
  xlabel('Torque (lb*in)');
  ylabel('\gamma, micro radians');
  legend('Actual Gamma', 'Predicted Gamma');
  xlim([min(torque), max(torque)]);
  print([fname, '-gamma'], '-dpng');

  figure; hold on;
  plot(torque, GJ, 'LineWidth', lw);
  plot([min(torque), max(torque)], [theory_GJ, theory_GJ], 'LineWidth', lw);
  title([plot_title, ', GJ']);
  xlabel('Torque (lb*in)');
  ylabel('GJ');
  legend('Actual GJ', 'Predicted GJ');
  xlim([min(torque), max(torque)]);
  print([fname, '-gj'], '-dpng');
end
