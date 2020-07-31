function SeparateNCCT(datasetPath, outputPath)
datasetPath = createPath(datasetPath);
outputPath = createPath(outputPath);

try
    mkdir(outputPath, 'NCCT')
    outputPath = strcat(outputPath,'NCCT/');
catch
end

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
         if contains(tempName, 'W-O') || contains(tempName, '5.0_Head')
            files = dir(fullfile(datasetPath, patient.name, '/', tempDir.name, '/', subDirs(j).name));
            files = fixDir(files);
            
            outputFolder = strcat(outputPath, patient.name, '_NCCT/');
            mkdir(outputFolder) 
            
            for fileNum = 1 : length(files)
                curFile = strcat(datasetPath, patient.name, '/', tempDir.name, '/', subDirs(j).name, '/', files(fileNum).name);
                %fileInfo = dicominfo(fullfile(curFile));                
                outputFile = strcat(outputFolder, files(fileNum).name);
                copyfile(curFile,outputFile)
            end
         end
    end
end
end