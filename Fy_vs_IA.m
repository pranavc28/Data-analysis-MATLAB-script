%Tire Analysis V1
%MER 20
%new

%% % Load data
% Use cornering test data.

close all;
clear all;
load('B1654run21.mat');

%% Set bounds on what pressures and angles to test
% For B1654run26, the schedule is as follows:
% pressure = [10 12 14];
% slip_ratio = 0;
% inclination_angles = [0 2 4];
% loads_lb = [200, 150, 250, 50];
% Slip ratio is swept +0.15 -> -0.15 -> +0.15
% No warmup
% Select which parameters to process below

%Change pressure or inclination angle to what you want it to be
pressures_psi = [10 12 14];
slip_ratio = 0;
inclination_angles = [0 2 4];
loads_lb = [200, 150, 250, 50];

% Don't edit below
% Conversion factors
loads_N = loads_lb.*4.45; % lbs to N
pressures_kpa = pressures_psi.*6.89476; % psi to kpa

% Bounds to use for extraction
% Sets sensitivity for extraction
pressure_s = 20; % kpa
inclination_angle_s = 1; %degrees
load_s = 60; % N

%% Extract and process the data
% Iterate through all the desired pressures, slip angles, cambers, and
% loads
for i = 1:length(pressures_kpa)
    for j = 1:length(slip_ratio)
        for k = 1:length(inclination_angles)
            for m = 1:length(loads_N)
                % Each logx varibale is a logical array that contains the
                % indices of where the data is in the overall array that
                % matches the search criteria, set in the above matrices
                % and the "sensitivities" defined above
                logp = (P > pressures_kpa(i)-pressure_s) & (P < pressures_kpa(i)+pressure_s);
                logsr = (SL == 0);
                logia = (IA > inclination_angles(k)-inclination_angle_s) & (IA < inclination_angles(k)+inclination_angle_s);
                logfz = (-FZ > loads_N(m)-load_s) & (-FZ < loads_N(m)+load_s);
                % The data is then put into multidimensional cell arrays
                % for organization. slip ratio and longitudinal and lateral
                % force are needed for the traction circle. The same
                % strategy can be applied to the other variables as well
                logall = (logp & logia & logfz & logsr);
                lat_force_data{i,j,k,m}(:,1) = FY(logall);
                lon_force_data{i,j,k,m}(:,1) = FX(logall);
                normal_force_data{i,j,k,m}(:,1) = FZ(logall);
                slip_angle_data{i,j,k,m}(:,1) = SA(logall);
                Mz_data{i,j,k,m}(:,1) = MZ(logall);
            end
        end
    end
end
%% Fy vs SA processing

desired_pressure = 12;
desired_IA  = 0;

% Set up a colors array for plotting
colors = ['r' 'g' 'b' 'k' 'm' 'c' 'y'];

% Value for smoothing
smooth_val = 5;

% Iterate through all loads, pressures, and IAs. 
% Inclination angles plotted on same plots
for m = 1:length(loads_N)
    figure(m);
    hold on;
    grid on;
    for i = 1:length(pressures_kpa)
        subplot(2,2,i);
        for k = 1:length(inclination_angles)
            for j = 1:length(slip_ratio)
                plot(smooth(slip_angle_data{i,j,k,m}(:,1),smooth_val),smooth(lat_force_data{i,j,k,m}(:,1),smooth_val), ['.' colors(k)], 'MarkerSize',8);
            end
        end
    % Format the plot
    xlabel('Slip Angle (Degrees)','FontSize',14);
    ylabel('Lateral Force (N)','FontSize',14);
    % char(176) is the Unicode degrees symbol
    leg(k) = legend(string(inclination_angles) + char(176) + ' inclination angle');
    leg(k).FontSize = 14;
    title('Lateral Force vs. Slip Angle at ' + string(round(loads_N(m))) + ' N Normal Load and ' + string(round(pressures_kpa(i))) + ' kPa Pressure','FontSize',14);
    % Make the axes square
    axis square;
    end
end