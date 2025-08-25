function GeothermalANFISPredictionGUI()
    % MATLAB GUI for Geothermal Potential Prediction using trained ANFIS model
    % Includes integrated resistivity index calculator
    
    % Initialize main figure
    fig = figure('Name', 'Geothermal ANFIS Prediction & Resistivity Calculator', ...
                 'Position', [100, 100, 1000, 700], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'none', ...
                 'Resize', 'off', ...
                 'Color', [0.94 0.94 0.94]);
    
    % Global variables
    global anfisModel resistivityIndex
    anfisModel = [];
    resistivityIndex = NaN;
    
    % Create GUI components
    createGUIComponents(fig);
    
    % Initialize default values
    initializeDefaults();
end

function createGUIComponents(fig)
    % Create all GUI components
    
    % Title
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Geothermal Potential Prediction System', ...
              'Position', [300, 650, 400, 30], ...
              'FontSize', 16, ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    % Create main panels
    createModelPanel(fig);
    createResistivityPanel(fig);
    createInputPanel(fig);
    createResultsPanel(fig);
    createControlPanel(fig);
end

function createModelPanel(fig)
    % Panel for ANFIS model management
    
    uipanel('Parent', fig, ...
            'Title', 'ANFIS Model Management', ...
            'Position', [20, 580, 460, 60], ...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [0.94 0.94 0.94]);
    
    % Load Model Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Load Trained ANFIS Model', ...
              'Position', [40, 595, 150, 25], ...
              'Callback', @loadModelCallback, ...
              'FontSize', 9);
    
    % Model Status
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Status: No model loaded', ...
              'Position', [210, 595, 250, 25], ...
              'HorizontalAlignment', 'left', ...
              'Tag', 'modelStatus', ...
              'BackgroundColor', [0.94 0.94 0.94]);
end

function createResistivityPanel(fig)
    % Panel for resistivity calculation
    
    uipanel('Parent', fig, ...
            'Title', 'Integrated Resistivity Index Calculator', ...
            'Position', [500, 350, 480, 290], ...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [0.94 0.94 0.94]);
    
    % Resistivity depth labels and input fields
    depths = {'1700masl', '1500masl', '1000masl', '500masl', ...
              'sea level', '-500masl', '-1000masl', '-3000masl'};
    
    weights = [0.05, 0.05, 0.15, 0.10, 0.15, 0.20, 0.20, 0.10];
    
    descriptions = {'Too shallow', 'Cap rock zone', 'Upper reservoir boundary', ...
                   'Intermediate zone', 'Central reservoir indicator', ...
                   'Strong geothermal layer', 'Strong geothermal layer', 'Deep anomaly'};
    
    % Create input fields in a 2x4 grid
    for i = 1:8
        row = ceil(i/2);
        col = mod(i-1, 2) + 1;
        
        x_pos = 520 + (col-1) * 230;
        y_pos = 610 - (row-1) * 60;
        
        % Depth label
        uicontrol('Parent', fig, ...
                  'Style', 'text', ...
                  'String', depths{i}, ...
                  'Position', [x_pos, y_pos, 80, 15], ...
                  'HorizontalAlignment', 'left', ...
                  'FontWeight', 'bold', ...
                  'BackgroundColor', [0.94 0.94 0.94]);
        
        % Weight and description
        uicontrol('Parent', fig, ...
                  'Style', 'text', ...
                  'String', sprintf('(w=%.2f) %s', weights(i), descriptions{i}), ...
                  'Position', [x_pos, y_pos-15, 200, 12], ...
                  'HorizontalAlignment', 'left', ...
                  'FontSize', 8, ...
                  'ForegroundColor', [0.5 0.5 0.5], ...
                  'BackgroundColor', [0.94 0.94 0.94]);
        
        % Input field
        uicontrol('Parent', fig, ...
                  'Style', 'edit', ...
                  'Position', [x_pos + 120, y_pos-2, 80, 20], ...
                  'Tag', ['resist_' num2str(i)], ...
                  'BackgroundColor', 'white');
    end
    
    % Calculate Resistivity Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Calculate Resistivity Index', ...
              'Position', [600, 365, 180, 30], ...
              'Callback', @calculateResistivityCallback, ...
              'FontSize', 10, ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.2 0.6 0.2], ...
              'ForegroundColor', 'white');
    
    % Resistivity Result Display
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Integrated Resistivity Index: Not Calculated', ...
              'Position', [520, 340, 300, 15], ...
              'HorizontalAlignment', 'left', ...
              'Tag', 'resistivityResult', ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    % Clear Resistivity Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Clear', ...
              'Position', [800, 365, 60, 30], ...
              'Callback', @clearResistivityCallback, ...
              'FontSize', 9);
