function SeparatePM(datasetPath, outputPath)
%----------------------------------------
% Created by Garrett Fullerton and Simon Kato
% University of Florida, Dept. of Biomedical Engineering
% Smart Medical Informatics Learning and Evaluation (SMILE) Laboratory
% Dr. Ruogu Fang
% 6/1/2020
%----------------------------------------
% datasetPath: relative/absolute path to folder which contains deidentified patients and which follows structure created by deidentify_dataset.m
% outputPath: relative/absolute path to destination where perfusion maps should be copied to.
%
% Last Updated: 8/20/2020 by SK
% Bug fixes

datasetPath = createPath(datasetPath);
outputPath = createPath(outputPath);

if ~exist(outputPath,'dir'), mkdir(outputPath); end

patients = dir(datasetPath);
patients = fixDir(patients);

for i = 1: length(patients)
    patient = patients(i);
    tempDirs = dir(fullfile(datasetPath, '/' , patient.name));

    tempDirs = fixDir(tempDirs);
    tempDir = tempDirs(1);
    
    subDirs = dir(fullfile(datasetPath, '/', patient.name, '/', tempDir.name));
    subDirs = fixDir(subDirs);
    
    for j = 1 : length(subDirs)
        tempName = subDirs(j).name;
        tempName = replace(tempName,' ','_');
         if contains(tempName, '0.5_CE_4D') || contains(tempName, '0.5_CE_Perfusion')
            files = dir(fullfile(datasetPath, patient.name, '/', tempDir.name, '/', subDirs(j).name));
            files = fixDir(files);
            
            outputFolder = strcat(outputPath, patient.name, '_perfusion_maps/');
            mkdir(outputFolder) 
            
            for fileNum = 1 : length(files)
                curFile = strcat(datasetPath, patient.name, '/', tempDir.name, '/', subDirs(j).name, '/', files(fileNum).name);
                fileInfo = dicominfo(fullfile(curFile));
                
                if strcmp(fileInfo.ImageType, 'DERIVED\SECONDARY\') 
                    if not(isfield(fileInfo, 'SpecificCharacterSet')) 
                        outputFile = strcat(outputFolder, files(fileNum).name);
                        copyfile(curFile,outputFile)
                    end
                end
            end
         end
    end
end
end
