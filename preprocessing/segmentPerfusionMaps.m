function SegmentPerfusionMaps(inputFolder, outputFolder)
%Description: segments all Perfusion Map files within inputFolder to 6
%segments: MIP, RCBV, TTP, rCBG, MTT, Delay maps *not sure if those are
%correct
%
%Input: inputFolder - folder with generated Perfusion Maps, string assumed
%
%Output: outputFolder - location of folder which the new 6 segmented maps
%will be saved to, can be same folder

inputFolder = createPath(inputFolder);
outputFolder = createPath(outputFolder);

if ~strcmp(inputFolder(end),'/')
    inputFolder = [inputFolder '/'];
end

if ~strcmp(outputFolder(end),'/')
    outputFolder = [outputFolder '/'];
end

%Creates the output folders%
mkdir(outputFolder, 'MIP')
mkdir(outputFolder,'rCBV')
mkdir(outputFolder,'TTP')
mkdir(outputFolder,'rCBF')
mkdir(outputFolder,'MTT')
mkdir(outputFolder,'Delay')

patients = fixDir(inputFolder);
for patientNum = 1 : length(patients)
    
    patientPics = dir(strcat(inputFolder,patients(patientNum).name));
    patientPics = fixDir(patientPics);
    
    for imageNum = 1: length(patientPics)
        filepath = fullfile(inputFolder, patients(patientNum).name, patientPics(imageNum).name);
        fileImage = dicomread(filepath);
        fileInfo = dicominfo(filepath);
        
        try
            fileImage = fileInfo.RescaleSlope * fileImage + fileInfo.RescaleIntercept;
        catch
        end
        
        fileImageSize = size(fileImage);
        xsplit = fileImageSize(2)/3;
        ysplit = fileImageSize(1)/2;
        
        rCBV =  fileImage(1:ysplit,xsplit + 1:2*xsplit,:);
        mask = SegmentPerfusionMap_FindMask(rCBV);
    
        MIP = fileImage(1:ysplit, 1:xsplit,:);
        MIP = bsxfun(@times, MIP, cast(mask, 'like', MIP));
        
        rCBV = bsxfun(@times, rCBV, cast(mask, 'like', rCBV));
        
        TTP = fileImage(1:ysplit,2*xsplit + 1:3*xsplit,:);
        TTP = bsxfun(@times, TTP, cast(mask, 'like', TTP));
        
        rCBF = fileImage(ysplit + 1: 2*ysplit,1:xsplit,:);
        rCBF = bsxfun(@times, rCBF, cast(mask, 'like', rCBF));
        
        MTT = fileImage(ysplit + 1: 2*ysplit, xsplit + 1:2*xsplit,:);
        MTT = bsxfun(@times, MTT, cast(mask, 'like', MTT));
        
        Delay = fileImage(ysplit + 1: 2*ysplit, 2*xsplit + 1:3*xsplit, :);
        Delay = bsxfun(@times, Delay, cast(mask, 'like', Delay));
    
    
        save(strcat(outputFolder,'MIP/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'MIP');
        save(strcat(outputFolder,'rCBV/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'rCBV');
        save(strcat(outputFolder,'TTP/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'TTP');
        save(strcat(outputFolder,'rCBF/',num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'rCBF');
        save(strcat(outputFolder,'MTT/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'MTT');
        save(strcat(outputFolder,'Delay/', num2str(patientNum,'%04.f'), '_', num2str(imageNum)),'Delay');
    end
end