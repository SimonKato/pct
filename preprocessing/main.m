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
%       createOri
%
%Examples: 
%   main segmentPM datasetPath='../../data/Perfusion\ Maps' outputPath='../../data/segmentedPerfusion\ Maps' segmentPM
%
%Important Notes:
%   Most of the current functions will create a special folder within the
%   outputPath path appropiately named after the function called. Subject
%   to change, however for the sake of calling multiple functions at once,
%   this works best.
%
%Alternative to using main.m is to create a script which calls the
%functions which you need. The script must be in the same folder as the
%functions you wish to use, this can be done with having script.m in the
%same folder from the getgo, or cd() into folder as needed. Script might be
%better?
%

function main(varargin) 

%%%%%%%%%%%%%%%%%%%%%%%%%%Generating Default variable values%%%%%%%%%%%%%%%

datasetPath = '../data/processed'; %consider having a way of putting a dataset as an input parameter
outputPath = '../data/results'; %consider checking if it has been created
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
        if ~strcmp(datasetPath(end),'\')
            datasetPath = [datasetPath '\'];
        end
    elseif contains(curArg, 'outputPath=')
        lastIndex = find(curArg == '=', 1);
        outputPath = curArg(lastIndex + 1:length(curArg));
        if ~strcmp(outputPath(end),'\')
            outputPath = [outputPath '\'];
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
outputPath = createPath(outputPath);

if deidentify
    deidentify(datasetPath, outputPath)
    
    datasetPath = outputPath;
end

if createGT && createOri
    try
        mkdir(outputPath,'vol_ori');
    catch
    end
    
    try
        mkdir(outputPath,'GT');
    catch
    end
    
    createOriFile(datasetPath, strcat(outputPath, 'vol_ori'));
    createGTFile(strcat(outputPath,'vol_ori'),strcat(outputPath,'GT'));
elseif createOri
    try
        mkdir(outputPath,'vol_ori');
    catch
    end
    
     createOriFile(datasetPath, strcat(outputPath,'vol_ori'));
elseif createGT
    try
        mkdir(outputPath,'GT');
    catch
    end
    
    createGTFile(datasetPath,strcat(outputPath, 'GT'));
end

if segmentPM
    try
        mkdir(outputPath,'segmented_perfusion_maps');
    catch
    end
    segmentPerfusionMaps(datasetPath, strcat(outputPath,'segmented_perfusion_maps'))
end

if convertNCCT
    try
        mkdir(outputPath,'NCCTdicom_mit');
    catch
    end
    convertNCCT_MAT(datasetPath,strcat(outputPath,'NCCTdicom_mit'))
end

end