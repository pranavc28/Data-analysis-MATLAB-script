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
inclination_angles = 0;
loads_lb = 250;

% Don't edit below
% Conversion factors
loads_N = loads_lb.*4.45; % lbs to N
pressures_kpa = pressures_psi.*6.89476; % psi to kpa

% Bounds to use for extraction
% Sets sensitivity for extraction
pressure_s = 20; % kpa
slip_angle_s = 1; %degrees
inclination_angle_s = 1; %degrees
load_s = 10; % N

%% Extract and process the data

                % Each logx varibale is a logical array that contains the
                % indices of where the data is in the overall array that
                % matches the search criteria, set in the above matrices
                % and the "sensitivities" defined above
                logp = (P > pressures_kpa-pressure_s) & (P < pressures_kpa+pressure_s);
                logsa = (SA > slip_angles-slip_angle_s) & (SA < slip_angles+slip_angle_s);
                logia = (IA > inclination_angles-inclination_angle_s) & (IA < inclination_angles+inclination_angle_s);
                logfz = (-FZ > loads_N-load_s) & (-FZ < loads_N+load_s);
                % The data is then put into multidimensional cell arrays
                % for organization. slip ratio and longitudinal and lateral
                % force are needed for the traction circle. The same
                % strategy can be applied to the other variables as well
                logall = (logp & logia & logfz & logsa);
                slip_ratio_data_vector = SL(logall);
                lon_force_data_vector = FX(logall);
                slip_ratio_data = SL(logall);
                lat_force_data = FY(logall);
                lon_force_data = FX(logall);
                normal_force_data = FZ(logall);
                slip_angle_data = SA(logall);

%% Fy vs SA processing

%Create average force. Use the lon data in the processing section, with a
%concolution function to get a moving average window. Use ones, divided by
%50 cause the window is 50.

average_lon = conv(lon_force_data, ones(1,50)./50,'valid');
average_slip = conv(slip_angle_data, ones(1,50)./50,'valid');

%Get max of the new average lon, which filtered noise
[val,idx] = max(average_lon);
slip_ratio_at_max = slip_ratio_data_vector([idx]);

