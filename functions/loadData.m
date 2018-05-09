function [data] = loadData(filename)
%loadData Load data from a 2-channel .tf8 or .tif stack.
%   The function assumes the two channels are alternating in the orininal
%   file. Both a 'uint-16' version (data.dataAll/Dead) and a 'double'
%   version (scaled 16-bit values from 0-2000 to 0-1) (data.imageAll/Dead)
%   is returned in the struct data.
raw_data = loadtiff(filename);

n = size(raw_data,3);

arrayStackC1 = raw_data(:,:,2:2:n);
arrayStackC2 = raw_data(:,:,1:2:n);
data.dataAll = flip(arrayStackC2, 3);
data.dataDead = flip(arrayStackC1, 3);
data.imageAll = mat2gray(data.dataAll, [0 2000]);
data.imageDead = mat2gray(data.dataDead, [0 2000]);
end