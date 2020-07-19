function correctDir = fixDir(tempDir)
%Description: Gets rid of hidden files which the dir function creates
%returns a struct with only non-hidden files
%
%Input: Path to tempDir or the struct which dir(tempDir) creates
%
%Output: Returns a Struct which contains non-hidden files
%
%Consider getting rid of empty folders


if ischar(tempDir)
    tempDir = dir(tempDir);
end

tempLength = length(tempDir);
    for tempIndex = 1 : tempLength - 1
        if tempDir(tempLength - tempIndex).name(1) == '.'
            tempDir(tempLength - tempIndex) = [];
        end
    end
    correctDir = tempDir;
end