end

function createInputPanel(fig)
    % Panel for ANFIS input parameters
    
    uipanel('Parent', fig, ...
            'Title', 'ANFIS Model Inputs', ...
            'Position', [20, 200, 460, 370], ...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [0.94 0.94 0.94]);
    
    % Input parameter labels and fields
    labels = {'CO2 (ppm)', 'RN_222 (Bq/m³)', 'RN_220 (Bq/m³)', 'RN_222_CO2 Ratio', ...
              'RTD (°C)', 'TEMP15 (°C)', 'TEMP20 (°C)', 'T2-T1 (°C)', ...
              'Integrated Resistivity Index'};
    
    tags = {'co2', 'rn222', 'rn220', 'rn222_co2', 'rtd', 'temp15', 'temp20', 't2t1', 'resistivity_idx'};
    
    % Create input fields in a column layout
    for i = 1:9
        y_pos = 530 - (i-1) * 35;
        
        % Label
        uicontrol('Parent', fig, ...
                  'Style', 'text', ...
                  'String', labels{i}, ...
                  'Position', [40, y_pos, 200, 20], ...
                  'HorizontalAlignment', 'left', ...
                  'FontWeight', 'bold', ...
                  'BackgroundColor', [0.94 0.94 0.94]);
        
        % Input field
        editHandle = uicontrol('Parent', fig, ...
                              'Style', 'edit', ...
                              'Position', [250, y_pos, 100, 22], ...
                              'Tag', tags{i}, ...
                              'BackgroundColor', 'white', ...
                              'HorizontalAlignment', 'center');
        
        % Make resistivity index field read-only initially
        if i == 9
            set(editHandle, 'Enable', 'inactive', 'BackgroundColor', [0.9 0.9 0.9]);
        end
        
        % Units/info
        if i <= 8
            units = {'', '', '', '', '°C', '°C', '°C', '°C'};
            if i <= 4
                unitText = {'(ppm)', '(Bq/m³)', '(Bq/m³)', '(ratio)'};
                uicontrol('Parent', fig, ...
                          'Style', 'text', ...
                          'String', unitText{i}, ...
                          'Position', [360, y_pos, 60, 20], ...
                          'HorizontalAlignment', 'left', ...
                          'FontSize', 9, ...
                          'BackgroundColor', [0.94 0.94 0.94]);
            end
        else
            uicontrol('Parent', fig, ...
                      'Style', 'text', ...
                      'String', '(auto-calculated)', ...
                      'Position', [360, y_pos, 100, 20], ...
                      'HorizontalAlignment', 'left', ...
                      'FontSize', 8, ...
                      'ForegroundColor', [0.6 0.6 0.6], ...
                      'BackgroundColor', [0.94 0.94 0.94]);
        end
    end
end

