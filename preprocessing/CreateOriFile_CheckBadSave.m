function badSave = CreateOriFile_CheckBadSave(subDirs)
%Consider renaming to CreateOriFile_CheckBadSave
badSave = false;

for i = 1 : length(subDirs)
    if contains(subDirs(i).name, "Perfusion_0.5_CE_Perfusion_Head_4D_CBP_DYNAMIC_4_")
        badSave = true;
        break
    end
end
end