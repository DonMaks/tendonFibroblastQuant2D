%% General parameters
parameters.root_folder = 'J:\Stefania_SampleImages'; % The rootfolder containing your 'Images' folder and where the 'Results' folder will be created
parameters.filenameExtension = '.tif'; % Filename extension of the images
%parameters.scale = [0.619 0.619 1]; % [um] physical x y and z dimension of the input images
parameters.scale = [0.3095 0.3095 2]; % [um] physical x y and z dimension of the input images
parameters.measurementDepth = 60; %[um]
parameters.alternatingChannels = 1; % if set to 1 channels are alternating in the tiff file, otherwise first n/2 images are channelAll last images channelDead
parameters.reverseOrderOfChannels = 0; % 0 means channelAll first, 1 means channelDead first

%% Additional parameters for tendonFibroblastQuant2D
parameters.minSizeUm2 = 20; % [um^2] minimum area to be considered a nucleus
parameters.maxSizeUm2 = 150; % [um^2] maximum area to still be considered a single nucleus
parameters.hugeArtefactsUm2 = 350; % [um^2] the area of a 'blob' for it to be considered an artefact BEFORE applying watershed seg.
parameters.saveRatioImage = true; % Set to true if you want to save the ratios visualization
parameters.saveDeadAliveImage = true; % Set to true if you wat to save the dead/alive visualization (based on parameters.deathThresholdRatio)
parameters.deathThresholdRatio = 0.5; % the channel ratio (channelDead/channelAll) at wich a cell is considered dead
parameters.adaptiveSensitivity = 0.4; % [0-1]
parameters.watershedSensitivity = 1; % increase if image is oversegmented
parameters.medfiltWindowsize = 2; % increase if nuclei seem fuzzy
parameters.maximumExpectedRatio = 1.25; %channel ratio with maximum color for visualization
parameters.minimumExpectedRatio = 0; %c hannel ratio with minimum color for visualization

%% Additional parameters for tendonFibroblastCountOvergrown
parameters.stepSize = 10; % [um] depth of the z-projection steps
parameters.meanNucleusArea = 150; % [um^2] average area of a nucleus
parameters.adaptiveSensitivityOvergrown = 0.5; % [0-1]
parameters.visualizeResults = true;