function createResultsPanel(fig)
    % Panel for prediction results
    
    uipanel('Parent', fig, ...
            'Title', 'Prediction Results', ...
            'Position', [500, 200, 480, 140], ...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [0.94 0.94 0.94]);
    
    % Geothermal Potential Score
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Geothermal Potential Score:', ...
              'Position', [520, 300, 200, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold', ...
              'FontSize', 12, ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    uicontrol('Parent', fig, ...
              'Style', 'edit', ...
              'Position', [720, 298, 100, 25], ...
              'Tag', 'predictionScore', ...
              'FontSize', 14, ...
              'FontWeight', 'bold', ...
              'HorizontalAlignment', 'center', ...
              'Enable', 'inactive', ...
              'BackgroundColor', [1 1 0.8]);
    
    % Interpretation
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Interpretation:', ...
              'Position', [520, 270, 100, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'No prediction made', ...
              'Position', [620, 270, 300, 20], ...
              'HorizontalAlignment', 'left', ...
              'Tag', 'interpretation', ...
              'FontSize', 11, ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    % Confidence Level
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Model Inputs Status:', ...
              'Position', [520, 240, 130, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Incomplete', ...
              'Position', [650, 240, 200, 20], ...
              'HorizontalAlignment', 'left', ...
              'Tag', 'inputStatus', ...
              'ForegroundColor', [0.8 0.2 0.2], ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    % Additional Info
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Note: All 9 input parameters must be provided for accurate prediction', ...
              'Position', [520, 215, 400, 15], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 8, ...
              'ForegroundColor', [0.5 0.5 0.5], ...
              'BackgroundColor', [0.94 0.94 0.94]);
end

function createControlPanel(fig)
    % Panel for control buttons
    
    uipanel('Parent', fig, ...
            'Title', 'Controls', ...
            'Position', [20, 50, 960, 140], ...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'BackgroundColor', [0.94 0.94 0.94]);
    
    % Predict Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'RUN ANFIS PREDICTION', ...
              'Position', [50, 120, 200, 40], ...
              'Callback', @runPredictionCallback, ...
              'FontSize', 12, ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [0.1 0.4 0.8], ...
              'ForegroundColor', 'white');
    
    % Clear All Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Clear All Inputs', ...
              'Position', [270, 120, 120, 40], ...
              'Callback', @clearAllCallback, ...
              'FontSize', 10);
    
    % Export Results Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Export Results', ...
              'Position', [410, 120, 120, 40], ...
              'Callback', @exportResultsCallback, ...
              'FontSize', 10);
    
    % Load Sample Data Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Load Sample Data', ...
              'Position', [550, 120, 120, 40], ...
              'Callback', @loadSampleDataCallback, ...
              'FontSize', 10);
    
    % Help Button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Help', ...
              'Position', [690, 120, 80, 40], ...
              'Callback', @showHelpCallback, ...
              'FontSize', 10);
    
    % Status Bar
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Ready - Load ANFIS model and enter parameters to begin', ...
              'Position', [50, 70, 700, 20], ...
              'HorizontalAlignment', 'left', ...
              'Tag', 'statusBar', ...
              'FontSize', 10, ...
              'BackgroundColor', [0.94 0.94 0.94]);
    
    % Formula Display
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Resistivity Formula: Index = (Σ wi × 1/Ri) / (Σ wi), where wi = geological weights, Ri = resistivity values', ...
              'Position', [50, 90, 800, 15], ...
              'HorizontalAlignment', 'left', ...
              'FontSize', 8, ...
              'ForegroundColor', [0.4 0.4 0.4], ...
              'BackgroundColor', [0.94 0.94 0.94]);
end

function initializeDefaults()
    % Initialize default values and settings
    updateStatusBar('System initialized - Load ANFIS model to begin');
end

% Callback Functions

