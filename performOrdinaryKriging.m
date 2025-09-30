function [predictedValues, predictionVariance] = performOrdinaryKriging(knownLocations, knownValues, predictionLocations, variogramModel)
%performOrdinaryKriging Performs Ordinary Kriging interpolation.
%
%   INPUTS:
%   knownLocations      - (N x 2) matrix of known data coordinates [X, Y].
%   knownValues         - (N x 1) vector of values at known locations.
%   predictionLocations - (M x 2) matrix of locations to predict [X, Y].
%   variogramModel      - Struct with fields: .type, .sill, .nugget, .range.
%
%   OUTPUTS:
%   predictedValues     - (M x 1) vector of predicted values.
%   predictionVariance  - (M x 1) vector of the Kriging variance.

% --- 1. Calculate Covariance Matrix for Known Locations ---
numKnown = size(knownLocations, 1);
distMatrix = pdist2(knownLocations, knownLocations);

% Calculate covariance matrix C based on the variogram model
C = calculateCovariance(distMatrix, variogramModel);

% Set up the Kriging system matrix A
A = [C, ones(numKnown, 1); ones(1, numKnown), 0];

% --- 2. Calculate Covariance Vector for Prediction Locations ---
numPred = size(predictionLocations, 1);
distVecs = pdist2(knownLocations, predictionLocations);
k = calculateCovariance(distVecs, variogramModel);

% Set up the right-hand side matrix b
b = [k; ones(1, numPred)];

% --- 3. Solve the Kriging System ---
% The weights (lambda) are found by solving A * lambda = b -> lambda = A \ b
weights = A \ b;

% --- 4. Calculate Predicted Values ---
% Predicted value is a weighted sum of known values
predictedValues = weights(1:numKnown, :)' * knownValues;

% --- 5. Calculate Prediction Variance ---
% Variance = Sill - (weights' * b)
predictionVariance = variogramModel.sill - sum(weights .* b, 1)';
end


function C = calculateCovariance(D, model)
% Helper function to calculate covariance from a distance matrix/vector
    sill = model.sill;
    nugget = model.nugget;
    range = model.range;
    
    % Covariance = Sill - Semivariance
    semivariance = zeros(size(D));
    
    switch lower(model.type)
        case 'spherical'
            idx = D > 0 & D <= range;
            semivariance(idx) = nugget + (sill - nugget) * ...
                (1.5 * (D(idx) / range) - 0.5 * (D(idx) / range).^3);
            semivariance(D > range) = sill;
            semivariance(D == 0) = 0; % At zero distance, semivariance is 0 by definition
        case 'exponential'
            idx = D > 0;
            semivariance(idx) = nugget + (sill - nugget) * ...
                (1 - exp(-3 * D(idx) / range));
            semivariance(D == 0) = 0;
        otherwise
            error('Unknown variogram model type. Use "spherical" or "exponential".');
    end
    C = sill - semivariance;
end