clear all;
mfilepath = fileparts(which(mfilename));
addpath(fullfile(mfilepath, 'functions'));

parameters.scale = [0.619 0.619 1]; % [um] physical x y and z dimension of the input images
%parameters.scale = [0.3095 0.3095 2]; % [um] physical x y and z dimension of the input images
parameters.measurementDepth = 60; %[um] 
parameters.minSizeUm2 = 20; % [um^2] minimum area to be considered a nucleus
parameters.maxSizeUm2 = 150; % [um^2] maximum area to still be considered a single nucleus
parameters.hugeArtefactsUm2 = 350; % [um^2] the area of a 'blob' for it to be considered an artefact BEFORE applying watershed seg.
parameters.saveRatioImage = true; % Set to true if you want to save the ratios visualization
parameters.saveDeadAliveImage = true; % Set to true if you wat to save the dead/alive visualization (based on parameters.deathThresholdRatio)
parameters.deathThresholdRatio = 0.5; % the channel ratio (channelDead/channelAll) at wich a cell is considered dead
parameters.adaptiveSensitivity = 0.4; % [0-1]
parameters.watershedSensitivity = 1; % increase if image is oversegmented
parameters.medfiltWindowsize = 2; % increase if nuclei seem fuzzy
parameters.alternatingChannels = 1; % if set to 1 channels are alternating in the tiff file, otherwise first n/2 images are channelAll last images channelDead
parameters.reverseOrderOfChannels = 0; % 0 means channelAll first, 1 means channelDead first
parameters.root_folder = 'J:\Data_Tino\LD_1-76-xx\'; % The rootfolder containing your 'Images' folder and where the 'Results' folder will be created
parameters.image_folder = fullfile(parameters.root_folder, 'Images');
parameters.results_folder = fullfile(parameters.root_folder, ['Results2D_', strrep(strrep(char(datetime), ':', '-'), ' ', '-')]);
parameters.outfile_summary = fullfile(parameters.results_folder, '01_ResultsSummary.csv');
parameters.maximumExpectedRatio = 1.25; %channel ratio with maximum color for visualization
parameters.minimumExpectedRatio = 0; %c hannel ratio with minimum color for visualization


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



files = dir(fullfile(parameters.image_folder,'*.tf8'));

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