function loadModelCallback(~, ~)
    % Load trained ANFIS model
    global anfisModel
    
    modelPath = 'C:\Users\Kabi\Documents\MATLAB\code\eureka\fullgps.fis';
    
    if ~exist(modelPath, 'file')
        errordlg(['Model file not found: ' modelPath], 'File Error');
        return;
    end
    
    try
        % Load the FIS model directly
        anfisModel = readfis(modelPath);
        
        % Update status
        modelStatus = findobj('Tag', 'modelStatus');
        set(modelStatus, 'String', 'Status: Model loaded - fullgps.fis', ...
            'ForegroundColor', [0 0.6 0]);
        
        updateStatusBar('ANFIS model loaded successfully');
        
        msgbox('ANFIS model loaded successfully from: fullgps.fis', 'Success');
        
    catch ME
        errordlg(['Error loading ANFIS model: ' ME.message], 'Error');
        updateStatusBar('Error loading ANFIS model');
    end
end

function calculateResistivityCallback(~, ~)
    % Calculate integrated resistivity index
    global resistivityIndex
    
    try
        % Geological weights (from the Python code)
        weights = [0.05, 0.05, 0.15, 0.10, 0.15, 0.20, 0.20, 0.10];
        
        % Get resistivity values from input fields
        resistivities = zeros(1, 8);
        validCount = 0;
        
        for i = 1:8
            editHandle = findobj('Tag', ['resist_' num2str(i)]);
            value = str2double(get(editHandle, 'String'));
            
            if ~isnan(value) && value > 0
                resistivities(i) = value;
                validCount = validCount + 1;
            else
                resistivities(i) = NaN;
            end
        end
        
        if validCount == 0
            errordlg('Please enter at least one valid resistivity value (> 0)', 'Input Error');
            return;
        end
        
        % Calculate weighted harmonic mean (from Python code)
        validMask = ~isnan(resistivities) & resistivities > 0;
        validResistivities = resistivities(validMask);
        validWeights = weights(validMask);
        
        % Apply formula: Σ(wi * 1/Ri) / Σ(wi)
        weightedInverseSum = sum(validWeights ./ validResistivities);
        totalWeight = sum(validWeights);
        resistivityIndex = weightedInverseSum / totalWeight;
        
        % Update displays
        resultHandle = findobj('Tag', 'resistivityResult');
        set(resultHandle, 'String', sprintf('Integrated Resistivity Index: %.6f', resistivityIndex), ...
            'ForegroundColor', [0 0.6 0]);
        
        % Update the input field in ANFIS inputs
        resistivityInputHandle = findobj('Tag', 'resistivity_idx');
        set(resistivityInputHandle, 'String', sprintf('%.6f', resistivityIndex), ...
            'BackgroundColor', [0.8 1 0.8]);
        
        updateStatusBar(sprintf('Resistivity index calculated: %.6f (using %d depth values)', ...
            resistivityIndex, validCount));
        
        % Update input status
        updateInputStatus();
        
    catch ME
        errordlg(['Error calculating resistivity index: ' ME.message], 'Calculation Error');
        updateStatusBar('Error in resistivity calculation');
    end
end

function clearResistivityCallback(~, ~)
    % Clear all resistivity input fields
    global resistivityIndex
    
    for i = 1:8
        editHandle = findobj('Tag', ['resist_' num2str(i)]);
        set(editHandle, 'String', '');
    end
    
    % Clear results
    resultHandle = findobj('Tag', 'resistivityResult');
    set(resultHandle, 'String', 'Integrated Resistivity Index: Not Calculated', ...
        'ForegroundColor', [0 0 0]);
    
    % Clear resistivity input in ANFIS section
    resistivityInputHandle = findobj('Tag', 'resistivity_idx');
    set(resistivityInputHandle, 'String', '', 'BackgroundColor', [0.9 0.9 0.9]);
    
    resistivityIndex = NaN;
    updateStatusBar('Resistivity inputs cleared');
    updateInputStatus();
end

