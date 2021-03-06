%% COORDINATION ASV-ASV
% simulation of two ASV vehicles working in cooperation
clear all;
close all;
clc;

%% Simulation Inputs
% time
sim.Ts   = 0.01;
sim.Tend = 120;
sim.time = 0:sim.Ts:sim.Tend;

% waypoints
ref1.pathType = 2;
ref1.start = [0;0];
ref1.finish = [20;0];
ref1.waypoints = ref_waypoints(ref1);

ref2.pathType = 2;
ref2.start = [2;0];
ref2.finish = [18;0];
ref2.waypoints = ref_waypoints(ref2);

% constant speed reference
ref1.uRefNominal = 1;
ref1.uRef = ref1.uRefNominal;
ref2.uRefNominal = 1;
ref2.uRef = ref2.uRefNominal;

%% Initialize Vehicles
% initial yaw value
yawInit = 90; 

% establish structure
ASV1 = ASV_variables(sim, ref1.start, yawInit, 1);
ASV2 = ASV_variables(sim, ref2.start, yawInit, 2);

ASV1.ref = ref1;
ASV2.ref = ref2;

vcorr = [0;0];

%% Simulation
i = 1;
for t = sim.time
    %% Display Progression
    displayProgress(ASV1);
    
    %% Coordination
    if ASV1.counter > 100
        [vcorr] = coordinationMaster(ASV1, ASV2);
        ref1.uRef = ref1.uRefNominal + vcorr(1);
        ref2.uRef = ref2.uRefNominal + vcorr(2);
    end
    
    %% Calculate References
    [ref1.yawRef, ASV1] = pathFollowerASV(ASV1, ref1);
    [ref2.yawRef, ASV2] = pathFollowerASV(ASV2, ref2);

    %% Simulate Vehicles
    % ASV 1
    [ASV1] = innerLoopASV(ref1, ASV1);
    [ASV2] = innerLoopASV(ref2, ASV2);
    
    vCorr_hist(:,i) = vcorr;
    i = i + 1; 
end

%% Plotting
% trajectory
plotTrajectory(ASV1, ASV2);
% coordination
plotCoordination(ASV1, ASV2);
% cross track error
plotCrossTrackError(ASV1, ASV2);
% correction velocities
plotVcorr(vCorr_hist, sim.time);