function plotKrigingResults(XGrid, YGrid, predLocs, predVals, predVar, knownLocs, knownVals, titleStr)
%plotKrigingResults Creates a standardized 2x2 plot for Kriging results.

% --- Reshape gridded data ---
% Create a full grid of NaNs
Z_pred = nan(size(XGrid));
Z_var = nan(size(XGrid));

% Use a logical index to place the predicted values in the correct grid spots
[~, locb] = ismember(predLocs, [XGrid(:), YGrid(:)], 'rows');
Z_pred(locb) = predVals;
Z_var(locb) = predVar;

% --- Create the Figure ---
figure('Name', titleStr);

% Plot 1: Predicted Surface
subplot(2, 2, 1);
surf(XGrid, YGrid, Z_pred, 'EdgeColor', 'none');
hold on;
stem3(knownLocs(:,1), knownLocs(:,2), knownVals, 'k.', 'MarkerSize', 15);
hold off;
title('Predicted Surface with Data Points');
xlabel('X Coordinate'); ylabel('Y Coordinate'); zlabel('Value');
view(3); grid on;

% Plot 2: Prediction Variance Surface
subplot(2, 2, 2);
surf(XGrid, YGrid, Z_var, 'EdgeColor', 'none');
title('Prediction Variance');
xlabel('X Coordinate'); ylabel('Y Coordinate'); zlabel('Variance');
view(3); grid on;

% Plot 3: Predicted Contour
subplot(2, 2, 3);
contourf(XGrid, YGrid, Z_pred);
hold on;
plot(knownLocs(:,1), knownLocs(:,2), 'k.', 'MarkerSize', 15);
hold off;
title('Predicted Contour Map');
xlabel('X Coordinate'); ylabel('Y Coordinate');
axis equal;
colorbar;

% Plot 4: Variance Contour
subplot(2, 2, 4);
contourf(XGrid, YGrid, Z_var);
hold on;
plot(knownLocs(:,1), knownLocs(:,2), 'k.', 'MarkerSize', 15);
hold off;
title('Variance Contour Map');
xlabel('X Coordinate'); ylabel('Y Coordinate');
axis equal;
colorbar;
end