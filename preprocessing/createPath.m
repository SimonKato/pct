function absolutePath = createPath(relativePath)
%Description: Generates absolute path from a relative path
%
%Input : relative path to destination
%
%Output: absolute path to destination
curDir = cd();

cd(relativePath);
absolutePath = strcat(pwd(),'\');
cd(curDir);
end