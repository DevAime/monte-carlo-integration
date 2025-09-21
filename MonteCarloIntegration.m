function MonteCarloIntegrationGUI()
    % MONTE CARLO INTEGRATION GUI TOOL
    % A comprehensive GUI for Monte Carlo numerical integration
    
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
    
    % Initialize shared data
    data = struct();
    
    % Setup each tab
    setupSingleIntegralTab(tab1, data);
    setupDoubleIntegralTab(tab2, data);
    setupBatchProcessingTab(tab3, data);
    setupConvergenceTab(tab4, data);
end

function setupSingleIntegralTab(parent, data)
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
        examples = {
            'Polynomial: @(x) x.^3 + 2*x.^2 - x + 1';
            'Trigonometric: @(x) sin(x) .* cos(x.^2)';
            'Exponential: @(x) exp(-x) .* sin(10*x)';
            'Gaussian: @(x) exp(-(x-2).^2) .* sqrt(x)';
            'Rational: @(x) 1./(1 + x.^4)';
        };
        
        selection = uiconfirm(parent.Parent.Parent, ...
                             sprintf('%s\n\nSelect an example?', strjoin(examples, newline)), ...
                             'Function Examples', ...
                             'Options', {'Polynomial', 'Trigonometric', 'Exponential', 'Gaussian', 'Rational', 'Cancel'}, ...
                             'DefaultOption', 1, 'CancelOption', 6);
        
        switch selection
            case 'Polynomial'
                funcEdit.Value = '@(x) x.^3 + 2*x.^2 - x + 1';
                aEdit.Value = 0; bEdit.Value = 2;
            case 'Trigonometric'
                funcEdit.Value = '@(x) sin(x) .* cos(x.^2)';
                aEdit.Value = 0; bEdit.Value = pi;
            case 'Exponential'
                funcEdit.Value = '@(x) exp(-x) .* sin(10*x)';
                aEdit.Value = 0; bEdit.Value = 5;
            case 'Gaussian'
                funcEdit.Value = '@(x) exp(-(x-2).^2) .* sqrt(x)';
                aEdit.Value = 0; bEdit.Value = 5;
            case 'Rational'
                funcEdit.Value = '@(x) 1./(1 + x.^4)';
                aEdit.Value = 0; bEdit.Value = 10;
        end
    end
end

