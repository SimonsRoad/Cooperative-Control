%% Testing ASV Path Following (Lawnmower)
% The simulation can be varied using the Simulation Inputs, then the
% simulation is run by looping over time and using the path following
% controllers. 
% The file will also display plots of trajectory, internal
% command history, cross track error, and coordination states.

clear all;
close all;
clc;

complete = 1;

%% Simulation Inputs
% time
sim.Ts   = 0.01;
sim.Tend = 375;
sim.time = 0:sim.Ts:sim.Tend;

% waypoints
length_line = 25;
diameter_arc = 15;
segments = 5;

[wayPoints, ref] = waypointsLawnmower(length_line, diameter_arc, segments);

% constant speed reference
ref.uRef = 1;
ref.uRefNominal = 0.99;
ref.waypoints = wayPoints;

% initial yaw value
yawInit = 90; 

%% Initialize Vehicles
% establish structure
ASV1 = ASV_variables(sim, ref.start, yawInit, 1);
ASV1.ref = ref;

%% Simulation
for t = sim.time    
    %% Calculate References
    [ref.yawRef, ASV1] = pathFollowerASV(ASV1, ref);
    
    %% Update Reference, lawnmower
    if ASV1.gamma >= 1
        [ref, ASV1] = componentPath(ASV1, wayPoints, ref);
    end

    %% Simulate Vehicles
    % ASV 1
    [ASV1] = innerLoopASV(ref, ASV1);

    displayProgress(ASV1);
end
clc
disp('Finishing Up...');

%% Plotting
plotTrajectory(ASV1);
plotCoordination(ASV1);
plotCrossTrackError(ASV1);

clc
beep