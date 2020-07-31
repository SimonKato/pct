function RGBImage = SegmentPerfusionMaps_DecodeImage(rawImage)
RGBImage = uint8(zeros(1024, 1536, 3));
RGBImage(:,:,1) = rawImage(:,mod(1:4608,3)== 1);
RGBImage(:,:,2) = rawImage(:,mod(1:4608,3)== 2);
RGBImage(:,:,3) = rawImage(:,mod(1:4608,3)== 0);
end