function setupDoubleIntegralTab(parent, data)
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
                            'Value', '@(x,y) x.^2 + y.^2');
    
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
    
    % Buttons
    calculateBtn2D = uibutton(inputPanel, 'push', ...
                             'Position', [20, 100, 100, 30], ...
                             'Text', 'Calculate', ...
                             'BackgroundColor', [0.2, 0.7, 0.2], ...
                             'FontColor', 'white', ...
                             'FontWeight', 'bold');
    
    clearBtn2D = uibutton(inputPanel, 'push', ...
                         'Position', [140, 100, 80, 30], ...
                         'Text', 'Clear', ...
                         'BackgroundColor', [0.8, 0.4, 0.4], ...
                         'FontColor', 'white');
    
    exampleBtn2D = uibutton(inputPanel, 'push', ...
                           'Position', [240, 100, 80, 30], ...
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
                             'Value', {'Click Calculate to see results...'});
    
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
            
            % Parse function
            f = str2func(func_str);
            
            % Perform calculation
            resultText2D.Value = {'Calculating... Please wait.'};
            drawnow;
            
            [estimate, error, x_samples, y_samples, f_samples] = ...
                monteCarloDouble(f, a_val, b_val, c_val, d_val, N_val);
            
            % Display results
            results = {
                sprintf('DOUBLE INTEGRAL RESULTS');
                sprintf('=======================');
                sprintf('Function: %s', func_str);
                sprintf('Domain: [%.3f,%.3f] × [%.3f,%.3f]', a_val, b_val, c_val, d_val);
                sprintf('Samples: %d', N_val);
                sprintf('');
                sprintf('Integral Estimate: %.8f', estimate);
                sprintf('Standard Error: ± %.8f', error);
                sprintf('95%% Confidence: [%.6f, %.6f]', ...
                       estimate - 1.96*error, estimate + 1.96*error);
            };
            resultText2D.Value = results;
            
            % Plot results
            plotDoubleIntegralResults(ax2D_1, ax2D_2, ax2D_3, ax2D_4, ...
                                     f, a_val, b_val, c_val, d_val, ...
                                     x_samples, y_samples, f_samples);
            
        catch ME
            uialert(parent.Parent.Parent, ['Error: ' ME.message], 'Calculation Error');
        end
    end
    
    function clearDoubleResults()
        funcEdit2D.Value = '@(x,y) x.^2 + y.^2';
        aEdit2D.Value = 0; bEdit2D.Value = 1;
        cEdit2D.Value = 0; dEdit2D.Value = 1;
        NEdit2D.Value = 100000;
        resultText2D.Value = {'Click Calculate to see results...'};
        cla(ax2D_1); cla(ax2D_2); cla(ax2D_3); cla(ax2D_4);
        title(ax2D_1, 'Function Surface');
        title(ax2D_2, 'Sample Points');
        title(ax2D_3, 'Function Values Histogram');
        title(ax2D_4, 'Contour Plot');
    end
    
    function showDoubleExamples()
        examples = {
            'Polynomial: @(x,y) x.^2 + y.^2 + x.*y';
            'Gaussian: @(x,y) exp(-(x.^2 + y.^2))';
            'Trigonometric: @(x,y) sin(x) .* cos(y)';
            'Wave: @(x,y) cos(x.*y) .* exp(-(x+y).^2/4)';
            'Complex: @(x,y) exp((x+y).^4)';
        };
        
        selection = uiconfirm(parent.Parent.Parent, ...
                             sprintf('%s\n\nSelect an example?', strjoin(examples, newline)), ...
                             'Function Examples', ...
                             'Options', {'Polynomial', 'Gaussian', 'Trigonometric', 'Wave', 'Complex', 'Cancel'}, ...
                             'DefaultOption', 1, 'CancelOption', 6);
        
        switch selection
            case 'Polynomial'
                funcEdit2D.Value = '@(x,y) x.^2 + y.^2 + x.*y';
                setLimits(0,1,0,1);
            case 'Gaussian'
                funcEdit2D.Value = '@(x,y) exp(-(x.^2 + y.^2))';
                setLimits(-2,2,-2,2);
            case 'Trigonometric'
                funcEdit2D.Value = '@(x,y) sin(x) .* cos(y)';
                setLimits(0,pi,0,pi);
            case 'Wave'
                funcEdit2D.Value = '@(x,y) cos(x.*y) .* exp(-(x+y).^2/4)';
                setLimits(-3,3,-3,3);
            case 'Complex'
                funcEdit2D.Value = '@(x,y) exp((x+y).^4)';
                setLimits(0,1,0,1);
        end
        
        function setLimits(a,b,c,d)
            aEdit2D.Value = a; bEdit2D.Value = b;
            cEdit2D.Value = c; dEdit2D.Value = d;
        end
    end
end

