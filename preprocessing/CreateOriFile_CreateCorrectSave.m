function newFolderPath = CreateOriFile_CreateCorrectSave(subDirPath)
%Consider renaming to CreateOriFile_CheckBadSave, and considering delete
%the old 21 folders in leu of the new one.
try
    mkdir(subDirPath,"Perfusion_0.5_CE_Perfusion_Head_4D_CBP_DYANMIC_4")
    newFolderPath = strcat(subDirPath, "Perfusion_0.5_CE_Perfusion_Head_4D_CBP_DYANMIC_4");
catch
end

subDirs = dir(subDirPath);
subDirs = fixDir(subDirs);

for i = 1 : length(subDirs)
    if contains(subDirs(i).name,  "Perfusion_0.5_CE_Perfusion_Head_4D_CBP_DYANMIC_4_")
        file = dir(strcat(subDirPath, subDirs(i).name));
        file = fixDir(file);
        
        copyfile(strcat(subDirPath, subDirs(i).name, file(1)), strcat(newFolderPath,'/',file(1)))
    end
end

end