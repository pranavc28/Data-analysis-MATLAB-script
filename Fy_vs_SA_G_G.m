%Tire Analysis V1
%MER 20
%new

%% % Load data
% Use cornering test data for Fy vs SA (SL=0 in this data)

close all;
clear all;
load('B1464run20.mat');

% Above data is 18x6.0 10 R25B

%% Set bounds on what pressures and angles to test
% For B1654run26, the schedule is as follows:
% pressure = [10 12 14];
% slip_ratio = 0;
% inclination_angles = [0 2 4];
% loads_lb = [200, 150, 250, 50];
% Slip ratio is swept +0.15 -> -0.15 -> +0.15
% No warmup
% Select which parameters to process below

trim = find(ET > 515);
ET = ET(trim:end);
SA = SA(trim:end);
FY = FY(trim:end);
FZ = FZ(trim:end);
IA = IA(trim:end);
P = P(trim:end);

pressures_psi = 12;
inclination_angles = 0;

% Don't edit below
% Conversion factors
pressures_kpa = pressures_psi.*6.89476; % psi to kpa

% Bounds to use for extraction
% Sets sensitivity for extraction
pressure_s = 15; % kpa
inclination_angle_s = 0.5; %degrees


%% Extract and process the data

                % Each logx varibale is a logical array that contains the
                % indices of where the data is in the overall array that
                % matches the search criteria, set in the above matrices
                % and the "sensitivities" defined above
                logp = (P > pressures_kpa-pressure_s) & (P < pressures_kpa+pressure_s);
                logia = (IA > inclination_angles-inclination_angle_s) & (IA < inclination_angles+inclination_angle_s);
 
                % Note in this example we use SL for slip ratio since this data states in the contents that at SL=O, FX=0.            
                % Simple scim of the data shows that SL=O at all times.
                
                logall = (logp & logia);
                slip_ratio_data_vector = SL(logall);
                lon_force_data_vector = FX(logall);
                slip_ratio_data = SL(logall);
                lat_force_data = FY(logall);
                lon_force_data = FX(logall);
                normal_force_data = FZ(logall);
                slip_angle_data = SA(logall);
                
%% Fy vs SA processing for convolution graph (G_G)

%%For this plot add a constant load variable

%Create average force. Use the lon data in the processing section, with a
% %concolution function to get a moving average window. Use ones, divided by
% %50 cause the window is 50.
% average_lat = conv(lat_force_data', ones(1,50)./50,'valid');
% 
% %Get max of the new average lon, which filtered noise
% [val,idx] = max(average_lat);
% slip_angle_at_max = slip_angle_data([idx]);

%% Fy vs SA for 2D lookup table

    slip_angle_data = SA(logall);
    [slip_angle_data_sorted, indices] = sort(slip_angle_data);

    normal_force_data = FZ(logall);
    normal_force_data_sorted = normal_force_data(indices);
    
    lat_force_data = FY(logall);
    lat_force_data_sorted = lat_force_data(indices);
    

