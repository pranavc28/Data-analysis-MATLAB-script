%Tire Analysis V1
%MER 20


%% % Load data
% Use Drive/Brake Test data

close all;
clear all;
load('B1464run40.mat');

%% Set bounds on what pressures and angles to test
% For B1654run35, the schedule is as follows:
% pressure = [10 12 14];
% slip_angles = [0 -3 -6];
% inclination_angles = [0 2 4];
% loads_lb = [200, 150, 250, 50];
% Slip ratio is swept +0.15 -> -0.15 -> +0.15
% No warmup
% Select which parameters to process below

pressures_psi = 12;
slip_angles = 0;
inclination_angles = [0 2 4];
loads_lb = [200, 150, 250, 50];

% Don't edit below
% Conversion factors
loads_N = loads_lb.*4.45; % lbs to N
pressures_kpa = pressures_psi.*6.89476; % psi to kpa

% Bounds to use for extraction
% Sets sensitivity for extraction
pressure_s = 2; % kpa
slip_angle_s = 0.2; %degrees
inclination_angle_s = 0.5; %degrees
load_s = 30; % N

%% Extract and process the data

% Iterate through all the desired pressures, slip angles, cambers, and
% loads
for i = 1:length(pressures_kpa)
    for j = 1:length(slip_angles)
        for k = 1:length(inclination_angles)
            for m = 1:length(loads_N)
                % Each logx varibale is a logical array that contains the
                % indices of where the data is in the overall array that
                % matches the search criteria, set in the above matrices
                % and the "sensitivities" defined above
                logp = (P > pressures_kpa(i)-pressure_s) & (P < pressures_kpa(i)+pressure_s);
                logsa = (SA > slip_angles-slip_angle_s) & (SA < slip_angles+slip_angle_s);
                logia = (IA > inclination_angles(k)-inclination_angle_s) & (IA < inclination_angles(k)+inclination_angle_s);
                logfz = (-FZ > loads_N(m)-load_s) & (-FZ < loads_N(m)+load_s);
                % The data is then put into multidimensional cell arrays
                % for organization. slip ratio and longitudinal and lateral
                % force are needed for the traction circle. The same
                % strategy can be applied to the other variables as well
                logall = (logp & logia & logfz & logsa);
                slip_ratio_data_vector = SL(logall);
                lon_force_data_vector = FX(logall);
                slip_ratio_data{i,j,k,m}(:,1) = SL(logall);
                lat_force_data{i,j,k,m}(:,1) = FY(logall);
                lon_force_data{i,j,k,m}(:,1) = FX(logall);
                normal_force_data{i,j,k,m}(:,1) = FZ(logall);
                slip_angle_data{i,j,k,m}(:,1) = SA(logall);
                ia_data{i,j,k,m}(:,1) = IA(logall);
            end
        end
    end
end
%% Fx vs SR processing

desired_pressure = 12;
desired_IA  = 0;

% Set up a colors array for plotting
colors = ['r' 'g' 'b' 'k' 'm' 'c' 'y'];

% Value for smoothing
smooth_val = 5;

% Iterate through all loads, pressures, and IAs. 
% Normal loads plotted on same plots
for j = 1:(length(slip_angles))
    figure;
    hold on;
    grid on;
    for i = 1:length(desired_pressure)
        for m = 1:length(loads_N)
            for k = 1:length(inclination_angles)
                plot(smooth(ia_data{i,j,k,m}(:,1),smooth_val),smooth(lon_force_data{i,j,k,m}(:,1),smooth_val), ['.' colors(m)], 'MarkerSize',8);
            end
        end
    end
    % Format the plot
    xlabel('Inclination Angle','FontSize',14);
    ylabel('Longitudinal Force (N)','FontSize',14);
    % char(176) is the Unicode degrees symbol
    leg(m) = legend(string(loads_N) + ' N' + ' Load');
    leg(m).FontSize = 14;
    title('Longitudinal Force vs. Inclination Angle at Different IA''s','FontSize',14);
    % Make the axes square
    axis square;
end