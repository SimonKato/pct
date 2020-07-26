function fullMask = SegmentPerfusionMap_FindMask(rawImage)
%noTextImage = rawImage(60:460,80:430,:);
imageSize = size(rawImage);
xsize = imageSize(2);
ysize = imageSize(1);

noTextImage = rawImage(round(0.12*ysize):round(0.9*ysize),round(0.16*xsize):round(0.84*xsize),:);

if xsize > 512
    subMask = noTextImage > 0;
else
    subMask = rgb2gray(noTextImage) > 0;
end

fullMask = zeros(ysize,xsize);
fullMask(round(0.12*ysize):round(0.9*ysize),round(0.16*xsize):round(0.84*xsize),:) = subMask;
end