clear all;
mfilepath = fileparts(which(mfilename));
addpath(fullfile(mfilepath, 'functions'));

%parameters.scale = [0.619 0.619 1]; % [um] physical x y and z dimension of the input images
parameters.scale = [0.3095 0.3095 2]; % [um] physical x y and z dimension of the input images
parameters.measurementDepth = 60; %[um] how deep to measure into the tendon
parameters.stepSize = 10; % [um] depth of the z-projection steps
parameters.meanNucleusArea = 150; % [um^2] average area of a nucleus
parameters.adaptiveSensitivity = 0.5; % [0-1]
parameters.alternatingChannels = 1; % if set to 1 channels are alternating in the tiff file, otherwise first n/2 images are channelAll last images channelDead
parameters.reverseOrderOfChannels = 0; % 0 means channelAll first, 1 means channelDead first
parameters.root_folder = 'J:\Stefania_SampleImages'; % The rootfolder containing your 'Images' folder and where the 'Results' folder will be created
parameters.image_folder = fullfile(parameters.root_folder, 'CrowdedImages');
parameters.results_folder = fullfile(parameters.root_folder, ['ResultsCrowded_', strrep(strrep(char(datetime), ':', '-'), ' ', '-')]);
parameters.outfile_summary = fullfile(parameters.results_folder, '01_ResultsSummary.csv');
parameters.visualizeResults = true;


parameters.pixelArea = prod(parameters.scale(1:2));
if ~(7==exist(parameters.results_folder, 'dir'))
    mkdir(parameters.results_folder)
end

%write header to summary file and parameter file
header = {'Name', 'TotalCellCount', 'TotalArea', 'meanNucSize'};
header = strjoin(header, ',');
fid = fopen(parameters.outfile_summary, 'w+');
fprintf(fid,'%s\n',header);
fclose(fid);
writeStruct(fullfile(parameters.results_folder, '00_Parameters.txt'), parameters);



files = dir(fullfile(parameters.image_folder, '*.tif'));

for i = 1:length(files)
    filename = fullfile(parameters.image_folder, files(i).name);
    %filename = strcat(parameters.image_folder, '03.04.2018_Exp1-76-4_1a.tf8');
    parameters.name = files(i).name;
    
    %% Load data
    disp('Loading data:');
    data = loadData(filename, parameters);



    %% Find Start of imagestack and crop out the region to be evaluated (better performance)
    disp('Crop image stack:')
    tic
    parameters.startIndex = findStartIndexByMeanIntensity(data);
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
    
    %% Generate z-projections of depth parameters.stepSize
    stepSizePx = round(parameters.stepSize/parameters.scale(3));
    idx = 1;
    data.zProjects = zeros(size(data.imageAll, 1), size(data.imageAll, 2), ceil(size(data.imageAll, 3)/stepSizePx));
    for j = 1:size(data.zProjects, 3)
        try
            data.zProjects(:, :, j) = max(data.imageAll(:, :, idx:idx+stepSizePx-1), [], 3);
        catch
            data.zProjects(:, :, j) = max(data.imageAll(:, :, idx:end), [], 3);
        end
        idx = idx+stepSizePx;
    end
    
    %% Apply a threshold for every zProjected slice and add up the areas
    data.maskedZProjects = zeros(size(data.zProjects));
    for j = 1:size(data.zProjects, 3)
        data.maskedZProjects(:, :, j) = bwareaopen(imbinarize(data.zProjects(:, :, j), 'adaptive', 'Sensitivity', parameters.adaptiveSensitivity), 10);
    end
    
    areaCoveredByNuclei = sum(data.maskedZProjects(:)) * parameters.pixelArea;
    nucleusCount = round(areaCoveredByNuclei / parameters.meanNucleusArea);
    
    %% Append the results to the parameters.outfile_summary file
    line = {parameters.name, num2str(nucleusCount), ...
            num2str(areaCoveredByNuclei), num2str(parameters.meanNucleusArea)};
    string_line = strjoin(line, ',');
    fid = fopen(parameters.outfile_summary, 'a');
    fprintf(fid,'%s\n',string_line);
    fclose(fid);
    
    %% Visualization
    if parameters.visualizeResults
        outstack = zeros([size(data.zProjects), 3], 'uint8');
        for j = 1:size(data.zProjects, 3)
            img = data.zProjects(:, :, j);
            mask = data.maskedZProjects(:, :, j);
            perim = bwperim(mask);
            
            overlay = imoverlay(img, perim, 'blue');
            outstack(:, :, j, :) = overlay;
        end
        writeColorStack(outstack, fullfile(parameters.results_folder, [parameters.name(1:end-4), '.tif']))
    end         
end