function runPredictionCallback(~, ~)
    % Run ANFIS prediction
    global anfisModel resistivityIndex
    
    if isempty(anfisModel)
        errordlg('Please load a trained ANFIS model first!', 'Model Error');
        return;
    end
    
    try
        % Get all input values
        inputTags = {'co2', 'rn222', 'rn220', 'rn222_co2', 'rtd', 'temp15', 'temp20', 't2t1', 'resistivity_idx'};
        inputs = zeros(1, 9);
        validInputs = true;
        
        for i = 1:9
            editHandle = findobj('Tag', inputTags{i});
            value = str2double(get(editHandle, 'String'));
            
            if isnan(value)
                validInputs = false;
                break;
            end
            inputs(i) = value;
        end
        
        if ~validInputs
            errordlg('All input parameters must have valid numeric values!', 'Input Error');
            return;
        end
        
        % Run ANFIS prediction
        prediction = evalfis(anfisModel, inputs);
        
        % Display prediction
        predictionHandle = findobj('Tag', 'predictionScore');
        set(predictionHandle, 'String', sprintf('%.4f', prediction), ...
            'BackgroundColor', [0.8 1 0.8]);
        
        % Interpret result
        interpretation = interpretGeothermalScore(prediction);
        interpretationHandle = findobj('Tag', 'interpretation');
        set(interpretationHandle, 'String', interpretation.text, ...
            'ForegroundColor', interpretation.color);
        
        updateStatusBar(sprintf('Prediction completed: %.4f (%s)', prediction, interpretation.text));
        
    catch ME
        errordlg(['Error running ANFIS prediction: ' ME.message], 'Prediction Error');
        updateStatusBar('Error in ANFIS prediction');
    end
end

function interpretation = interpretGeothermalScore(score)
    % Interpret geothermal potential score
    if score >= 80
        interpretation.text = 'Excellent Geothermal Potential';
        interpretation.color = [0 0.8 0];
    elseif score >= 65
        interpretation.text = 'Good Geothermal Potential';
        interpretation.color = [0.5 0.7 0];
    elseif score >= 50
        interpretation.text = 'Moderate Geothermal Potential';
        interpretation.color = [0.8 0.6 0];
    elseif score >= 35
        interpretation.text = 'Low Geothermal Potential';
        interpretation.color = [0.8 0.4 0];
    else
        interpretation.text = 'Very Low Geothermal Potential';
        interpretation.color = [0.8 0 0];
    end
end

function clearAllCallback(~, ~)
    % Clear all input fields and results
    
    % Clear ANFIS inputs
    inputTags = {'co2', 'rn222', 'rn220', 'rn222_co2', 'rtd', 'temp15', 'temp20', 't2t1'};
    for i = 1:8
        editHandle = findobj('Tag', inputTags{i});
        set(editHandle, 'String', '');
    end
    
    % Clear resistivity inputs
    clearResistivityCallback();
    
    % Clear results
    predictionHandle = findobj('Tag', 'predictionScore');
    set(predictionHandle, 'String', '', 'BackgroundColor', [1 1 0.8]);
    
    interpretationHandle = findobj('Tag', 'interpretation');
    set(interpretationHandle, 'String', 'No prediction made', 'ForegroundColor', [0 0 0]);
    
    updateStatusBar('All inputs and results cleared');
    updateInputStatus();
end

function loadSampleDataCallback(~, ~)
    % Load sample data for testing
    
    % Sample geothermal data
    sampleData = struct();
    sampleData.co2 = 850;
    sampleData.rn222 = 1250;
    sampleData.rn220 = 680;
    sampleData.rn222_co2 = 1.47;
    sampleData.rtd = 25.8;
    sampleData.temp15 = 18.5;
    sampleData.temp20 = 19.2;
    sampleData.t2t1 = 0.7;
    
    % Sample resistivity values
    sampleResistivity = [120, 95, 45, 25, 15, 8, 12, 35];
    
    % Load ANFIS inputs
    inputTags = {'co2', 'rn222', 'rn220', 'rn222_co2', 'rtd', 'temp15', 'temp20', 't2t1'};
    fields = fieldnames(sampleData);
    
    for i = 1:length(inputTags)
        editHandle = findobj('Tag', inputTags{i});
        set(editHandle, 'String', num2str(sampleData.(fields{i})));
    end
    
    % Load resistivity values
    for i = 1:8
        editHandle = findobj('Tag', ['resist_' num2str(i)]);
        set(editHandle, 'String', num2str(sampleResistivity(i)));
    end
    
    updateStatusBar('Sample data loaded');
    updateInputStatus();
    
    msgbox('Sample data loaded successfully! You can now calculate resistivity and run prediction.', 'Sample Data');