function setupBatchProcessingTab(parent, data)
    % Batch processing tab
    
    % Control panel
    controlPanel = uipanel(parent, 'Title', 'Batch Processing Control', ...
                          'Position', [20, 650, 1140, 100], ...
                          'BackgroundColor', [0.94, 0.94, 0.94]);
    
    uilabel(controlPanel, 'Text', 'Sample Size:', ...
            'Position', [20, 50, 80, 22], 'FontWeight', 'bold');
    batchNEdit = uieditfield(controlPanel, 'numeric', ...
                            'Position', [110, 50, 80, 22], ...
                            'Value', 50000);
    
    runBatchBtn = uibutton(controlPanel, 'push', ...
                          'Position', [220, 45, 120, 30], ...
                          'Text', 'Run Batch Test', ...
                          'BackgroundColor', [0.2, 0.7, 0.2], ...
                          'FontColor', 'white', ...
                          'FontWeight', 'bold');
    
    exportBtn = uibutton(controlPanel, 'push', ...
                        'Position', [360, 45, 100, 30], ...
                        'Text', 'Export Results', ...
                        'BackgroundColor', [0.4, 0.4, 0.8], ...
                        'FontColor', 'white');
    
    % Progress bar
    progressBar = uiprogressdlg(parent.Parent.Parent, 'Title', 'Processing...', ...
                               'Indeterminate', 'on', 'Visible', 'off');
    
    % Results table
    resultsTable = uitable(parent, 'Position', [20, 50, 1140, 590], ...
                          'ColumnName', {'Function', 'Type', 'Domain', 'Estimate', 'Error', 'Exact', 'Rel.Error(%)', 'Status'}, ...
                          'ColumnWidth', {200, 60, 120, 100, 100, 100, 100, 80}, ...
                          'RowName', {});
    
    runBatchBtn.ButtonPushedFcn = @(~,~) runBatchProcessing();
    exportBtn.ButtonPushedFcn = @(~,~) exportResults();
    
    function runBatchProcessing()
        N = batchNEdit.Value;
        if N <= 0
            uialert(parent.Parent.Parent, 'Sample size must be positive!', 'Invalid Input');
            return;
        end
        
        progressBar.Visible = 'on';
        progressBar.Value = 0;
        
        % Define test functions
        test_functions = getTestFunctions();
        
        results_data = cell(length(test_functions), 8);
        
        for i = 1:length(test_functions)
            func_data = test_functions{i};
            progressBar.Value = (i-1)/length(test_functions);
            progressBar.Message = sprintf('Processing function %d/%d: %s', i, length(test_functions), func_data.name);
            
            try
                if strcmp(func_data.type, '1D')
                    [estimate, error] = monteCarloSingle(func_data.func, func_data.a, func_data.b, N);
                    domain_str = sprintf('[%.2f, %.2f]', func_data.a, func_data.b);
                else
                    [estimate, error] = monteCarloDouble(func_data.func, func_data.a, func_data.b, func_data.c, func_data.d, N);
                    domain_str = sprintf('[%.1f,%.1f]×[%.1f,%.1f]', func_data.a, func_data.b, func_data.c, func_data.d);
                end
                
                rel_error = abs(estimate - func_data.exact) / abs(func_data.exact) * 100;
                status = 'OK';
                
                results_data{i, 1} = func_data.name;
                results_data{i, 2} = func_data.type;
                results_data{i, 3} = domain_str;
                results_data{i, 4} = sprintf('%.6f', estimate);
                results_data{i, 5} = sprintf('%.6f', error);
                results_data{i, 6} = sprintf('%.6f', func_data.exact);
                results_data{i, 7} = sprintf('%.2f', rel_error);
                results_data{i, 8} = status;
                
            catch ME
                results_data{i, 1} = func_data.name;
                results_data{i, 2} = func_data.type;
                results_data{i, 3} = 'N/A';
                results_data{i, 4} = 'Error';
                results_data{i, 5} = 'Error';
                results_data{i, 6} = sprintf('%.6f', func_data.exact);
                results_data{i, 7} = 'N/A';
                results_data{i, 8} = 'Error';
            end
            
            % Update table progressively
            resultsTable.Data = results_data(1:i, :);
            drawnow;
        end
        
        progressBar.Visible = 'off';
        uialert(parent.Parent.Parent, 'Batch processing completed!', 'Success');
    end
    
    function exportResults()
        if isempty(resultsTable.Data)
            uialert(parent.Parent.Parent, 'No results to export. Run batch processing first.', 'No Data');
            return;
        end
        
        % Create table for export
        T = cell2table(resultsTable.Data, 'VariableNames', ...
                      {'Function', 'Type', 'Domain', 'Estimate', 'Error', 'Exact', 'RelError_Percent', 'Status'});
        
        [file, path] = uiputfile('*.csv', 'Save Results As');
        if file ~= 0
            writetable(T, fullfile(path, file));
            uialert(parent.Parent.Parent, ['Results exported to: ' fullfile(path, file)], 'Export Successful');
        end
    end
