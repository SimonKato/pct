function SeparatePM(datasetPath, outputPath)

datasetPath = createPath(datasetPath);
outputPath = createPath(outputPath);

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
                        %Separate these files into a new folder.
                        %Issue with some of the perfusion maps having this
                        %field
                        outputFile = strcat(outputFolder, files(fileNum).name);
                        copyfile(curFile,outputFile)
                    end
                end
            end
         end
    end
end
end