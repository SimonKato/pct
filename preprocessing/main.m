%Instructions for use:
%   1) Make sure all functions are in the same folder as main
%
%   2) Within matlab command window type main [-arguments]
%
% Current arguments:
%   Paths: ***Paths with spaces must have \ before space.
%       datasetPath=(insert path to dataset relative or absolute path)
%           *default value = ../data/
%
%       outputPath=(insert path to where you'd like to have processed
%       material outputted relative or absolute path) *Currently assumes
%       output folder has been created
%           *default value = ../data/results/
%
%   Currently supported processing tools:
%       segmentPM : Segments perfusion maps into their 6 components
%       convertNCCT : converts NCCT image portion to .mat file type
%
%Examples: 
%   main segmentPM datasetPath='../../data/Perfusion\ Maps' outputPath='../../data/segmentedPerfusion\ Maps' segmentPM
%
%Important Notes:
%   Most of the current functions will create a special folder within the
%   outputFolder path appropiately named after the function called. Subject
%   to change, however for the sake of calling multiple functions at once,
%   this works best.
%

function main(varargin) 

%%%%%%%%%%%%%%%%%%%%%%%%%%Generating Default variable values%%%%%%%%%%%%%%%

datasetPath = '../data/'; %consider having a way of putting a dataset as an input parameter
outputPath = '../data/results/';
createOri = false; 
createGT = false;
convertNCCT = false;
segmentPM = false;
deidentify = false;

%%%%%%%%%%%%%%%%%%%%%%Checking input arguments%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for curArg = varargin %1 : numArgs
    %Consider using switch for readability
    curArg = char(curArg);
    
    if strcmpi(curArg, 'ori') %input argument
        createOri = true;
    elseif strcmpi(curArg, 'gt') %input argument
        createGT = true;
    elseif contains(curArg, 'datasetPath=')
        lastIndex = find(curArg == '=', 1);
        datasetPath = curArg(lastIndex + 1:length(curArg));
        if ~strcmp(datasetPath(end),'/')
            datasetPath = [datasetPath '/'];
        end
    elseif contains(curArg, 'outputPath=')
        lastIndex = find(curArg == '=', 1);
        datasetPath = curArg(lastIndex + 1:length(curArg));
        if ~strcmp(outputPath(end),'/')
            outputPath = [inputFolder '/'];
        end
    elseif strcmpi(curArg, 'segmentPM')
        segmentPM = true;
    elseif strcmpi(curArg, 'convertNCCT')
        convertNCCT = true;
    elseif strcmpi(curArg, 'deidentify')
        deidentify = true;
    end  
end

datasetPath = createPath(datasetPath);

if deidentify
    deidentify(datasetPath,outputFolder)
    
    datasetPath = outputFolder;
end

if createGT && createOri
    try
        mkdir(outputFolder,'vol_ori/');
    catch
    end
    
    try
        mkdir(outputFolder,'GT/');
    catch
    end
    
    createOriFile(datasetPath, strcat(outputFolder, 'vol_ori/'));
    createGTFile(strcat(outputFolder,'vol_ori/'),strcat(outputFolder,'GT/'));
elseif createOri
    try
        mkdir(outputFolder,'vol_ori/');
    catch
    end
    
    createOriFile(datasetPath, strcat(outputFolder,'vol_ori/'));
elseif createGT
    try
        mkdir(outputFolder,'GT/');
    catch
    end
    
    createGTFile(datasetPath,strcat(outputFolder, 'GT/'));
end

if segmentPM
    try
        mkdir(outputFolder,'segmented_perfusion_maps/');
    catch
    end
    segmentPerfusionMaps(datasetPath, strcat(outputPath,'segmented_perfusion_maps/'))
end

if convertNCCT
    try
        mkdir(outputFolder,'NCCTdicom_mit/');
    catch
    end
    convertNCCT_MAT(datasetPath,strcat(outputPath,'NCCTdicom_mit/'))
end

end