end

function setupConvergenceTab(parent, data)
    % Convergence analysis tab
    
    % Control panel
    controlPanel = uipanel(parent, 'Title', 'Convergence Analysis', ...
                          'Position', [20, 650, 1140, 100], ...
                          'BackgroundColor', [0.94, 0.94, 0.94]);
    
    uilabel(controlPanel, 'Text', 'Test Function:', ...
            'Position', [20, 50, 80, 22], 'FontWeight', 'bold');
    testFuncDropdown = uidropdown(controlPanel, ...
                                 'Position', [110, 50, 200, 22], ...
                                 'Items', {'x^2 (0 to 1)', 'sin(x) (0 to π)', 'exp(-x) (0 to 5)', 'x^2+y^2 (unit square)'}, ...
                                 'Value', 'x^2 (0 to 1)');
    
    runConvergenceBtn = uibutton(controlPanel, 'push', ...
                                'Position', [330, 45, 150, 30], ...
                                'Text', 'Run Analysis', ...
                                'BackgroundColor', [0.2, 0.7, 0.2], ...
                                'FontColor', 'white', ...
                                'FontWeight', 'bold');
    
    % Plot panel
    plotPanel = uipanel(parent, 'Title', 'Convergence Plots', ...
                       'Position', [20, 50, 1140, 590], ...
                       'BackgroundColor', 'white');
    
    axConv1 = uiaxes(plotPanel, 'Position', [50, 320, 500, 250]);
    axConv2 = uiaxes(plotPanel, 'Position', [580, 320, 500, 250]);
    axConv3 = uiaxes(plotPanel, 'Position', [50, 30, 500, 250]);
    axConv4 = uiaxes(plotPanel, 'Position', [580, 30, 500, 250]);
    
    title(axConv1, 'Estimates vs Sample Size');
    title(axConv2, 'Error vs Sample Size (Log-Log)');
    title(axConv3, 'Error Distribution');
    title(axConv4, 'Convergence Rate');
    
    runConvergenceBtn.ButtonPushedFcn = @(~,~) runConvergenceAnalysis();
    
    function runConvergenceAnalysis()
        selection = testFuncDropdown.Value;
        
        % Define test function based on selection
        switch selection
            case 'x^2 (0 to 1)'
                f = @(x) x.^2;
                a = 0; b = 1; exact = 1/3;
                func_type = '1D';
            case 'sin(x) (0 to π)'
                f = @(x) sin(x);
                a = 0; b = pi; exact = 2;
                func_type = '1D';
            case 'exp(-x) (0 to 5)'
                f = @(x) exp(-x);
                a = 0; b = 5; exact = 1 - exp(-5);
                func_type = '1D';
            case 'x^2+y^2 (unit square)'
                f = @(x,y) x.^2 + y.^2;
                a = 0; b = 1; c = 0; d = 1; exact = 2/3;
                func_type = '2D';
        end
        
        % Sample sizes for convergence study
        N_values = [100, 500, 1000, 5000, 10000, 50000, 100000, 500000];
        estimates = zeros(size(N_values));
        errors = zeros(size(N_values));
        
        % Progress dialog
        progressDlg = uiprogressdlg(parent.Parent.Parent, ...
                                   'Title', 'Running Convergence Analysis', ...
                                   'Message', 'Calculating...');
        
        for i = 1:length(N_values)
            progressDlg.Value = i / length(N_values);
            progressDlg.Message = sprintf('Sample size: %d', N_values(i));
            
            if strcmp(func_type, '1D')
                [estimates(i), errors(i)] = monteCarloSingle(f, a, b, N_values(i));
            else
                [estimates(i), errors(i)] = monteCarloDouble(f, a, b, c, d, N_values(i));
            end
        end
        
        close(progressDlg);
        
        % Plot convergence results
        plotConvergenceResults(axConv1, axConv2, axConv3, axConv4, ...
                              N_values, estimates, errors, exact, selection);
        
        uialert(parent.Parent.Parent, 'Convergence analysis completed!', 'Success');
    end
