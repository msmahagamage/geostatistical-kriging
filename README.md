# geostatistical-kriging

# MATLAB Toolkit for Geostatistical Kriging Analysis

This project provides a modular and vectorized toolkit for performing 2D geostatistical analysis and interpolation using Ordinary Kriging in MATLAB. The workflow is designed for academic purposes, demonstrating an approach to spatial data analysis, cross-validation, and visualization.



---

##  Features

- **Modular Design:** The code is separated into a main driver script and reusable functions for the core logic (Kriging, variogram) and visualization.
- **Configurable Analysis:** The main script uses a configuration structure, making it easy to run and compare multiple analyses (e.g., different months, different variogram models) without duplicating code.
- **Cross-Validation:** Includes a clear workflow for splitting data into training and testing sets to calculate Root Mean Square Error (RMSE) for model validation.
- **Comprehensive Visualization:** Automatically generates a 2x2 plot for each analysis, showing the predicted surface, prediction variance, and contour maps.

---

##  Geostatistical Workflow

The toolkit follows a standard geostatistical workflow:

1.  **Data Loading:** Loads spatial data points (X, Y, Z) and a boundary shapefile.
2.  **Configuration:** The user defines all parameters in a single, clear section in the main script. This includes training/testing data splits and the theoretical variogram models (sill, nugget, range) for each analysis.
3.  **Kriging Interpolation:** The `performOrdinaryKriging.m` function is called to predict values across a grid within the specified boundary.
4.  **Visualization:** The `plotKrigingResults.m` function generates professional-quality plots of the results.
5.  **Validation:** The script calculates the RMSE for each model by comparing predicted values against a known set of test points.
6.  **Reporting:** A final summary table of RMSE values is displayed for easy model comparison.

---

##  Requirements

- MATLAB (R2020a or newer is recommended)
- Statistics and Machine Learning Toolbox (for `pdist2`)

---

##  How to Use

1.  Place all the M-files (`run_kriging_analysis.m`, `performOrdinaryKriging.m`, `calculateVariogram.m`, `plotKrigingResults.m`) in the same directory.
2.  Ensure your data files (`Wind_Morning.mat`, `Boundary.mat`) are also in that directory or in the MATLAB path.
3.  Open the main driver script, **`run_kriging_analysis.m`**.
4.  Modify the **CONFIGURATION** section at the top of the script to match your needs. This is where you define your data columns and variogram parameters.

    ```matlab
    % --- Define the different models and datasets to analyze ---
    analyses = struct(...
        'name',           {'March Spherical', 'March Exponential', 'June Spherical', 'June Exponential'}, ...
        'dataColumn',     {3, 3, 4, 4}, ...
        'modelType',      {'spherical', 'exponential', 'spherical', 'exponential'}, ...
        'sill',           {5, 5, 20, 20}, ...
        'nugget',         {4, 4, 15, 15}, ...
        'range',          {2.0e5, 2.0e5, 2.0e5, 2.0e5} ...
    );
    ```
5.  Run the script. The analysis will run for each configured case, generating plots and a final RMSE summary table in the command window.

---

##  Function Reference

- **`run_kriging_analysis.m`**: The main script. Configure and run your entire analysis from here.
- **`performOrdinaryKriging.m`**: The core algorithm. Takes known points and variogram parameters and returns predicted values and variances.
- **`calculateVariogram.m`**: A utility function to compute the experimental variogram from a set of data points, which helps in choosing the sill, nugget, and range parameters.
- **`plotKrigingResults.m`**: A dedicated plotting function that creates a standardized 2x2 visualization for any Kriging result.

---
