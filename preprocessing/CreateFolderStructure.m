function CreateFolderStructure(datasetPath, outputPath, patientNum)

datasetPath = createPath(datasetPath);
outputPath = createPath(outputPath);

subDirs = dir(datasetPath);

dirIndex = 1;  % For Print statements and keeping track of row number in Summary

if nargin == 2
    patientNum = 100;  % Used to generate the new patient ID, starts with 101 since first 100 has already been de-identified
end

birthYear = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Remove Empty Directories%%%%%%%%%%%%%%%%%%%%%%%
for i = 3: length(subDirs)
    try
        rmdir (fullfile(datasetPath, '/', subDirs(i).name));
    catch
    end
end

subDirs = dir(datasetPath);
subDirs = fixDir(subDirs);

for i = 1 : length(subDirs)
    fprintf('--------------------------------------Starting with Directory %i-----------------------------------\n', dirIndex);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Figuring out how many times a substring appears in List of strings%%%%%%%%%%%%%%%%%%% 
    curDirCount = 0;
    curDir = subDirs(i);
    Gtype = 0;
    

    if strcmp(curDir.name(1:3),'DVD')
        %Case for folder starting with 'DVD'
        for j = 1 : length(subDirs)
            tempDir = subDirs(j);
            lastIndex = find(curDir.name == '_', 1,'last');
            if strcmp(curDir.name(1:lastIndex), tempDir.name)
                curDirCount = curDirCount + 1;
            end
        end
        
    elseif strcmp(curDir.name(1), 'G')
        Gtype = 1;
        %Case for folder starting with 'G'
        for j = 1 : length(subDirs)
            tempDir = subDirs(j);
            if strcmp(curDir.name(1:length(curDir)),tempDir)
                curDirCount = curDirCount + 1;
            end
        end
        
    else
        %Any other case will assume every folder is a new person
        %Currently one case left to handle the ones which start with '1' etc
        curDirCount = 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculating the visitNum and patientNum variable%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if curDirCount > 1
        visitNum = curDir.name(find(curDir.name == '_', 1, 'last') + 1: length(curDir.name));
    else
        visitNum = '1';
    end
    
    if strcmp(visitNum,'1')
        patientNum = patientNum + 1;
       
    end
           
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Iterate Through Files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear files
    if Gtype == 1
        files = dir(fullfile(datasetPath, curDir.name, 'IMAGES'));
    else
        files = dir(fullfile(datasetPath, curDir.name));
    end
    
    files = fixDir(files);
    
    if(length(files) > 1)
        for k = 1 : length(files)
        %disp(k);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Path to each individual file%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if Gtype == 1
            filePath = fullfile(datasetPath, curDir.name, 'IMAGES', files(k).name);
        else
            filePath = fullfile(datasetPath, curDir.name, files(k).name);
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Get File Data from DICOM file%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            fileInfo = dicominfo(filePath, 'UseDictionaryVR', true);
            %fprintf('%s : ',fileInfo.StudyDate);
        catch yikes
            %fprintf('%s : ', yikes.message);
            fileInfo.StudyDate = dicominfo(strcat(datasetPath,curDir.name,'/',files(3).name), 'UseDictionaryVR', true).StudyDate; 
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Creating a new ID%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        newID = strcat(num2str(patientNum,'%06.f'),num2str(str2num(visitNum),'%02.f'));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Get variables for sorting folders%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            studyDescription = fileInfo.StudyDescription;  % Used to sort folders
        catch
            studyDescription = strcat('Untilted_',newID);
        end
        
        try
            seriesDescription = fileInfo.SeriesDescription;  % Used to sort folders
        catch
            seriesDescription = strcat('Untilted_',newID);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%De-identify/Edit some Fields%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        birthYear = fileInfo.PatientBirthDate(1:4);       
        
        curDate = datetime(str2double(fileInfo.StudyDate),'ConvertFrom', 'yyyymmdd');
        newDate = dateshift(curDate,'end','week',12);
        newDate = num2str(yyyymmdd(newDate));
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Creating Folder Structure%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        newCurDir = strcat(newID,'_', birthYear);
        if not(isfolder(strcat(outputPath, newCurDir)))
            mkdir(strcat(outputPath, newCurDir))
        end
        
        % The main folder
        mainDirPath = strcat(studyDescription , fileInfo.StudyID , '_' , fileInfo.StudyDate(1:4) , '0101');
        mainDirList = split(mainDirPath,' ');
        
        mainDirString = join(mainDirList,'_');
        mainDir = replace(mainDirString,'/', '-');
        
        % The subfolder
        if contains(seriesDescription, 'MIP')
            correctionIndex = find(seriesDescription == '.', 1, 'last')-1;
            subDirList = split(seriesDescription(1:correctionIndex),' ');
        elseif contains(seriesDescription, 'OBL')
            correctionIndex = find(seriesDescription == '.', 1, 'last') - 1;
            subDirList = split(seriesDescription(1:correctionIndex),' ');
        else
            subDirList = split(seriesDescription, ' ');
        end

        subDirString = join(subDirList, '_');
        subDir = replace(subDirString,'/','-');
        subDir = replace(subDir,'__','_');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Sorting into smaller files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        if not(isfolder(strcat(outputPath , newCurDir , '/' , char(mainDir))))
            mkdir(fullfile(outputPath , newCurDir , '/' , char(mainDir)))
        end
        
        % Move file into its proper folder or create it and then move it
        if not(isfolder(strcat(outputPath , newCurDir , '/' , char(mainDir) , '/' , char(subDir))))
            mkdir(fullfile(strcat(outputPath , newCurDir , '/' , char(mainDir) , '/' , char(subDir))))
        end
       
        newPath = strcat(outputPath , newCurDir , '/' , char(mainDir) , '/' , char(subDir) , '/' , files(k).name);
        copyfile(filePath, newPath)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('--------------------------------------Done with Directory %i-----------------------------------\n', dirIndex)
        dirIndex = dirIndex + 1;
    end
end
fprintf('--------------------------------------Done with Everything-------------------------------------\n')
end
