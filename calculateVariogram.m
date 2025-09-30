function expVariogram = calculateVariogram(locations, values, options)
%calculateVariogram Computes the experimental variogram for a dataset.
%
%   INPUTS:
%   locations   - (N x 2) matrix of data coordinates [X, Y].
%   values      - (N x 1) vector of values at those locations.
%   options     - Struct with optional fields: .maxLag, .numBins.
%
%   OUTPUT:
%   expVariogram - A table with columns: LagDistance, Semivariance, PairCount.

if nargin < 3, options = struct(); end
if ~isfield(options, 'numBins'), options.numBins = 15; end

% Calculate all pairwise distances and squared differences
pairwiseDists = pdist(locations);
pairwiseSqDiffs = pdist(values(:)).^2;

if ~isfield(options, 'maxLag'), options.maxLag = max(pairwiseDists) / 2; end

% Create the distance bins for the variogram
lagEdges = linspace(0, options.maxLag, options.numBins + 1);
lagCenters = lagEdges(1:end-1) + (lagEdges(2)-lagEdges(1))/2;

% Use discretize to assign each pair to a lag bin
[~, ~, lagBinIdx] = histcounts(pairwiseDists, lagEdges);

% Use accumarray to efficiently calculate sums and counts for each bin
semivariance = accumarray(lagBinIdx', pairwiseSqDiffs', [], @mean) / 2;
pairCount = accumarray(lagBinIdx', 1);

% Create a results table
expVariogram = table(lagCenters', semivariance(1:options.numBins), pairCount(1:options.numBins), ...
    'VariableNames', {'LagDistance', 'Semivariance', 'PairCount'});
end