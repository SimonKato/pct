function createGTFile(datasetPath, outputFolder)
patients = dir(datasetPath);
patients = fixDir(patients);

%mkdir (fullfile(outputFolder ,'/','CTP_vol_GT'));

for i = 1: length(patients)
    patient = patients(i);
    
    subDirs = dir(fullfile(datasetPath, '/', patient.name, '/'));
    subDirs = fixDir(subDirs);
    
    for j = 1 : length(subDirs)
        if strcmp(subDirs(j).name, 'CTP_vol_ori')
            inputFolder = dir(fullfile(datasetPath, patient.name, '/', subDirs(j).name));
            inputFolder = fixDir(inputFolder);
            
            for fileNum = 1 : length(inputFolder)

                CTP_vol_ori = fullfile(datasetPath, inputFolder(fileNum).name);

                [Y,X,T,S] = size(CTP_vol_ori);

                img=squeeze(CTP_vol_ori(:,:,1,1));
                mask = pct_brainMask(img,Wl,Wh,mask_val);
                labeledImage = logical(mask);
                boxMesurements=regionprops(labeledImage,'BoundingBox');
                firstBlobsBoundingBox = boxMesurements.BoundingBox;

                for s_i=1:S
                    for t_i=1:T
                    currentImg=squeeze(CTP_vol_ori(:,:,t_i,s_i));
                    currentMask = pct_brainMask(currentImg,Wl,Wh,mask_val); 
                    labeledImage = logical(currentMask);
                blobMeasurements = regionprops(labeledImage, 'BoundingBox');
                    thisBlobsBoundingBox = blobMeasurements.BoundingBox;
                    adjustBox(firstBlobsBoundingBox,thisBlobsBoundingBox);
                    end
                end

                CTP_vol_GT = zeros(firstBlobsBoundingBox(4)+1,firstBlobsBoundingBox(3)+1,T,S);

                for s_i=1:S
                    for t_i=1:T
                    finalImg=squeeze(CTP_vol_ori(:,:,t_i,s_i));
                    img_inRange = uint8(double(finalImg)/contrast_h*160);
                    mask = pct_brainMask(finalImg,Wl,Wh,mask_val);   
                    img_brain = mask .* double(img_inRange);
                    CTP_vol_GT(:,:,t_i,s_i) = imcrop(img_brain, firstBlobsBoundingBox);
                    end
                end
            end
            
        save(fullfile(outputFolder ,strcat('CTP_vol_GT_',patient.name,'.mat')),'CTP_vol_GT');
        end
    end

end