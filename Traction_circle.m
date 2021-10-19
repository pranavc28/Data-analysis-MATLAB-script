%Tire Analysis V1  - ONE OF THE TIRES SCRIPT I CREATED FOR ANALYSIS AND DECISION
%MAKING FOR THE 2020 RACECAR.
%MER 20

%% % Load data
% Use Drive/Brake test data.

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

pressures_psi = [10 12 14];
slip_angles = [0 -3 -6];
inclination_angles = [0 2 4];
loads_lb = [200, 150, 250, 50];

% Don't edit below
% Conversion factors
loads_N = loads_lb.*4.45; % lbs to N
pressures_kpa = pressures_psi.*6.89476; % psi to kpa

% Bounds to use for extraction
% Sets sensitivity for extraction
pressure_s = 20; % kpa
slip_angle_s = 1; %degrees
inclination_angle_s = 1; %degrees
load_s = 60; % N

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
                logsa = (SA > slip_angles(j)-slip_angle_s) & (SA < slip_angles(j)+slip_angle_s);
                logia = (IA > inclination_angles(k)-inclination_angle_s) & (IA < inclination_angles(k)+inclination_angle_s);
                logfz = (-FZ > loads_N(m)-load_s) & (-FZ < loads_N(m)+load_s);
                % The data is then put into multidimensional cell arrays
                % for organization. slip ratio and longitudinal and lateral
                % force are needed for the traction circle. The same
                % strategy can be applied to the other variables as well
                logall = (logp & logsa & logia & logfz);
                slip_ratio_data{i,j,k,m}(:,1) = SL(logall);
                lat_force_data{i,j,k,m}(:,1) = FY(logall);
                lon_force_data{i,j,k,m}(:,1) = FX(logall);
                normal_force_data{i,j,k,m}(:,1) = FZ(logall);
                normalized_lat_force_data{i,j,k,m}(:,1) = lat_force_data{i,j,k,m}(:,1)./normal_force_data{i,j,k,m}(:,1);
                normalized_lon_force_data{i,j,k,m}(:,1) = lon_force_data{i,j,k,m}(:,1)./normal_force_data{i,j,k,m}(:,1);
            end
        end
    end
end

%% Plot the traction circle

% Constant pressure, IA plots
% Can make this an array if desired. Just works with scalars for now
desired_pressure = 12;
desired_IA  = 0;

% Set up a colors array for plotting
colors = ['r' 'g' 'b' 'k' 'm' 'c' 'y'];

% Value for smoothing
smooth_val = 5;

% Iterate through all loads, pressures, and IAs. 
% Slip angles plotted on same plot
% Normal loads plotted on separate plots
for m = 1:length(loads_N)
    figure(m);
    hold on;
    grid on;
    for i = 1:length(desired_pressure)
        for j = 1:length(slip_angles)
            for k = 1:length(desired_IA)
                % Plot the right hand side of the circle and then negate
                % lateral force for the left hand side
                plot(smooth(lat_force_data{i,j,k,m}(:,1),smooth_val),smooth(lon_force_data{i,j,k,m}(:,1),smooth_val) ,['.' colors(j)],'MarkerSize',8);
                plot(-smooth(lat_force_data{i,j,k,m}(:,1),smooth_val),smooth(lon_force_data{i,j,k,m}(:,1),smooth_val) ,['.' colors(j)],'MarkerSize',8);
                % Use circleFitByPratt from MATLAB File Exchange to fit a
                % traction circle to the data for the higher slip angles
%                 if(-slip_angles(j) > 0)
%                     traction_circle_data{m,i,j,k}(1,:) = CircleFitByPratt([lat_force_data{i,j,k,m}(:,1) sort(lon_force_data{i,j,k,m}(:,1),'ascend')]);
%                     [x y r] =  traction_circle_data{m,i,j,k}(1,:);
%                     % Matlab doesn't have a circle drawing tool so you can
%                     % use rectangle with rounded edges
%                     rectangle('Position',[x-r y-r 2.*r 2.*r],'Curvature',[1 1],EdgeColor',colors(j));
%                 end
            end
        end
    end
    % Format the plot
    xlabel('Lateral Force (N)','FontSize',14);
    ylabel('Longitudinal Force (N)','FontSize',14);
    % char(176) is the Unicode degrees symbol
    leg(m) = legend(string(slip_angles) + char(176) + ' Slip Angle');
    leg(m).FontSize = 14;
    title('Traction Circle (Longitudinal vs. Lateral Force) at ' + string(round(loads_N(m))) + ' N Normal Load','FontSize',14);
    % Make the axes square
    axis square;
end