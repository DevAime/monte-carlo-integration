function MonteCarloIntegrationGUI()
    % MONTE CARLO INTEGRATION GUI TOOL
    % Usage: MonteCarloIntegrationGUI()
    
    % Create main figure
    fig = uifigure('Name', 'Monte Carlo Integration Tool', ...
                   'Position', [100, 100, 1200, 800], ...
                   'Resize', 'on');
    
    % Create tab group
    tabgroup = uitabgroup(fig, 'Position', [10, 10, 1180, 780]);
    
    % Create tabs
    tab1 = uitab(tabgroup, 'Title', 'Single Integral');
    tab2 = uitab(tabgroup, 'Title', 'Double Integral'); 
    tab3 = uitab(tabgroup, 'Title', 'Batch Processing');
    tab4 = uitab(tabgroup, 'Title', 'Convergence Analysis');
    
    % Setup each tab
    setupSingleIntegralTab(tab1);
    setupDoubleIntegralTab(tab2);
    setupBatchProcessingTab(tab3);
    setupConvergenceTab(tab4);
end

% =====================================================================
% TAB SETUP FUNCTIONS
% =====================================================================

function setupSingleIntegralTab(parent)
    % Single integral tab setup
    
    % Left panel for inputs
    inputPanel = uipanel(parent, 'Title', 'Integration Parameters', ...
                        'Position', [20, 400, 350, 350], ...
                        'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Function input
    uilabel(inputPanel, 'Text', 'Function f(x):', ...
            'Position', [20, 300, 100, 22], 'FontWeight', 'bold');
    funcEdit = uieditfield(inputPanel, 'text', ...
                          'Position', [20, 270, 300, 22], ...
                          'Value', '@(x) x.^2', ...
                          'Tooltip', 'Enter function using MATLAB syntax');
    
    % Integration limits
    uilabel(inputPanel, 'Text', 'Integration Limits:', ...
            'Position', [20, 230, 120, 22], 'FontWeight', 'bold');
    
    uilabel(inputPanel, 'Text', 'Lower (a):', 'Position', [20, 200, 70, 22]);
    aEdit = uieditfield(inputPanel, 'numeric', 'Position', [100, 200, 80, 22], 'Value', 0);
    
    uilabel(inputPanel, 'Text', 'Upper (b):', 'Position', [200, 200, 70, 22]);
    bEdit = uieditfield(inputPanel, 'numeric', 'Position', [270, 200, 50, 22], 'Value', 1);
    
    % Number of samples
    uilabel(inputPanel, 'Text', 'Samples (N):', 'Position', [20, 160, 80, 22], 'FontWeight', 'bold');
    NEdit = uieditfield(inputPanel, 'numeric', 'Position', [110, 160, 100, 22], 'Value', 100000);
    
    % Buttons
    calculateBtn = uibutton(inputPanel, 'push', ...
                           'Position', [20, 100, 100, 30], ...
                           'Text', 'Calculate', ...
                           'BackgroundColor', [0.2, 0.7, 0.2], ...
                           'FontColor', 'white', ...
                           'FontWeight', 'bold');
    
    clearBtn = uibutton(inputPanel, 'push', ...
                       'Position', [140, 100, 80, 30], ...
                       'Text', 'Clear', ...
                       'BackgroundColor', [0.8, 0.4, 0.4], ...
                       'FontColor', 'white');
    
    exampleBtn = uibutton(inputPanel, 'push', ...
                         'Position', [240, 100, 80, 30], ...
                         'Text', 'Examples', ...
                         'BackgroundColor', [0.4, 0.4, 0.8], ...
                         'FontColor', 'white');
    
    % Results panel
    resultPanel = uipanel(parent, 'Title', 'Results', ...
                         'Position', [20, 250, 350, 140], ...
                         'BackgroundColor', [0.94, 0.94, 0.94]);
    
    resultText = uitextarea(resultPanel, 'Position', [10, 10, 330, 100], ...
                           'Editable', 'off', ...
                           'FontName', 'FixedWidth', ...
                           'Value', {'Click Calculate to see results...'});
    
    % Plot panel
    plotPanel = uipanel(parent, 'Title', 'Visualization', ...
                       'Position', [390, 50, 760, 700], ...
                       'BackgroundColor', 'white');
    
    % Create axes for plotting
    ax1 = uiaxes(plotPanel, 'Position', [30, 380, 700, 290]);
    ax2 = uiaxes(plotPanel, 'Position', [30, 50, 700, 290]);
    
    title(ax1, 'Function and Sample Points');
    title(ax2, 'Distribution of Function Values');
    
    % Button callbacks
    calculateBtn.ButtonPushedFcn = @(~,~) calculateSingleIntegral();
    clearBtn.ButtonPushedFcn = @(~,~) clearSingleResults();
    exampleBtn.ButtonPushedFcn = @(~,~) showSingleExamples();
    
    function calculateSingleIntegral()
        try
            % Get inputs
            func_str = funcEdit.Value;
            a_val = aEdit.Value;
            b_val = bEdit.Value;
            N_val = NEdit.Value;
            
            % Validate inputs
            if a_val >= b_val
                uialert(parent.Parent.Parent, 'Lower limit must be less than upper limit!', 'Invalid Input');
                return;
            end
            
            if N_val <= 0
                uialert(parent.Parent.Parent, 'Number of samples must be positive!', 'Invalid Input');
                return;
            end
            
            % Parse function
            f = str2func(func_str);
            
            % Test function with a single point
            test_val = f(a_val);
            if ~isnumeric(test_val) || ~isfinite(test_val)
                uialert(parent.Parent.Parent, 'Invalid function or function returns non-numeric values!', 'Function Error');
                return;
            end
            
            % Perform Monte Carlo integration
            resultText.Value = {'Calculating... Please wait.'};
            drawnow;
            
            [estimate, error, x_samples, f_samples] = monteCarloSingle(f, a_val, b_val, N_val);
            
            % Display results
            results = {
                sprintf('MONTE CARLO INTEGRATION RESULTS');
                sprintf('================================');
                sprintf('Function: %s', func_str);
                sprintf('Limits: [%.3f, %.3f]', a_val, b_val);
                sprintf('Samples: %d', N_val);
                sprintf('');
                sprintf('Integral Estimate: %.8f', estimate);
                sprintf('Standard Error: ± %.8f', error);
                sprintf('95%% Confidence: [%.6f, %.6f]', ...
                       estimate - 1.96*error, estimate + 1.96*error);
                sprintf('Relative Error: ± %.4f%%', error/abs(estimate)*100);
            };
            resultText.Value = results;
            
            % Plot results
            plotSingleIntegralResults(ax1, ax2, f, a_val, b_val, x_samples, f_samples, estimate);
            
        catch ME
            uialert(parent.Parent.Parent, ['Error: ' ME.message], 'Calculation Error');
        end
    end
    
    function clearSingleResults()
        funcEdit.Value = '@(x) x.^2';
        aEdit.Value = 0;
        bEdit.Value = 1;
        NEdit.Value = 100000;
        resultText.Value = {'Click Calculate to see results...'};
        cla(ax1);
        cla(ax2);
        title(ax1, 'Function and Sample Points');
        title(ax2, 'Distribution of Function Values');
    end
    
    function showSingleExamples()
        % Simple examples without complex switch statements
        examples = {
            'Polynomial: x^3 + 2*x^2 - x + 1';
            'Trigonometric: sin(x) * cos(x^2)';
            'Exponential: exp(-x) * sin(10*x)';
            'Gaussian: exp(-(x-2)^2) * sqrt(x)';
            'Rational: 1/(1 + x^4)';
        };
        
        [indx,tf] = listdlg('PromptString', 'Select example:', ...
                           'SelectionMode', 'single', ...
                           'ListString', examples, ...
                           'ListSize', [300, 150]);
        
        if tf
            if indx == 1
                funcEdit.Value = '@(x) x.^3 + 2*x.^2 - x + 1';
                aEdit.Value = 0; bEdit.Value = 2;
            end
            if indx == 2
                funcEdit.Value = '@(x) sin(x) .* cos(x.^2)';
                aEdit.Value = 0; bEdit.Value = pi;
            end
            if indx == 3
                funcEdit.Value = '@(x) exp(-x) .* sin(10*x)';
                aEdit.Value = 0; bEdit.Value = 5;
            end
            if indx == 4
                funcEdit.Value = '@(x) exp(-(x-2).^2) .* sqrt(x)';
                aEdit.Value = 0; bEdit.Value = 5;
            end
            if indx == 5
                funcEdit.Value = '@(x) 1./(1 + x.^4)';
                aEdit.Value = 0; bEdit.Value = 10;
            end
        end
    end
end

function setupDoubleIntegralTab(parent)
    % Double integral tab setup
    
    % Input panel
    inputPanel = uipanel(parent, 'Title', 'Integration Parameters', ...
                        'Position', [20, 400, 350, 350], ...
                        'BackgroundColor', [0.94, 0.94, 0.94]);
    
    % Function input
    uilabel(inputPanel, 'Text', 'Function f(x,y):', ...
            'Position', [20, 300, 120, 22], 'FontWeight', 'bold');
    funcEdit2D = uieditfield(inputPanel, 'text', ...
                            'Position', [20, 270, 300, 22], ...
                            'Value', '@(x,y) x.^2 + y.^2', ...
                            'Tooltip', 'Enter 2D function using MATLAB syntax');
    
    % Integration limits
    uilabel(inputPanel, 'Text', 'Integration Limits:', ...
            'Position', [20, 230, 120, 22], 'FontWeight', 'bold');
    
    % X limits
    uilabel(inputPanel, 'Text', 'x: [', 'Position', [20, 200, 25, 22]);
    aEdit2D = uieditfield(inputPanel, 'numeric', 'Position', [45, 200, 50, 22], 'Value', 0);
    uilabel(inputPanel, 'Text', ',', 'Position', [100, 200, 10, 22]);
    bEdit2D = uieditfield(inputPanel, 'numeric', 'Position', [115, 200, 50, 22], 'Value', 1);
    uilabel(inputPanel, 'Text', ']', 'Position', [170, 200, 10, 22]);
    
    % Y limits
    uilabel(inputPanel, 'Text', 'y: [', 'Position', [190, 200, 25, 22]);
    cEdit2D = uieditfield(inputPanel, 'numeric', 'Position', [215, 200, 50, 22], 'Value', 0);
    uilabel(inputPanel, 'Text', ',', 'Position', [270, 200, 10, 22]);
    dEdit2D = uieditfield(inputPanel, 'numeric', 'Position', [285, 200, 35, 22], 'Value', 1);
    uilabel(inputPanel, 'Text', ']', 'Position', [325, 200, 10, 22]);
    
    % Number of samples
    uilabel(inputPanel, 'Text', 'Samples (N):', 'Position', [20, 160, 80, 22], 'FontWeight', 'bold');
    NEdit2D = uieditfield(inputPanel, 'numeric', 'Position', [110, 160, 100, 22], 'Value', 100000);
    
    % Additional options
    uilabel(inputPanel, 'Text', 'Display Options:', 'Position', [20, 120, 100, 22], 'FontWeight', 'bold');
    show3DCheck = uicheckbox(inputPanel, 'Text', '3D Surface', 'Position', [20, 95, 80, 22], 'Value', true);
    showSamplesCheck = uicheckbox(inputPanel, 'Text', 'Sample Points', 'Position', [110, 95, 100, 22], 'Value', true);
    
    % Buttons
    calculateBtn2D = uibutton(inputPanel, 'push', ...
                             'Position', [20, 60, 100, 30], ...
                             'Text', 'Calculate', ...
                             'BackgroundColor', [0.2, 0.7, 0.2], ...
                             'FontColor', 'white', ...
                             'FontWeight', 'bold');
    
    clearBtn2D = uibutton(inputPanel, 'push', ...
                         'Position', [140, 60, 80, 30], ...
                         'Text', 'Clear', ...
                         'BackgroundColor', [0.8, 0.4, 0.4], ...
                         'FontColor', 'white');
    
    exampleBtn2D = uibutton(inputPanel, 'push', ...
                           'Position', [240, 60, 80, 30], ...
                           'Text', 'Examples', ...
                           'BackgroundColor', [0.4, 0.4, 0.8], ...
                           'FontColor', 'white');
    
    % Results panel
    resultPanel2D = uipanel(parent, 'Title', 'Results', ...
                           'Position', [20, 250, 350, 140], ...
                           'BackgroundColor', [0.94, 0.94, 0.94]);
    
    resultText2D = uitextarea(resultPanel2D, 'Position', [10, 10, 330, 100], ...
                             'Editable', 'off', ...
                             'FontName', 'FixedWidth', ...
                             'Value', {'Click Calculate to see double integral results...'});
    
    % Plot panel with multiple axes
    plotPanel2D = uipanel(parent, 'Title', 'Visualization', ...
                         'Position', [390, 50, 760, 700], ...
                         'BackgroundColor', 'white');
    
    ax2D_1 = uiaxes(plotPanel2D, 'Position', [30, 380, 340, 290]);
    ax2D_2 = uiaxes(plotPanel2D, 'Position', [390, 380, 340, 290]);
    ax2D_3 = uiaxes(plotPanel2D, 'Position', [30, 50, 340, 290]);
    ax2D_4 = uiaxes(plotPanel2D, 'Position', [390, 50, 340, 290]);
    
    title(ax2D_1, 'Function Surface');
    title(ax2D_2, 'Sample Points');
    title(ax2D_3, 'Function Values Histogram');
    title(ax2D_4, 'Contour Plot');
    
    % Button callbacks
    calculateBtn2D.ButtonPushedFcn = @(~,~) calculateDoubleIntegral();
    clearBtn2D.ButtonPushedFcn = @(~,~) clearDoubleResults();
    exampleBtn2D.ButtonPushedFcn = @(~,~) showDoubleExamples();
    
    function calculateDoubleIntegral()
        try
            % Get inputs
            func_str = funcEdit2D.Value;
            a_val = aEdit2D.Value; b_val = bEdit2D.Value;
            c_val = cEdit2D.Value; d_val = dEdit2D.Value;
            N_val = NEdit2D.Value;
            
            % Validate inputs
            if a_val >= b_val || c_val >= d_val
                uialert(parent.Parent.Parent, 'Lower limits must be less than upper limits!', 'Invalid Input');
                return;
            end
            
            if N_val <= 0
                uialert(parent.Parent.Parent, 'Number of samples must be positive!', 'Invalid Input');
                return;
            end
            
            % Parse and test function
            f = str2func(func_str);
            
            % Test function with sample points
            test_x = (a_val + b_val) / 2;
            test_y = (c_val + d_val) / 2;
            test_val = f(test_x, test_y);
            if ~isnumeric(test_val) || ~isfinite(test_val)
                uialert(parent.Parent.Parent, 'Invalid function or function returns non-numeric values!', 'Function Error');
                return;
            end
            
            % Show progress
            resultText2D.Value = {'Calculating double integral... Please wait.'};
            drawnow;
            
            % Perform Monte Carlo double integration
            [estimate, error, x_samples, y_samples, f_samples] = ...
                monteCarloDouble(f, a_val, b_val, c_val, d_val, N_val);
            
            % Display results
            domain_area = (b_val - a_val) * (d_val - c_val);
            results = {
                sprintf('DOUBLE INTEGRAL RESULTS');
                sprintf('=======================');
                sprintf('Function: %s', func_str);
                sprintf('Domain: [%.3f,%.3f] × [%.3f,%.3f]', a_val, b_val, c_val, d_val);
                sprintf('Domain Area: %.6f', domain_area);
                sprintf('Samples: %d', N_val);
                sprintf('');
                sprintf('∫∫ f(x,y) dxdy = %.8f', estimate);
                sprintf('Standard Error: ± %.8f', error);
                sprintf('95%% Confidence: [%.6f, %.6f]', ...
                       estimate - 1.96*error, estimate + 1.96*error);
                sprintf('Relative Error: ± %.4f%%', error/abs(estimate)*100);
                sprintf('');
                sprintf('Mean f(x,y): %.6f', mean(f_samples));
                sprintf('Std f(x,y): %.6f', std(f_samples));
            };
            resultText2D.Value = results;
            
            % Plot results
            try
                plotDoubleIntegralResults(ax2D_1, ax2D_2, ax2D_3, ax2D_4, ...
                                         f, a_val, b_val, c_val, d_val, ...
                                         x_samples, y_samples, f_samples, ...
                                         show3DCheck.Value, showSamplesCheck.Value);
            catch plotME
                % If plotting fails, show simple message
                cla(ax2D_1); title(ax2D_1, 'Plot Error - Check Function');
                cla(ax2D_2); title(ax2D_2, 'Plot Error - Check Function'); 
                cla(ax2D_3); title(ax2D_3, 'Plot Error - Check Function');
                cla(ax2D_4); title(ax2D_4, 'Plot Error - Check Function');
                warning('Double integral plotting failed: %s', plotME.message);
            end
            
        catch ME
            uialert(parent.Parent.Parent, ['Calculation Error: ' ME.message], 'Error');
            resultText2D.Value = {['Error: ' ME.message]; 'Please check your function syntax.'};
        end
    end
    
    function clearDoubleResults()
        funcEdit2D.Value = '@(x,y) x.^2 + y.^2';
        aEdit2D.Value = 0; bEdit2D.Value = 1;
        cEdit2D.Value = 0; dEdit2D.Value = 1;
        NEdit2D.Value = 100000;
        show3DCheck.Value = true;
        showSamplesCheck.Value = true;
        resultText2D.Value = {'Click Calculate to see double integral results...'};
        cla(ax2D_1); cla(ax2D_2); cla(ax2D_3); cla(ax2D_4);
        title(ax2D_1, 'Function Surface');
        title(ax2D_2, 'Sample Points');
        title(ax2D_3, 'Function Values Histogram');
        title(ax2D_4, 'Contour Plot');
    end
    
    function showDoubleExamples()
        % Simple examples using individual if statements
        examples = {
            'Simple: x^2 + y^2 + x*y';
            'Gaussian: exp(-(x^2 + y^2))';
            'Trigonometric: sin(x) * cos(y)';
            'Wave: cos(x*y) * exp(-(x+y)^2/4)';
            'Exponential: exp((x+y)^4)';
            'Product: x * y * (x + y)';
        };
        
        [indx,tf] = listdlg('PromptString', 'Select example:', ...
                           'SelectionMode', 'single', ...
                           'ListString', examples, ...
                           'ListSize', [300, 150]);
        
        if tf
            if indx == 1
                funcEdit2D.Value = '@(x,y) x.^2 + y.^2 + x.*y';
                aEdit2D.Value = 0; bEdit2D.Value = 1; cEdit2D.Value = 0; dEdit2D.Value = 1;
            end
            if indx == 2
                funcEdit2D.Value = '@(x,y) exp(-(x.^2 + y.^2))';
                aEdit2D.Value = -2; bEdit2D.Value = 2; cEdit2D.Value = -2; dEdit2D.Value = 2;
            end
            if indx == 3
                funcEdit2D.Value = '@(x,y) sin(x) .* cos(y)';
                aEdit2D.Value = 0; bEdit2D.Value = pi; cEdit2D.Value = 0; dEdit2D.Value = pi;
            end
            if indx == 4
                funcEdit2D.Value = '@(x,y) cos(x.*y) .* exp(-(x+y).^2/4)';
                aEdit2D.Value = -3; bEdit2D.Value = 3; cEdit2D.Value = -3; dEdit2D.Value = 3;
            end
            if indx == 5
                funcEdit2D.Value = '@(x,y) exp((x+y).^4)';
                aEdit2D.Value = 0; bEdit2D.Value = 1; cEdit2D.Value = 0; dEdit2D.Value = 1;
            end
            if indx == 6
                funcEdit2D.Value = '@(x,y) x .* y .* (x + y)';
                aEdit2D.Value = 0; bEdit2D.Value = 2; cEdit2D.Value = 0; dEdit2D.Value = 2;
            end
        end
    end
end

function setupBatchProcessingTab(parent)
    % Simple message for now
    uilabel(parent, 'Text', 'Batch Processing Feature Coming Soon...', ...
            'Position', [400, 400, 300, 22], 'FontWeight', 'bold', 'FontSize', 16);
end

function setupConvergenceTab(parent)
    % Simple message for now
    uilabel(parent, 'Text', 'Convergence Analysis Feature Coming Soon...', ...
            'Position', [400, 400, 300, 22], 'FontWeight', 'bold', 'FontSize', 16);
end

% =====================================================================
% CORE MONTE CARLO FUNCTIONS
% =====================================================================

function [integral_estimate, error_estimate, x_samples, f_samples] = ...
    monteCarloSingle(f, a, b, N)
    % Single integral Monte Carlo integration
    
    x_samples = a + (b - a) * rand(N, 1);
    f_samples = f(x_samples);
    
    mean_f = mean(f_samples);
    integral_estimate = (b - a) * mean_f;
    
    std_f = std(f_samples);
    error_estimate = (b - a) * std_f / sqrt(N);
end

function [integral_estimate, error_estimate, x_samples, y_samples, f_samples] = ...
    monteCarloDouble(f, a, b, c, d, N)
    % Double integral Monte Carlo integration
    
    x_samples = a + (b - a) * rand(N, 1);
    y_samples = c + (d - c) * rand(N, 1);
    f_samples = f(x_samples, y_samples);
    
    mean_f = mean(f_samples);
    integral_estimate = (b - a) * (d - c) * mean_f;
    
    std_f = std(f_samples);
    error_estimate = (b - a) * (d - c) * std_f / sqrt(N);
end

% =====================================================================
% PLOTTING FUNCTIONS
% =====================================================================

function plotSingleIntegralResults(ax1, ax2, f, a, b, x_samples, f_samples, estimate)
    % Plot single integral results
    
    % Plot 1: Function and sample points
    cla(ax1);
    x_plot = linspace(a, b, 1000);
    y_plot = f(x_plot);
    
    plot(ax1, x_plot, y_plot, 'b-', 'LineWidth', 2);
    hold(ax1, 'on');
    
    % Show subset of points for clarity
    n_show = min(500, length(x_samples));
    idx_show = randperm(length(x_samples), n_show);
    scatter(ax1, x_samples(idx_show), f_samples(idx_show), 15, 'r.', 'MarkerEdgeAlpha', 0.4);
    
    xlabel(ax1, 'x');
    ylabel(ax1, 'f(x)');
    title(ax1, sprintf('Function and Sample Points (N=%d)', length(x_samples)));
    legend(ax1, 'f(x)', sprintf('Samples (%d shown)', n_show), 'Location', 'best');
    grid(ax1, 'on');
    
    % Plot 2: Histogram of function values
    cla(ax2);
    histogram(ax2, f_samples, 50, 'FaceAlpha', 0.7, 'FaceColor', [0.3, 0.7, 0.9]);
    hold(ax2, 'on');
    xline(ax2, mean(f_samples), 'r--', 'LineWidth', 2, 'Label', sprintf('Mean = %.4f', mean(f_samples)));
    
    xlabel(ax2, 'Function Values');
    ylabel(ax2, 'Frequency');
    title(ax2, sprintf('Distribution (Estimate = %.6f)', estimate));
    grid(ax2, 'on');
end

function plotDoubleIntegralResults(ax1, ax2, ax3, ax4, f, a, b, c, d, x_samples, y_samples, f_samples, show3D, showSamples)
    % Plot double integral results
    
    try
        % Plot 1: Function surface (if enabled)
        cla(ax1);
        if show3D
            [X, Y] = meshgrid(linspace(a, b, 30), linspace(c, d, 30));
            Z = f(X, Y);
            surf(ax1, X, Y, Z, 'FaceAlpha', 0.8, 'EdgeAlpha', 0.3);
            xlabel(ax1, 'x'); ylabel(ax1, 'y'); zlabel(ax1, 'f(x,y)');
            title(ax1, 'Function Surface');
            colorbar(ax1);
            view(ax1, -37.5, 30);
        else
            text(ax1, 0.5, 0.5, '3D Surface Disabled', 'HorizontalAlignment', 'center');
            title(ax1, '3D Surface (Disabled)');
        end
        
        % Plot 2: Sample points colored by function value
        cla(ax2);
        if showSamples
            n_show = min(2000, length(x_samples));
            idx_show = randperm(length(x_samples), n_show);
            scatter(ax2, x_samples(idx_show), y_samples(idx_show), 25, f_samples(idx_show), 'filled');
            xlabel(ax2, 'x'); ylabel(ax2, 'y');
            title(ax2, sprintf('Sample Points (N=%d)', length(x_samples)));
            colorbar(ax2);
            xlim(ax2, [a, b]); ylim(ax2, [c, d]);
            grid(ax2, 'on');
        else
            text(ax2, 0.5, 0.5, 'Sample Points Disabled', 'HorizontalAlignment', 'center');
            title(ax2, 'Sample Points (Disabled)');
        end
        
        % Plot 3: Histogram of function values
        cla(ax3);
        histogram(ax3, f_samples, 50, 'FaceAlpha', 0.7, 'FaceColor', [0.3, 0.7, 0.9]);
        hold(ax3, 'on');
        xline(ax3, mean(f_samples), 'r--', 'LineWidth', 2, 'Label', sprintf('Mean=%.4f', mean(f_samples)));
        xlabel(ax3, 'Function Values');
        ylabel(ax3, 'Frequency');
        title(ax3, sprintf('Distribution (μ=%.4f, σ=%.4f)', mean(f_samples), std(f_samples)));
        grid(ax3, 'on');
        
        % Plot 4: Contour plot with sample points
        cla(ax4);
        try
            [X, Y] = meshgrid(linspace(a, b, 25), linspace(c, d, 25));
            Z = f(X, Y);
            contourf(ax4, X, Y, Z, 15);
            hold(ax4, 'on');
            
            if showSamples
                n_show_contour = min(500, length(x_samples));
                idx_show_contour = randperm(length(x_samples), n_show_contour);
                scatter(ax4, x_samples(idx_show_contour), y_samples(idx_show_contour), 8, 'w.', 'MarkerEdgeAlpha', 0.8);
            end
            
            xlabel(ax4, 'x'); ylabel(ax4, 'y');
            title(ax4, 'Contours + Sample Points');
            colorbar(ax4);
            
        catch
            % If contour fails, show scatter plot instead
            if showSamples
                n_show = min(1000, length(x_samples));
                idx_show = randperm(length(x_samples), n_show);
                scatter(ax4, x_samples(idx_show), y_samples(idx_show), 15, f_samples(idx_show), 'filled');
                colorbar(ax4);
            end
            xlabel(ax4, 'x'); ylabel(ax4, 'y');
            title(ax4, 'Sample Points (Contour Failed)');
            xlim(ax4, [a, b]); ylim(ax4, [c, d]);
        end
        
    catch ME
        % If all plotting fails, show error message
        cla(ax1); title(ax1, 'Plot Error - Check Function');
        cla(ax2); title(ax2, 'Plot Error - Check Function');
        cla(ax3); title(ax3, 'Plot Error - Check Function');
        cla(ax4); title(ax4, 'Plot Error - Check Function');
        warning('Plotting failed: %s', ME.message);
    end
end
