function createGTFile(oriPath, outputFolder)

oriPath = createPath(oriPath);
outputFolder = createPath(outputFolder);

inputFolder = dir(oriPath);
inputFolder = fixDir(inputFolder);

Wl = 0; 
Wh = 120;
mask_val = 10;
contrast_h = 90;
            
for fileNum = 1 : length(inputFolder)
    CTP_vol_ori = fullfile(oriPath, inputFolder(fileNum).name);
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
    CTP_vol_GT = zeros(firstBlobsBoundingBox(4),firstBlobsBoundingBox(3),T,S);
    
    for s_i=1:S
        for t_i=1:T
        finalImg=squeeze(CTP_vol_ori(:,:,t_i,s_i));
        img_inRange = uint8(double(finalImg)/contrast_h*160);
        mask = pct_brainMask(finalImg,Wl,Wh,mask_val);   
        img_brain = mask .* double(img_inRange);
        CTP_vol_GT(:,:,t_i,s_i) = imcrop(img_brain, firstBlobsBoundingBox);
        end
    end
    saveName = inputFolder(fileNum).name;
    save(fullfile(outputFolder ,strcat('CTP_vol_GT_',saveName(1:8),'.mat')),'CTP_vol_GT');
end

end