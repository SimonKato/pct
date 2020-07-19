function convertNCCT_MAT(inputFolder, outputFolder)
%Description: Converts NCCT files from inputFolder and saves it to .mat
%will save only the images, no metadata will be saved.
%
%Input: inputFolder - folder with NCCT images
%
%Output: outputFolder - location of folder which the .mat images will be
%located

if ~strcmp(inputFolder(end),'/')
    inputFolder = [inputFolder '/'];
end

if ~strcmp(outputFolder(end),'/')
    outputFolder = [outputFolder '/'];
end

inputFolder = createPath(inputFolder);
outputFolder = createPath(outputFolder);

inputDir = fixDir(inputFolder);

for imageNum = 1: length(inputDir)
    filepath = fullfile(inputFolder, inputDir(imageNum).name);
    fileImage = dicomread(filepath);
    
    save(strcat(outputFolder, '_', num2str(imageNum)),'fileImage')
end