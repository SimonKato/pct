%Instructions for use:
%   1) Make sure all functions are in the same folder as main
%
%   2) Within matlab command window type main [-arguments]
%
% Current arguments:
%   Paths: ***Paths with spaces will not work ie folders with spaces will
%   cause error
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
%   main segmentPM datasetPath=../../data/PerfusionMaps outputPath=../../data/segmentedPerfusionMaps segmentPM

function main(varargin) 

%%%%%%%%%%%%%%%%%%%%%%%%%%Generating Default variable values%%%%%%%%%%%%%%%

datasetPath = '../data/'; %consider having a way of putting a dataset as an input parameter
outputPath = '../data/output/';
numInputs = size(varargin);
numArgs = numInputs(2);
createOri = false; 
createGT = false;
convertNCCT = false;
segmentPM = false;

%%%%%%%%%%%%%%%%%%%%%%Checking input arguments%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1: length(numArgs)
    if strcmpi(varargin{i}, 'ori') %input argument
        createOri = true;
    elseif strcmpi(varargin{i}, 'gt') %input argument
        createGT = true;
    elseif contains(varargin{i}, 'datasetPath=')
        lastIndex = find(varargin{i} == '=', 1);
        datasetPath = varargin{i}(lastIndex:length(varargin{i}));
        if ~strcmp(datasetPath(end),'/')
            datasetPath = [inputFolder '/'];
        end
    elseif contains(varargin{i}, 'outputPath=')
        lastIndex = find(varargin{i} == '=', 1);
        datasetPath = varargin{i}(lastIndex:length(varargin{i}));
        if ~strcmp(outputPath(end),'/')
            outputPath = [inputFolder '/'];
        end
    elseif strcmpi(varargin{i}, 'segmentPM')
        segmentPM = true;
    elseif strcmpi(varargin{i}, 'convertNCCT')
        convertNCCT = true;
    end
end

datasetPath = createPath(datasetPath);

if createOri
elseif createGT
elseif segmentPM
    segmentPerfusionMaps(datasetPath, outputPath)
elseif convertNCCT
    convertNCCT_MAT(datasetPath,outputPath)
end

end