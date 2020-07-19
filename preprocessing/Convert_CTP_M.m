%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Keyword for CTP needs to be added, see down below
%How should folders be structured? Should the image be written to the same
%place or do we want to put it somewhere else?
%What do we do if a file is not a CTP? Ignore it?
%Add code to convert
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;



%datasetPath = '/Users/neevasethi/subjectData';  %Edit Path to inside location of dataset
datasetPath = '../data/';
checkEmptyDirs = dir(datasetPath);
dirIndex = 1;  % For Print statements and keeping track of row number in Summary 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Remove Empty Directories%%%%%%%%%%%%%%%%%%%%%%%
for i = 3: length(checkEmptyDirs)
    try
        rmdir (fullfile(datasetPath, '/', checkEmptyDirs(i).name));
    catch
    end
end

patients = dir(datasetPath);
patients = fixDir(patients);

for i = 1 : length(patients)
    %fprintf('--------------------------------------Starting with Directory %i-----------------------------------\n', dirIndex);
    
    patient = patients(i);
    tempDirs = dir(fullfile(datasetPath, '/' , patient.name));
    tempDirs = fixDir(tempDirs);
    tempDir = tempDirs(1);
    
    subDirs = dir(fullfile(datasetPath, '/', patient.name, '/', tempDir.name));
    subDirs = fixDir(subDirs);
    
    for j = 1 : length(subDirs)
        if strcmp(subDirs(j).name,'Perfusion_05_CE_Perfusion_Head_4D_CBP_DYNAMIC_3')
            files_dcm = dir(fullfile(datasetPath, '/', patient.name, '/', tempDir.name, '/', subDirs(j).name));
            files_dcm = fixDir(files_dcm);
            contrast_l = 0; contrast_h = 160;      
            rescaleIntercept = 0;
            CTP_vol_ori = zeros(512,512,21,10);
            for t_i = 1:length(files_dcm)
                %% extract 3D dicom file
                data_ctp = squeeze(dicomread(fullfile(files_dcm(t_i).folder,files_dcm(t_i).name)));
                [Y,X,Z] = size(data_ctp);
                
                % select slice range along z-axis, and save for each t_i 
                CTP_vol_ori(:,:,t_i,:) = data_ctp(:,:,131:10:230);
            end
            mkdir (fullfile(datasetPath, patient.name,'/','CTP_vol_ori'));
            save(fullfile(datasetPath, patient.name, '/', 'CTP_vol_ori','/', 'CTP_vol_ori.mat'),'CTP_vol_ori');
        end
    end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('--------------------------------------Done with Directory %i-----------------------------------\n', dirIndex)
        dirIndex = dirIndex + 1;
end

function correctDir = fixDir(tempDir)
tempLength = length(tempDir);
    for tempIndex = 1 : tempLength - 1
        if contains(tempDir(tempLength - tempIndex).name, '.')
            tempDir(tempLength - tempIndex) = [];
        end
    end
    correctDir = tempDir;
end
