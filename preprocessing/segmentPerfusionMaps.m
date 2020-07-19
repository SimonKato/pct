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

patients = fixDir(inputFolder);
for patient = 1 : length(patients)
    
    patientPics = dir(strcat(inputFolder,patients.patient.name));
    patientPics = fixDir(patientPics);
    
    mkdir(strcat(outputFolder,'patient_',num2str(patient)))
    tempOutput = strcat(outputFolder,'patient_',num2str(patient),'/');
    
    for imageNum = 1: length(patientPics)
        filepath = fullfile(inputFolder, patientPics(imageNum).name);
        fileImage = dicomread(filepath);
    
        rCBF = fileImage(1:512,1:512,:);
        MTT =  fileImage(1:512,513:1024,:);
        Delay = fileImage(1:512,1025:1536,:);
        rCBF_SVD = fileImage(513:1024,1:512,:);
        MTT_SVD = fileImage(513:1024, 513:1024,:);
        Delay_SVD = fileImage(513:1024, 1025:1536, :);
    
    
        save(strcat(tempOutput,'rCBF_',num2str(imageNum)),'rCBF');
        save(strcat(tempOutput,'MTT_',num2str(imageNum)),'MTT');
        save(strcat(tempOutput,'Delay_',num2str(imageNum)),'Delay');
        save(strcat(tempOutput,'rCBF_SVD_',num2str(imageNum)),'rCBF_SVD');
        save(strcat(tempOutput,'MTT_SVD_',num2str(imageNum)),'MTT_SVD');
        save(strcat(tempOutput,'Delay_SVD_',num2str(imageNum)),'Delay_SVD');
    end
end