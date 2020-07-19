function patientmAs = generateArray(inputFolder)
patientDir = dir(inputFolder);
patientDir = fixDir(patientDir);

patientmAs = []

for i = 1 : length(patientDir)
    fileInfo = dicominfo(inputFolder(i).name);
    %curmAs = 
    %patientmAs.append
end

%save file?