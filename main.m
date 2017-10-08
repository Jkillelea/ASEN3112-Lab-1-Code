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
    plot_title = 'solid bar';
  else % slotted bar
    phi = gamma .* L / t;
    b   = 2 * pi * R_avg;  % height of unrolled cross section (t is thickness)
    J   = (1/3) * b * t^3; % b/t = 34.558, so alpha = beta = 1/3
    plot_title = 'slotted bar';
  end

  % should be semi-constant
  GJ = torque .* L ./ phi;

  % theoretical gamma
  theory_gamma = (torque*Re) ./ (G*J);

  % make some plots
  figure; hold on;
  plot(phi, gamma);
  plot(phi, theory_gamma);
  title([plot_title, ', gamma']);
  xlabel('\phi');
  ylabel('\gamma, radians');
  legend('Actual Gamma', 'Predicted Gamma');

  figure; hold on;
  plot(phi, GJ);
  title([plot_title, ', GJ']);
  xlabel('\phi');
  ylabel('GJ');
end
