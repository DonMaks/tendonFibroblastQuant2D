clear all;
mfilepath = fileparts(which(mfilename));
addpath(fullfile(mfilepath, 'functions'));

parameters.scale = [0.619 0.619 1]; % [um] physical x y and z dimension of the input images
%parameters.scale = [0.3095 0.3095 2]; % [um] physical x y and z dimension of the input images
parameters.measurementDepth = 60; %[um] 
parameters.root_folder = 'J:\Data_Tino\LD_1-76-xx';
parameters.image_folder = fullfile(parameters.root_folder, 'Images');
parameters.alternatingChannels = 1; % if set to 1 channels are alternating in the tiff file, otherwise first n/2 images are channelAll last images channelDead
parameters.reverseOrderOfChannels = 0; % 0 means channelAll first, 1 means channelDead first

parameters.outfile_volume = fullfile(parameters.root_folder, '01_VolumeSummary.csv');

%write header to summary file and parameter file
header = {'Name', 'Volume', 'Length', 'Diameter', 'Depth'};
header = strjoin(header, ',');
fid = fopen(parameters.outfile_volume, 'w+');
fprintf(fid,'%s\n',header);
fclose(fid);



files = dir(fullfile(parameters.image_folder,'*.tf8'));

for i = 1:length(files)
    filename = fullfile(parameters.image_folder, files(i).name);
    disp('Loading data:');
    data = loadData(filename, parameters);
    maximumProjection = imadjust(max(data.imageAll, [], 3));
    [~, lengthPx, diameterPx] = measureGUI(maximumProjection);
    tendon = Tendon(lengthPx, diameterPx, parameters);
    
    line = {files(i).name, num2str(tendon.volume), num2str(tendon.length),...
        num2str(tendon.diameter), num2str(tendon.depth)};
    string_line = strjoin(line, ',');
    fid = fopen(parameters.outfile_volume, 'a');
    fprintf(fid,'%s\n',string_line);
    fclose(fid);
end