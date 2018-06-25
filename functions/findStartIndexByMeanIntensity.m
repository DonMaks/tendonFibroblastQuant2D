function [ startIndex ] = findStartIndexByMeanIntensity( data, parameters )
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

% save a figure containing a plot of the mean intensities of individual
% images and a red line for the evaluated region
xline = [startIndex-1, startIndex-1+ceil(parameters.measurementDepth/parameters.scale(3))];
yline = [min(res), min(res)];
fig = figure('visible', 'off');
plot(1:length(res), res, '.-');
hold on
plot(xline, yline, 'r', 'LineWidth', 3);
xlabel('Image Index');
ylabel('Mean Pixel Intensity');
saveas(fig, fullfile(parameters.results_folder, [parameters.name(1:end-4), '_plot.png']));
close(fig);
end

