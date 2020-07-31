function correctStats = CreateOriFile_CheckSizeName(subDir)

correctStats = false;

curDir = dir(fullfile(subDir.folder,'/', subDir.name));
curDir = fixDir(curDir);
curSize = size(curDir);

if curSize(1) == 21
    if contains(subDir.name, 'Perfusion')
        correctStats = true;
    end
end

end