end

% Core Monte Carlo functions
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

% Plotting functions
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

function plotDoubleIntegralResults(ax1, ax2, ax3, ax4, f, a, b, c, d, x_samples, y_samples, f_samples)
    % Plot double integral results
    
    try
        % Plot 1: Function surface
        cla(ax1);
        [X, Y] = meshgrid(linspace(a, b, 30), linspace(c, d, 30));
        Z = f(X, Y);
        surf(ax1, X, Y, Z, 'FaceAlpha', 0.8);
        xlabel(ax1, 'x'); ylabel(ax1, 'y'); zlabel(ax1, 'f(x,y)');
        title(ax1, 'Function Surface');
        colorbar(ax1);
        
        % Plot 2: Sample points colored by function value
        cla(ax2);
        n_show = min(1000, length(x_samples));
        idx_show = randperm(length(x_samples), n_show);
        scatter(ax2, x_samples(idx_show), y_samples(idx_show), 25, f_samples(idx_show), 'filled');
        xlabel(ax2, 'x'); ylabel(ax2, 'y');
        title(ax2, sprintf('Sample Points (N=%d)', length(x_samples)));
        colorbar(ax2);
        xlim(ax2, [a, b]); ylim(ax2, [c, d]);
        
        % Plot 3: Histogram of function values
        cla(ax3);
        histogram(ax3, f_samples, 50, 'FaceAlpha', 0.7);
        xlabel(ax3, 'Function Values');
        ylabel(ax3, 'Frequency');
        title(ax3, 'Value Distribution');
        grid(ax3, 'on');
        
        % Plot 4: Contour plot with sample points
        cla(ax4);
        contourf(ax4, X, Y, Z, 15);
        hold(ax4, 'on');
        scatter(ax4, x_samples(idx_show), y_samples(idx_show), 8, 'w.', 'MarkerEdgeAlpha', 0.6);
        xlabel(ax4, 'x'); ylabel(ax4, 'y');
        title(ax4, 'Contours + Samples');
        colorbar(ax4);
        
    catch ME
        % If plotting fails, show error message
        cla(ax1); text(ax1, 0.5, 0.5, 'Plot Error', 'HorizontalAlignment', 'center');
    end
end

