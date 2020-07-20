function fixedImage = segmentPerfusionMap_IsolateImage(rawImage)
noTextImage = rawImage(50:460,80:430,:);
subMask = rgb2gray(noTextImage) > 0;

fullMask = zeros(512);
fullMask(90:450,100:430,:) = subMask;

fixedImage = bsxfun(@times, rawImage, cast(fullMask, 'like', rawImage));
end