end

function exportResultsCallback(~, ~)
    % Export current results to file
    
    try
        % Get current values
        inputTags = {'co2', 'rn222', 'rn220', 'rn222_co2', 'rtd', 'temp15', 'temp20', 't2t1', 'resistivity_idx'};
        inputLabels = {'CO2', 'RN_222', 'RN_220', 'RN_222_CO2', 'RTD', 'TEMP15', 'TEMP20', 'T2-T1', 'Resistivity_Index'};
        
        predictionHandle = findobj('Tag', 'predictionScore');
        interpretationHandle = findobj('Tag', 'interpretation');
        
        prediction = get(predictionHandle, 'String');
        interpretation = get(interpretationHandle, 'String');
        
        % Create results structure
        results = struct();
        results.Timestamp = datestr(now);
        
        for i = 1:9
            editHandle = findobj('Tag', inputTags{i});
            value = get(editHandle, 'String');
            if ~isempty(value)
                results.(inputLabels{i}) = str2double(value);
            else
                results.(inputLabels{i}) = NaN;
            end
        end
        
        results.Geothermal_Score = prediction;
        results.Interpretation = interpretation;
        
        % Save to file
        [filename, pathname] = uiputfile('*.mat', 'Save results as...');
        if ~isequal(filename, 0)
            save(fullfile(pathname, filename), 'results');
            msgbox(['Results exported to: ' fullfile(pathname, filename)], 'Export Success');
            updateStatusBar(['Results exported to: ' filename]);
        end
        
    catch ME
        errordlg(['Error exporting results: ' ME.message], 'Export Error');
    end
end

function showHelpCallback(~, ~)
    % Show help information
    
    helpText = {
        'Geothermal ANFIS Prediction System - Help'
        ''
        '1. LOAD ANFIS MODEL:'
        '   - Click "Load Trained ANFIS Model" to load your .fis file'
        '   - The model should be a trained ANFIS (fuzzy inference system) object'
        ''
        '2. CALCULATE RESISTIVITY INDEX:'
        '   - Enter resistivity values for different depths'
        '   - At least one value is required'
        '   - Click "Calculate Resistivity Index"'
        '   - The calculated index will auto-fill in ANFIS inputs'
        ''
        '3. ENTER ANFIS INPUTS:'
        '   - Fill in all 8 geothermal parameters'
        '   - Resistivity index is auto-calculated'
        '   - All fields must have valid numbers'
        ''
        '4. RUN PREDICTION:'
        '   - Click "RUN ANFIS PREDICTION"'
        '   - View results in the Results panel'
        ''
        '5. ADDITIONAL FEATURES:'
        '   - Load Sample Data: Test with sample values'
        '   - Clear All: Reset all inputs and results'
        '   - Export Results: Save current session to .mat file'
        ''
        'INPUT PARAMETERS (in order):'
        '1. CO2 (ppm) - Carbon dioxide concentration'
        '2. RN_222 (Bq/m³) - Radon-222 activity'
        '3. RN_220 (Bq/m³) - Radon-220 activity'
        '4. RN_222_CO2 - Ratio of Radon-222 to CO2'
        '5. RTD (°C) - Rock temperature at depth'
        '6. TEMP15 (°C) - Temperature at 15cm depth'
        '7. TEMP20 (°C) - Temperature at 20cm depth'
        '8. T2-T1 (°C) - Temperature difference'
        '9. Integrated Resistivity Index (calculated)'
        ''
        'RESISTIVITY DEPTHS:'
        '- 1700masl: Surface/shallow (weight: 0.05)'
        '- 1500masl: Cap rock zone (weight: 0.05)'
        '- 1000masl: Upper reservoir (weight: 0.15)'
        '- 500masl: Intermediate zone (weight: 0.10)'
        '- Sea level: Central reservoir (weight: 0.15)'
        '- -500masl: Strong geothermal (weight: 0.20)'
        '- -1000masl: Strong geothermal (weight: 0.20)'
        '- -3000masl: Deep anomaly (weight: 0.10)'
        ''
        'SCORE INTERPRETATION:'
        '≥ 80: Excellent Geothermal Potential'
        '65-80: Good Geothermal Potential'
        '50-65: Moderate Geothermal Potential'
        '35-50: Low Geothermal Potential'
        '< 35: Very Low Geothermal Potential'
    };
    
    % Create help dialog
    helpFig = figure('Name', 'Help - Geothermal ANFIS System', ...
                     'Position', [200, 200, 600, 500], ...
                     'MenuBar', 'none', ...
                     'ToolBar', 'none', ...
                     'Resize', 'off');
    
    uicontrol('Parent', helpFig, ...
              'Style', 'listbox', ...
              'String', helpText, ...
              'Position', [20, 60, 560, 420], ...
              'FontSize', 9, ...
              'Max', length(helpText), ...
              'Enable', 'inactive');
    
    uicontrol('Parent', helpFig, ...
              'Style', 'pushbutton', ...
              'String', 'Close', ...
              'Position', [270, 20, 60, 30], ...
              'Callback', @(~,~) close(helpFig));
