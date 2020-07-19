
function createGTFile(patientFolder)%%CTP_vol_ori = get the ori file created with createOriFile function...aka find CTP_vol_ori in each patient's file%%
CTP_vol_ori = fullfile(patientFolder, '/', 'CTP_vol_ori','/', 'CTP_vol_ori.mat');

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
    CTP_vol_GT = uint8(CTP_vol_GT);
    % figure;imshow(CTP_vol_GT(:,:,1,1)); title('GT');
    mkdir (fullfile(patientFolder ,'/','CTP_vol_GT'));
    save(fullfile(patientFolder, '/', 'CTP_vol_GT','/', 'CTP_vol_GT.mat'),'CTP_vol_GT');
end