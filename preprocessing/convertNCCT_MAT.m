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

try
    mkdir(outputFolder, 'NCCT_mat')
catch
end

inputFolder = createPath(inputFolder);
outputFolder = createPath(outputFolder);

patients = fixDir(inputFolder);

for patientNum = 1 : length(patients)
    
    patientPics = dir(strcat(inputFolder,patients(patientNum).name));
    patientPics = fixDir(patientPics);
    
    for imageNum = 1: length(patientPics)
        filepath = fullfile(inputFolder, patients(patientNum).name, patientPics(imageNum).name);
        fileImage = dicomread(filepath);
        fileInfo = dicominfo(filepath);
        
        fileImage = fileInfo.RescaleSlope * fileImage + fileInfo.RescaleIntercept;
    
        save(strcat(outputFolder, 'NCCT_mat/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'fileImage')
    end
end