end

function updateInputStatus()
    % Update the input status display
    
    inputTags = {'co2', 'rn222', 'rn220', 'rn222_co2', 'rtd', 'temp15', 'temp20', 't2t1', 'resistivity_idx'};
    completedInputs = 0;
    
    for i = 1:9
        editHandle = findobj('Tag', inputTags{i});
        value = get(editHandle, 'String');
        if ~isempty(value) && ~isnan(str2double(value))
            completedInputs = completedInputs + 1;
        end
    end
    
    statusHandle = findobj('Tag', 'inputStatus');
    
    if completedInputs == 9
        set(statusHandle, 'String', 'Complete (9/9 parameters)', ...
            'ForegroundColor', [0 0.6 0]);
    else
        set(statusHandle, 'String', sprintf('Incomplete (%d/9 parameters)', completedInputs), ...
            'ForegroundColor', [0.8 0.2 0.2]);
    end
end

function updateStatusBar(message)
    % Update the status bar message
    statusHandle = findobj('Tag', 'statusBar');
    if ~isempty(statusHandle)
        timestamp = datestr(now, 'HH:MM:SS');
        set(statusHandle, 'String', sprintf('[%s] %s', timestamp, message));
    end
end

% Additional utility functions for enhanced functionality

function validateNumericInput(src, ~)
    % Validate numeric input in real-time
    value = get(src, 'String');
    if ~isempty(value) && isnan(str2double(value))
        set(src, 'BackgroundColor', [1 0.8 0.8]); % Light red for invalid
        updateStatusBar('Invalid numeric input detected');
    else
        set(src, 'BackgroundColor', 'white'); % White for valid
        updateInputStatus();
    end
end

function setupInputValidation()
    % Setup real-time input validation for all numeric fields
    inputTags = {'co2', 'rn222', 'rn220', 'rn222_co2', 'rtd', 'temp15', 'temp20', 't2t1'};
    
    for i = 1:8
        editHandle = findobj('Tag', inputTags{i});
        set(editHandle, 'Callback', @validateNumericInput);
    end
    
    % Also setup for resistivity fields
    for i = 1:8
        editHandle = findobj('Tag', ['resist_' num2str(i)]);
        set(editHandle, 'Callback', @validateNumericInput);
    end
end