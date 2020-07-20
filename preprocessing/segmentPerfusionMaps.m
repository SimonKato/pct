function segmentPerfusionMaps(inputFolder, outputFolder)
%Description: segments all Perfusion Map files within inputFolder to 6
%segments: MIP, RCBV, TTP, rCBG, MTT, Delay maps *not sure if those are
%correct
%
%Input: inputFolder - folder with generated Perfusion Maps, string assumed
%
%Output: outputFolder - location of folder which the new 6 segmented maps
%will be saved to, can be same folder

inputFolder = createPath(inputFolder);
outputFolder = createPath(outputFolder);

if ~strcmp(inputFolder(end),'/')
    inputFolder = [inputFolder '/'];
end

if ~strcmp(outputFolder(end),'/')
    outputFolder = [outputFolder '/'];
end

%Creates the output folders%
mkdir(outputFolder, 'MIP')
mkdir(outputFolder,'rCBV')
mkdir(outputFolder,'TTP')
mkdir(outputFolder,'rCBF')
mkdir(outputFolder,'MTT')
mkdir(outputFolder,'Delay')

patients = fixDir(inputFolder);
for patientNum = 1 : length(patients)
    
    patientPics = dir(strcat(inputFolder,patients(patientNum).name));
    patientPics = fixDir(patientPics);
    
    for imageNum = 1: length(patientPics)
        filepath = fullfile(inputFolder, patients(patientNum).name, patientPics(imageNum).name);
        fileImage = dicomread(filepath);
        fileInfo = dicominfo(filepath);
        
        fileImage = fileInfo.RescaleSlope * fileImage + fileInfo.RescaleIntercept;
    
        MIP = fileImage(1:512,1:512,:);
        MIP = segmentPerfusionMap_IsolateImage(MIP);
        
        rCBV =  fileImage(1:512,513:1024,:);
        rCBV = segmentPerfusionMap_IsolateImage(rCBV);
        
        TTP = fileImage(1:512,1025:1536,:);
        TTP = segmentPerfusionMap_IsolateImage(TTP);
        
        rCBF = fileImage(513:1024,1:512,:);
        rCBF = segmentPerfusionMap_IsolateImage(rCBF);
        
        MTT = fileImage(513:1024, 513:1024,:);
        MTT = segmentPerfusionMap_IsolateImage(MTT);
        
        Delay = fileImage(513:1024, 1025:1536, :);
        Delay = segmentPerfusionMap_IsolateImage(Delay);
    
    
        save(strcat(outputFolder,'MIP/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'MIP');
        save(strcat(outputFolder,'rCBV/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'rCBV');
        save(strcat(outputFolder,'TTP/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'TTP');
        save(strcat(outputFolder,'rCBF/',num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'rCBF');
        save(strcat(outputFolder,'MTT/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'MTT');
        save(strcat(outputFolder,'Delay/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'Delay');
    end
end