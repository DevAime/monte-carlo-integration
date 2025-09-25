# Monte Carlo Integration GUI

A comprehensive MATLAB graphical user interface for numerical integration using Monte Carlo methods. This tool provides an intuitive way to compute single and double integrals with real-time visualization and error analysis.

### Single Integral Integration
*Compute 1D integrals with real-time function visualization and statistical analysis*

![Single Integral Interface](https://github.com/user-attachments/assets/daa15ddf-40bb-4907-b69d-2e13a42cd7fc)

### Double Integral Integration  
*Compute 2D integrals with stunning 3D surface plots, contour maps, and comprehensive analysis*

![Double Integral Interface](https://github.com/user-attachments/assets/31c62225-4c2b-4f64-8471-b19d77f25f20)

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Requirements](#requirements)

## Features

### **Core Functionality**
- **Single Integral (1D)**: Compute ∫f(x)dx over [a,b]
- **Double Integral (2D)**: Compute ∫∫f(x,y)dxdy over rectangular domains
- **Real-time Visualization**: Interactive plots showing function behavior and sampling
- **Statistical Analysis**: Automatic error estimation and confidence intervals

### **Advanced Analytics**
- **Monte Carlo Sampling**: Efficient random sampling with user-defined sample sizes
- **Error Analysis**: Standard error calculation and 95% confidence intervals
- **Convergence Visualization**: Multiple plot types for comprehensive analysis

## Installation

### Method 1: Direct Download
1. **Download** the `MonteCarloIntegrationGUI.m` file
2. **Place** it in your MATLAB working directory
3. **Run** the function:
   ```matlab
   MonteCarloIntegrationGUI()
   ```

### Method 2: Clone Repository
```bash
git clone https://github.com/yourusername/monte-carlo-integration-gui.git
cd monte-carlo-integration-gui
```

Then in MATLAB:
```matlab
MonteCarloIntegrationGUI()
```

## Usage

### Getting Started
1. **Launch** the GUI: `MonteCarloIntegrationGUI()`
2. **Choose** a tab: Single Integral or Double Integral
3. **Enter** your function using MATLAB syntax
4. **Set** integration limits and sample size
5. **Click** Calculate to see results and visualizations

### Function Syntax
- **Single Integral**: `@(x) x.^2 + sin(x)`
- **Double Integral**: `@(x,y) x.^2 + y.^2 + x.*y`

### Sample Sizes
- **Quick Test**: 10,000 samples
- **Standard**: 100,000 samples (recommended)
- **High Precision**: 1,000,000+ samples

## Examples

### Single Integral Examples

#### Polynomial Function
```matlab
Function: @(x) x.^3 + 2*x.^2 - x + 1
Domain: [0, 2]
Expected Result: ~8.67
```

#### Gaussian Function
```matlab
Function: @(x) exp(-(x-2).^2) .* sqrt(x)
Domain: [0, 5]
Expected Result: Beautiful bell curve visualization
```

### Double Integral Examples

#### Simple Polynomial
```matlab
Function: @(x,y) x.^2 + y.^2
Domain: [0,1] × [0,1]
Expected Result: 0.6667 (exact: 2/3)
```

#### 3D Gaussian Hill **Most Spectacular**
```matlab
Function: @(x,y) exp(-(x.^2 + y.^2))
Domain: [-2,2] × [-2,2]
Expected Result: ~3.14159 (≈ π)
```



## Requirements

### System Requirements
- **MATLAB**: R2019b or later (App Designer required)
- **Toolboxes**: Statistics and Machine Learning Toolbox (recommended)
- **RAM**: 4GB+ recommended for large sample sizes
- **Display**: 1200×800 minimum resolution

### MATLAB Functions Used
- `uifigure`, `uitabgroup`, `uipanel` (App Designer)
- `rand`, `mean`, `std` (Core functions)
- `surf`, `contourf`, `scatter` (Visualization)
- `histogram`, `plot`, `colorbar` (Graphics)


## References

1. **Numerical Recipes**: Press, W. H., et al. *Numerical Recipes in C*
2. **Monte Carlo Methods**: Rubinstein, R. Y. *Simulation and the Monte Carlo Method*
3. **MATLAB Documentation**: MathWorks App Designer Guide
