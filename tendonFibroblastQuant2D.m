% Script for viability quantification of tendon fibroblast image 2 channel
% image stacks (channelAll and channelDead containing all or dead cells).
% A maximum intensity z-projection starting at the top of the tendon down
% to a defined depth is evaluated. The channelAll is used for segmentation
% of the nuclei by applying an adaptive threshold and subsequent watershed
% segmentation. The resulting segmented nuclei are used to count the cells
% and determine the viability of the cell by comparing the intensities
% between the two channels.
%
% Author: Max Hess <hess.max.timo@gmail.com>
% Created: Mai 2018
% Modified: June 2018
%
% Dependencies:
% - loadParameters.m
% - functions/writeStruct.m
% - functions/loadData.m
%   - loadtiff.m
% - functions/findStartIndexByMeanIntensity.m
% - functions/createBinaryMask.m
%   - functions/bwwatershed
% - functions/processImage2D.m
%   - functions/concatImages2D.m
% 
% Instructions:
% (1) Specify the 'General parameters' and 'Additional parameters for
%     tendonFibroblastQuant2D' in the 'loadParameters.m' file.
% (2) Put all your images in a folder named 'Images', the
%     parent-directory of which has to be referenced in 'loadParamteres.m'.
% (3) Run this script and find your results in a folder named
%     Results2D_DATETIME.
%
% Output files:
% - 00_Parameters.txt       - 1 file containing the parameter settings
% - 01_ResultsSummary.csv   - 1 file containing all the results
% - imageName.csv           - 1 file/image containing individual results
% - imageName_deatAlive.png - 1 file/image dead/alive visualization
%                             (only if parameters.saveDeadAliveImage = true)
% - imageName_ratio.png     - 1 file/image dead/all-ration visualized in
%                             colors (red-blue)
%                             (only if parameters.saveRatioImage = true)
% - imageName_plot.png      - 1 file/image with plot of mean image
%                             intensities and evaluated part of stack
%                             (only if parameters.saveIntensityPlot = true)

clear all;
mfilepath = fileparts(which(mfilename));
addpath(fullfile(mfilepath, 'functions'));

loadParameters;

parameters.image_folder = fullfile(parameters.root_folder, 'Images');
parameters.results_folder = fullfile(parameters.root_folder, ['Results2D_', strrep(strrep(char(datetime), ':', '-'), ' ', '-')]);
parameters.outfile_summary = fullfile(parameters.results_folder, '01_ResultsSummary.csv');

parameters.pixelArea = prod(parameters.scale(1:2));
parameters.voxelVolume = prod(parameters.scale);
parameters.minSizePx = parameters.minSizeUm2/parameters.pixelArea;
parameters.maxSizePx = parameters.maxSizeUm2/parameters.pixelArea;
parameters.removeHugeArtefactsBeforeWatershed = parameters.hugeArtefactsUm2/parameters.pixelArea;

if ~(7==exist(parameters.results_folder, 'dir'))
    mkdir(parameters.results_folder)
end

%write header to summary file and parameter file
header = {'Name', 'TotalCellCount', 'AliveCells', 'DeadCells', 'Artefacts', 'percentageAlive'};
header = strjoin(header, ',');
fid = fopen(parameters.outfile_summary, 'w+');
fprintf(fid,'%s\n',header);
fclose(fid);
writeStruct(fullfile(parameters.results_folder, '00_Parameters.txt'), parameters);



files = dir(fullfile(parameters.image_folder,['*', parameters.filenameExtension]));

for i = 1:length(files)
    filename = fullfile(parameters.image_folder, files(i).name);
    %filename = strcat(parameters.image_folder, '03.04.2018_Exp1-76-4_1a.tf8');
    parameters.name = files(i).name;
    
    %% Load data
    disp('Loading data:');
    data = loadData(filename, parameters);



    %% Find Start of imagestack and crop out the region the be evaluated (better performance)
    disp('Crop image stack:')
    tic
    parameters.startIndex = findStartIndexByMeanIntensity(data, parameters);
    parameters.endIndex = parameters.startIndex + ceil(parameters.measurementDepth/parameters.scale(3));
    if parameters.startIndex > 1
        parameters.startIndex = parameters.startIndex-1; %add a layer at the beginning
    end

    try
        data.imageAll = data.imageAll(:,:,parameters.startIndex:parameters.endIndex);
        data.imageDead = data.imageDead(:,:,parameters.startIndex:parameters.endIndex);
        data.dataAll = data.dataAll(:,:,parameters.startIndex:parameters.endIndex);
        data.dataDead = data.dataDead(:,:,parameters.startIndex:parameters.endIndex);
    catch
        data.imageAll = data.imageAll(:,:,parameters.startIndex:end);
        data.imageDead = data.imageDead(:,:,parameters.startIndex:end);
        data.dataAll = data.dataAll(:,:,parameters.startIndex:end);
        data.dataDead = data.dataDead(:,:,parameters.startIndex:end);
        parameters.actualMeasurementDepth = size(data.imageAll, 3)*parameters.scale(3);
    end
    toc
    
    %% Calculate the maximum projections
    disp('Calculate maximum projection:')
    tic
    data.maxAll = max(data.imageAll, [], 3);
    data.maxDead = max(data.imageDead, [], 3);
    data.maxAll16 = max(data.dataAll, [], 3);
    data.maxDead16 = max(data.dataDead, [], 3);
    toc
    
    %% Create a binary mask using adaptive thresholding medfilt and watershedsegmentation
    disp('Create binary mask:')
    tic
    data.mask = createBinaryMask(data.maxAll, parameters);
    toc


    %% Find connected components
    disp('Process image:')
    tic
    [ResultsSummary, ResultsTable, ratioImage, deadAliveImage] = processImage2D(data, parameters);
    toc
    %% Save Results
    
    disp('Save results:')
    tic
    %Save one .csv file per image containing all the measurements
    writetable(ResultsTable, fullfile(parameters.results_folder, [parameters.name(1:end-4), '.csv']));
    
    %Append the summary to the ResultsSummary.csv file
    line = {ResultsSummary.name, num2str(ResultsSummary.cellsTotal), ...
            num2str(ResultsSummary.cellsAlive), num2str(ResultsSummary.cellsDead), ...
            num2str(ResultsSummary.artefacts), num2str(ResultsSummary.percentageAlive)};
    string_line = strjoin(line, ',');
    fid = fopen(parameters.outfile_summary, 'a');
    fprintf(fid,'%s\n',string_line);
    fclose(fid);
    
    %If selectd save visualizations
    if parameters.saveRatioImage
        imwrite(ratioImage, fullfile(parameters.results_folder, [parameters.name(1:end-4), '_ratio.png']));
    end
    if parameters.saveDeadAliveImage
        imwrite(deadAliveImage, fullfile(parameters.results_folder, [parameters.name(1:end-4), '_deadAlive.png']));
    end
    toc
end