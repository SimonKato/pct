function deidentify(datasetPath, outputPath, patientNum)
%Description: deidentifies PHI from patient folders within datasetPath.
%Current behavior is to create folders within the same directory as
%datasetPath.
%
%Input: datasetPath - location of folders contating dicom images which need
%to be deidentified.
%
%Output: Creates a new file structure within outputPath which creates a new
%folder for each previous patient with a unique ID created within the code
%and then sorts the images by studyDescription and then SeriesDescriptions.
%
%Note: I changed some of the datasetPath to outputPath which might have
%broken something, I am unsure currently.

summaryFilesFolder = strcat(outputPath,'Summary/');
if not(isfolder(summaryFilesFolder))
    mkdir(summaryFilesFolder);
end

subDirs = dir(datasetPath);

dirIndex = 1;  % For Print statements and keeping track of row number in Summary

if nargin == 2
    patientNum = 100;  % Used to generate the new patient ID, starts with 101 since first 100 has already been de-identified
end

alphabet = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'};

emptyFolders = 0;
birthYear = '';

SummaryVarTypes = {'string', 'string','double','logical','logical','logical','double'}; 
sz = [(length(subDirs)- 2) 7];
Summary = table('Size', sz, 'VariableTypes', SummaryVarTypes, 'VariableNames', {'Patient ID', 'Accession Number', 'Visit Number', 'NCCT', 'CTP', 'CECT', 'Scanning Date'}); %scanning date is original, nonshifted date

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
    summaryIndex = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculating the visitNum and patientNum variable%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if curDirCount > 1
        visitNum = curDir.name(find(curDir.name == '_', 1, 'last') + 1: length(curDir.name));
    else
        visitNum = '1';
    end
    
    if strcmp(visitNum,'1')
        patientNum = patientNum + 1;
        
        % Generate new accession number for each new patient
        alphabetIndexes = randi(length(alphabet), 1, 8);
        newAccessionNumber = cell2mat(alphabet(alphabetIndexes));
    end
           
    Summary(dirIndex, 1) = {num2str(patientNum,'%06.f')};
    Summary(dirIndex, 2) = {newAccessionNumber};
    Summary(dirIndex, 3) = {str2num(visitNum)};
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
        disp(k);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Path to each individual file%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if Gtype == 1
            filepath = fullfile(datasetPath, curDir.name, 'IMAGES', files(k).name);
        else
            filepath = fullfile(datasetPath, curDir.name, files(k).name);
        end
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Get File Data from DICOM file%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            fileInfo = dicominfo(filepath, 'UseDictionaryVR', true);
            %fprintf('%s : ',fileInfo.StudyDate);
        catch yikes
            %fprintf('%s : ', yikes.message);
            fileInfo.StudyDate = dicominfo(strcat(datasetPath,curDir.name,'/',files(3).name), 'UseDictionaryVR', true).StudyDate; 
        end
        try 
            fileImage = dicomread(filepath);
        catch yikes
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
        %fprintf('%s : ',birthYear);
        
        fileInfo.PatientID = newID;
        fileInfo.PatientName = newID;
        fileInfo.PatientBirthDate = strcat(birthYear, '0101');
        fileInfo.StudyID = newAccessionNumber;
        
        % Store the original Implementation Class UID and Version Name
        ImClassStore = char(fileInfo.(dicomlookup('0002','0012'))); % Original Implemenation Class UID
        ImVerStore = char(fileInfo.(dicomlookup('0002','0013'))); % Original Implementation Version Name       
        
        try
            if isfield(fileInfo, 'ReferringPhysicianName')
                fileInfo.ReferringPhysicianName = '';
            end
            
        catch
        end
        
        try
            if isfield(fileInfo, dicomlookup('0009','0400'))
                fileInfo.(dicomlookup('0009','0400')).Item_1.PatientName = newID;
                fileInfo.(dicomlookup('0009','0400')).Item_1.PatientID = newID;
                fileInfo.(dicomlookup('0009','0400')).Item_1.IssuerOfPatientID = '';
                fileInfo.(dicomlookup('0009','0400')).Item_1.PatientBirthDate = strcat(birthYear, '0101');
                fileInfo.(dicomlookup('0009','0400')).Item_1.OtherPatientIDs = newID;
            end
        catch
        end
        
        fileInfo.AccessionNumber = newAccessionNumber;
        try
            if isfield(fileInfo, dicomlookup('0040','0009'))
                fileInfo.ScheduledProcedureStepID = newAccessionNumber;
            end
        catch
        end
        try
            if isfield(fileInfo, dicomlookup('0040','A370'))
                fileInfo.ReferenceRequestSequence.Item_1.AccessionNumber = newAccessionNumber;
            end
        catch
        end
        
        try
            if isfield(fileInfo, dicomlookup('0040','0275'))
                fileInfo.RequestAttributesSequence.Item_1.ScheduledProcedureStepID = newAccessionNumber;
            end
        catch
        end
        
        try
            if isfield(fileInfo, dicomlookup('0040','0275'))
                fileInfo.RequestAttributesSequence.Item_1.RequestedProcedureID = newAccessionNumber;
            end
        catch
        end
        
        try
            if isfield(fileInfo, dicomlookup('0040','1001'))
                fileInfo.RequestedProcedureID = newAccessionNumber;
            end
        catch
        end
        
        try
            if isfield(fileInfo, dicomlookup('0008','1070'))
                fileInfo.OperatorsName = [];
            end
        catch
        end
        
        curDate = datetime(str2double(fileInfo.StudyDate),'ConvertFrom', 'yyyymmdd');
        newDate = dateshift(curDate,'end','week',12);
        newDate = num2str(yyyymmdd(newDate));
        
        fileInfo.StudyDate = newDate;
        %fprintf('%s\n', fileInfo.StudyDate);
        fileInfo.SeriesDate = newDate;
        
        try
            if isfield(fileInfo, dicomlookup('0008','0022'))
                fileInfo.AcquisitionDate = newDate;
            end
        catch
        end
        try
            if isfield(fileInfo, dicomlookup('0008','0023'))
                fileInfo.ContentDate = newDate;
            end
        catch
        end
        try
            if isfield(fileInfo, dicomlookup('0040','0002'))
                fileInfo.ScheduledProcedureStepStartDate = newDate;
            end
        catch
        end
        try
            if isfield(fileInfo, dicomlookup('0040','0004'))
                fileInfo.ScheduledProcedureStepEndDate = newDate;
            end
        catch
        end
        try
            if isfield(fileInfo, dicomlookup('0040','0244'))
                fileInfo.PerformedProcedureStepStartDate = newDate;
            end
        catch
        end
        try
            if isfield(fileInfo, dicomlookup('0040','A032'))
                fileInfo.ObservationDateTime = newDate;
            end
            if isfield(fileInfo, dicomlookup('0040','A073'))
                fileInfo.VerifyingObserverSequence.Item_1.VerificationDateTime = newDate;
            end
        catch
        end
        
        
        % Deidentify radiology report
        try
            title = fileInfo.ConceptNameCodeSequence.Item_1.CodeMeaning;
            if strcmpi(title, 'RADIOLOGY REPORT')
                try
                    fileInfo.VerifyingObserverSequence.Item_1.VerifyingObserverName = '';
                    fileInfo.ContentSequence.Item_4.PersonName = '';
                    fileInfo.ContentSequence.Item_2.PersonName = '';
                catch
                end
                
                % Remove prior study date
                for jj = 1:2
                    try
                        % Remove date info
                        text = fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue;
                        dateMatch = regexp(text, '\d{2}/\d{2}/\d{4}', 'match');
                        if isempty(dateMatch)
                            dateMatch = regexp(text, '\d{1}/\d{2}/\d{4}', 'match');
                            if isempty(dateMatch)
                                dateMatch = regexp(text, '\d{2}/\d{1}/\d{4}', 'match');
                                if isempty(dateMatch)
                                    dateMatch = regexp(text, '\d{1}/\d{1}/\d{4}', 'match');
                                end
                            end
                        end
                        newText = regexprep(text, dateMatch{1}, newDate);
                        fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue = newText;               
                                                                        
                    catch
                    end
                    try
                        newText = fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue;
                        
                        % Remove physician name info
                        breaks = ismember(newText, char([10 13]));
                        breaks = find(breaks==1);
                        nameMatch = regexp(newText,'MD');
                        if isempty(nameMatch)
                            nameMatch = regexp(newText,'Dr.');
                            if isempty(nameMatch)
                                nameMatch = regexp(newText,'Dr');
                                if isempty(nameMatch)
                                    nameMatch = regexp(newText,'I, ');
                                end
                            end
                        end
                        [minValue,closestIndex] = min(abs(breaks-nameMatch));
                        newText(breaks(closestIndex):breaks(closestIndex+1)) = [];
                        
                        fileInfo.ContentSequence.Item_5.ContentSequence.Item_1.TextValue = newText;
                    catch
                    end
                end
            end
        catch
        end
        

        try
            if isfield(fileInfo, dicomlookup('0040','A730'))
                fileInfo.ContentSequence.Item_4.DateTime = newDate;
                fileInfo.ContentSequence.Item_5.DateTime = newDate;
            end
        catch   
        end
        
       % Deidentify dose summary
        try
            if contains(upper(fileInfo.SeriesDescription), 'SUMMARY')
                if Gtype ~= 1
                    image = dicomread(fileInfo.Filename);

    %                 fh = figure;
    %                 imshow(path, 'border', 'tight');
    %                 hold on;

                    if summaryIndex == 0
                        image(100:175,400:650) = 2047;
                        image(240:320,270:400) = 2047;
    %                     rectangle('Position', [400 100 250 75], 'FaceColor', 'Black');
    %                     rectangle('Position', [270 240 130 80], 'FaceColor', 'Black');
                    else
                        image(25:50,160:280) = 2047;
                        %rectangle('Position', [160 25 120 25], 'FaceColor', 'Black');
                    end    

                    %frm = getframe(fh);
                    %fileImage = frm.cdata;
                    summaryIndex = summaryIndex + 1;
                    
                else
                    fileImage = blackoutImage(fileInfo.Filename, summaryIndex);            
                    summaryIndex = summaryIndex + 1;
                end
            end
        catch
        end
            
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Summary File Checks%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %fprintf("%s\n", seriesDescription);
        if contains(seriesDescription, 'Head W/O 5.0') %Check for NCCT keyword
            Summary(dirIndex,4) = {true};
            
        elseif contains(seriesDescription, 'Perfusion Head 4D') %Check for CTP keyword
            Summary(dirIndex,5) = {true};
            
        elseif contains(seriesDescription, 'Head Brain HEAD W/C') %Check for CECT keyword
            Summary(dirIndex,6) = {true};
        end
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
            subDirList = split(seriesDescirption(1:correctionIndex),' ');
        else
            subDirList = split(seriesDescription, ' ');
        end

        subDirString = join(subDirList, '_');
        subDir = replace(subDirString,'/','-');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Sorting into smaller files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Must write these data to private fields :(
        if ~isfield(fileInfo, dicomlookup('0009','0012')) && ~isfield(fileInfo, dicomlookup('0009','0013'))            
            fileInfo.(dicomlookup('0009','0012')) = ImClassStore;
            fileInfo.(dicomlookup('0009','0013')) = ImVerStore;
        elseif ~isfield(fileInfo, dicomlookup('0011','0012')) && ~isfield(fileInfo, dicomlookup('0011','0013'))
            fileInfo.(dicomlookup('0011','0012')) = ImClassStore;
            fileInfo.(dicomlookup('0011','0013')) = ImVerStore;
        else
            fileInfo.(dicomlookup('0013','0012')) = ImClassStore;
            fileInfo.(dicomlookup('0013','0013')) = ImVerStore;
        end
        
        
        if not(isfolder(strcat(outputPath , newCurDir , '/' , char(mainDir))))
            mkdir(fullfile(outputPath , newCurDir , '/' , char(mainDir)))
        end
        
        % Move file into its proper folder or create it and then move it
        if isfolder(strcat(outputPath , newCurDir , '/' , char(mainDir) , '/' , char(subDir)))
            newPath = strcat(fullfile(outputPath , newCurDir , '/' , char(mainDir) , '/' , char(subDir) , '/' , files(k).name), '.dcm');
            gen_count = 0; err_count = 0;
            while gen_count == err_count
                try
                    dicomwrite(fileImage, newPath, fileInfo, 'CreateMode', 'copy', 'WritePrivate', true);
                catch MException
                    err_count=err_count+1;
                    grp = MException.message(12:15);
                    el = MException.message(17:20);
                    fileInfo = rmfield(fileInfo,(dicomlookup(grp,el)));
                end
                gen_count=gen_count+1;
            end
        else
            mkdir(fullfile(strcat(outputPath , newCurDir , '/' , char(mainDir) , '/' , char(subDir))))
            newPath = strcat(fullfile(outputPath , newCurDir , '/' , char(mainDir) , '/' , char(subDir) , '/' , files(k).name), '.dcm');
            gen_count = 0; err_count = 0;
            while gen_count == err_count
                try
                    dicomwrite(fileImage, newPath, fileInfo, 'CreateMode', 'copy', 'WritePrivate', true);
                catch MException
                    grp = MException.message(12:15);
                    el = MException.message(17:20);
                    fileInfo = rmfield(fileInfo,(dicomlookup(grp,el)));
                    err_count = err_count+1;
                end
            gen_count = gen_count+1;
            end
        end
       
        emptyFolders = emptyFolders + 1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Summary(dirIndex, 6) = {yyyymmdd(curDate)};
        fprintf('--------------------------------------Done with Directory %i-----------------------------------\n', dirIndex)
        dirIndex = dirIndex + 1;
    end
end
 
writetable(Summary, fullfile(summaryFilesFolder, 'Dataset Data.xlsx'))
writetable(Summary, fullfile(summaryFilesFolder, 'Dataset Data.csv'), 'Delimiter', ',')
fprintf('--------------------------------------Done with Everything-------------------------------------\n')
end
