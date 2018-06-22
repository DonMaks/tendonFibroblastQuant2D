function [ startIndex ] = findStartIndexByMeanIntensity( data )
%FINDSTARTINDEXBYMEANINTENSITY Find the index of the first image in a stack containing nuclei
%   The mean pixel intensities for every image in a stack are calculated.
%   Then the difference in mean intensities between two adjacent images is
%   calculated, the start of the image stack is where the difference is
%   maximum.

res = zeros(size(data.imageAll, 3), 1);
diff = zeros(length(res)-1, 1);

for i = 1:size(data.imageAll, 3)
    image = data.imageAll(:, :, i);
    res(i) = (mean(image(:)));
    if i>1
        diff(i) = res(i)-res(i-1);
    end
end

[~, startIndex] = max(diff);
end

