function [data] = loadData(filename, parameters)
%loadData Load data from a 2-channel .tf8 or .tif stack.
%   The function assumes the two channels are alternating in the orininal
%   file. Both a 'uint-16' version (data.dataAll/Dead) and a 'double'
%   version (scaled 16-bit values from 0-parameters.maximum16BitValue to 0-1) (data.imageAll/Dead)
%   is returned in the struct data. If parameters.alternatingChannels is
%   set to 1, the images are loaded in alternating fashion (1. image
%   channelAll, 2. image channelDead, etc...) otherwise the first half of
%   the stack is assumed to be channelAll and the second have channelDead.
raw_data = loadtiff(filename);

n = size(raw_data,3);

if parameters.alternatingChannels
    arrayStackAll = raw_data(:,:,1:2:n);
    arrayStackDead = raw_data(:,:,2:2:n);
else
    arrayStackAll = raw_data(:, :, 1:round(n/2));
    arrayStackDead = raw_data(:, :, round(n/2):end);
end

if parameters.reverseOrderOfChannels
    temp = arrayStackDead;
    arrayStackDead = arrayStackAll;
    arrayStackAll = temp;
end

if parameters.flipStackZOrder
    data.dataAll = flip(arrayStackAll, 3);
    data.dataDead = flip(arrayStackDead, 3);
else
    data.dataAll = arrayStackAll;
    data.dataDead = arrayStackDead;
end

data.imageAll = mat2gray(data.dataAll, [0 parameters.maximum16BitValue]);
data.imageDead = mat2gray(data.dataDead, [0 parameters.maximum16BitValue]);
end