function plotConvergenceResults(ax1, ax2, ax3, ax4, N_values, estimates, errors, exact, func_name)
    % Plot convergence analysis results
    
    % Plot 1: Estimates vs Sample Size
    cla(ax1);
    semilogx(ax1, N_values, estimates, 'bo-', 'LineWidth', 2, 'MarkerSize', 8);
    hold(ax1, 'on');
    semilogx(ax1, N_values, exact * ones(size(N_values)), 'r--', 'LineWidth', 2);
    xlabel(ax1, 'Sample Size');
    ylabel(ax1, 'Estimate');
    title(ax1, ['Convergence: ' func_name]);
    legend(ax1, 'MC Estimate', 'Exact', 'Location', 'best');
    grid(ax1, 'on');
    
    % Plot 2: Error vs Sample Size (Log-Log)
    cla(ax2);
    actual_errors = abs(estimates - exact);
    loglog(ax2, N_values, actual_errors, 'ro-', 'LineWidth', 2, 'MarkerSize', 8);
    hold(ax2, 'on');
    % Theoretical 1/sqrt(N) line
    theoretical = actual_errors(1) * sqrt(N_values(1)) ./ sqrt(N_values);
    loglog(ax2, N_values, theoretical, 'k--', 'LineWidth', 2);
    xlabel(ax2, 'Sample Size');
    ylabel(ax2, 'Absolute Error');
    title(ax2, 'Error Convergence');
    legend(ax2, 'Actual', 'O(1/√N)', 'Location', 'best');
    grid(ax2, 'on');
    
    % Plot 3: Error distribution
    cla(ax3);
    rel_errors = actual_errors ./ abs(exact) * 100;
    bar(ax3, 1:length(N_values), rel_errors);
    xlabel(ax3, 'Test Number');
    ylabel(ax3, 'Relative Error (%)');
    title(ax3, 'Relative Errors');
    set(ax3, 'XTickLabel', arrayfun(@(x) sprintf('%dk', x/1000), N_values, 'UniformOutput', false));
    grid(ax3, 'on');
    
    % Plot 4: Convergence rate
    cla(ax4);
    if length(N_values) > 1
        conv_rates = -diff(log(actual_errors)) ./ diff(log(N_values));
        plot(ax4, N_values(2:end), conv_rates, 'go-', 'LineWidth', 2, 'MarkerSize', 8);
        hold(ax4, 'on');
        plot(ax4, N_values(2:end), 0.5 * ones(size(N_values(2:end))), 'r--', 'LineWidth', 2);
        xlabel(ax4, 'Sample Size');
        ylabel(ax4, 'Convergence Rate');
        title(ax4, 'Rate Analysis');
        legend(ax4, 'Observed', 'Theoretical (0.5)', 'Location', 'best');
        grid(ax4, 'on');
    end
end

function test_functions = getTestFunctions()
    % Define test functions for batch processing
    test_functions = {
        % 1D Functions
        struct('func', @(x) x.^2, 'a', 0, 'b', 1, 'name', 'x²', 'exact', 1/3, 'type', '1D'),
        struct('func', @(x) sin(x), 'a', 0, 'b', pi, 'name', 'sin(x)', 'exact', 2, 'type', '1D'),
        struct('func', @(x) exp(x), 'a', 0, 'b', 1, 'name', 'eˣ', 'exact', exp(1)-1, 'type', '1D'),
        struct('func', @(x) 1./(1+x.^2), 'a', 0, 'b', 1, 'name', '1/(1+x²)', 'exact', pi/4, 'type', '1D'),
        struct('func', @(x) sqrt(x), 'a', 0, 'b', 4, 'name', '√x', 'exact', 16/3, 'type', '1D'),
        struct('func', @(x) x.^3, 'a', -1, 'b', 1, 'name', 'x³', 'exact', 0, 'type', '1D'),
        
        % 2D Functions
        struct('func', @(x,y) x.^2 + y.^2, 'a', 0, 'b', 1, 'c', 0, 'd', 1, 'name', 'x²+y²', 'exact', 2/3, 'type', '2D'),
        struct('func', @(x,y) sin(x).*cos(y), 'a', 0, 'b', pi/2, 'c', 0, 'd', pi/2, 'name', 'sin(x)cos(y)', 'exact', 1, 'type', '2D'),
        struct('func', @(x,y) x.*y, 'a', 0, 'b', 1, 'c', 0, 'd', 1, 'name', 'xy', 'exact', 1/4, 'type', '2D'),
        struct('func', @(x,y) exp(-(x.^2 + y.^2)), 'a', -1, 'b', 1, 'c', -1, 'd', 1, 'name', 'e^(-(x²+y²))', 'exact', pi*(1-exp(-1))^2, 'type', '2D'),
        struct('func', @(x,y) ones(size(x)), 'a', 0, 'b', 2, 'c', 0, 'd', 3, 'name', '1 (area)', 'exact', 6, 'type', '2D')
    };
end