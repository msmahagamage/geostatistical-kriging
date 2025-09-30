% =========================================================================
% run_kriging_analysis.m
% 
% Main driver script for performing and evaluating Ordinary Kriging on
% wind data. This script is configurable and demonstrates a
% workflow for geostatistical analysis.
% =========================================================================
clear; clc; close all;

% --- 1. SETUP: Load Data ---
fprintf('Loading data...\n');
load('Wind_Morning.mat'); % Should contain a variable named 'wind'
load('Boundary.mat');     % Should contain a variable named 'boundary'

% --- 2. CONFIGURATION: Define All Analysis Parameters ---
fprintf('Configuring analysis...\n');

% Define training and testing data indices
trainIdx = 1:18;
testIdx = 19:22;
trainData.locations = wind(trainIdx, 1:2);
testData.locations = wind(testIdx, 1:2);

% Define the grid for spatial prediction
gridResolution = 30; % Create a 30x30 grid
minCoords = min(boundary);
maxCoords = max(boundary);
xGridVec = linspace(minCoords(1), maxCoords(1), gridResolution);
yGridVec = linspace(minCoords(2), maxCoords(2), gridResolution);
[XGrid, YGrid] = meshgrid(xGridVec, yGridVec);
predictionLocations = [XGrid(:), YGrid(:)];

% Remove prediction points outside the boundary
[in, ~] = inpolygon(predictionLocations(:,1), predictionLocations(:,2), boundary(:,1), boundary(:,2));
predictionLocations = predictionLocations(in, :);

% --- Define the different models and datasets to analyze ---
% This struct array makes it easy to add new analyses without duplicating code.
analyses = struct(...
    'name',           {'March Spherical', 'March Exponential', 'June Spherical', 'June Exponential', 'November Spherical', 'November Exponential', 'December Spherical', 'December Exponential'}, ...
    'dataColumn',     {3, 3, 4, 4, 5, 5, 6, 6}, ...
    'modelType',      {'spherical', 'exponential', 'spherical', 'exponential', 'spherical', 'exponential', 'spherical', 'exponential'}, ...
    'sill',           {5, 5, 20, 20, 4.5, 4.5, 6, 6}, ...
    'nugget',         {4, 4, 15, 15, 2, 2, 3.5, 3.5}, ...
    'range',          {2.0e5, 2.0e5, 2.0e5, 2.0e5, 2.0e5, 2.0e5, 2.0e5, 2.0e5} ...
);

results = table(); % Create a table to store the final RMSE values

% --- 3. EXECUTION: Loop Through and Run Each Analysis ---
for i = 1:length(analyses)
    currentAnalysis = analyses(i);
    fprintf('\n--- Running Analysis: %s ---\n', currentAnalysis.name);

    % Extract the correct data column for the current month
    trainData.values = wind(trainIdx, currentAnalysis.dataColumn);
    testData.values = wind(testIdx, currentAnalysis.dataColumn);

    % Package the variogram model parameters into a struct
    variogramModel.type = currentAnalysis.modelType;
    variogramModel.sill = currentAnalysis.sill;
    variogramModel.nugget = currentAnalysis.nugget;
    variogramModel.range = currentAnalysis.range;

    % Perform Kriging on the grid for visualization
    fprintf('Performing Kriging on prediction grid...\n');
    [predictedGridValues, predictionVariance] = performOrdinaryKriging( ...
        trainData.locations, trainData.values, predictionLocations, variogramModel);
    
    % Visualize the results
    plotKrigingResults(XGrid, YGrid, predictionLocations, predictedGridValues, predictionVariance, ...
        trainData.locations, trainData.values, currentAnalysis.name);

    % Perform cross-validation on the test data
    fprintf('Performing cross-validation...\n');
    [predictedTestValues, ~] = performOrdinaryKriging( ...
        trainData.locations, trainData.values, testData.locations, variogramModel);
    
    % Calculate and store RMSE
    squaredErrors = (predictedTestValues - testData.values).^2;
    rmse = sqrt(mean(squaredErrors));
    fprintf('RMSE for %s: %.4f\n', currentAnalysis.name, rmse);
    
    % Store result
    results.AnalysisName(i) = string(currentAnalysis.name);
    results.RMSE(i) = rmse;
end

% --- 4. FINAL REPORT: Display Comparison Table ---
fprintf('\n--- Analysis Complete ---\n');
disp('Cross-Validation Results:');
disp(results);