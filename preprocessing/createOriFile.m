function createOriFile(datasetPath, outputFolder)
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
        if strcmp(subDirs(j).name, 'Perfusion_05_CE_Perfusion_Head_4D_CBP_DYNAMIC_3')
            inputFolder = dir(fullfile(datasetPath, patient.name, '/', tempDir.name, '/', subDirs(j).name));
            inputFolder = fixDir(inputFolder);
            
            contrast_l = 0; contrast_h = 160;      
            rescaleIntercept = 0;
            CTP_vol_ori = zeros(512,512,21,10);
            for t_i = 1:length(inputFolder)
                %% extract 3D dicom file
                data_ctp = squeeze(dicomread(fullfile(inputFolder(t_i).folder,inputFolder(t_i).name)));
                [Y,X,Z] = size(data_ctp);
                
                % select slice range along z-axis, and save for each t_i 
                CTP_vol_ori(:,:,t_i,:) = data_ctp(:,:,131:10:230);
            end
        save(fullfile(outputFolder ,strcat(patient.name, 'CTP_vol_ori.mat')),'CTP_vol_ori');
        end
    end

end
