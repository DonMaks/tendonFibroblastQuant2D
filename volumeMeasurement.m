clear all;
mfilepath = fileparts(which(mfilename));
addpath(fullfile(mfilepath, 'functions'));

loadParameters;

parameters.image_folder1 = fullfile(parameters.root_folder, 'Images');
parameters.image_folder2 = fullfile(parameters.root_folder, 'CrowdedImages');
parameters.outfile_volume = fullfile(parameters.root_folder, '01_VolumeSummary.csv');

%write header to summary file and parameter file
header = {'Name', 'Volume', 'Length', 'Diameter', 'Depth'};
header = strjoin(header, ',');
fid = fopen(parameters.outfile_volume, 'w+');
fprintf(fid,'%s\n',header);
fclose(fid);

files1 = dir(fullfile(parameters.image_folder1,['*', parameters.filenameExtension]));
files2 = dir(fullfile(parameters.image_folder2,['*', parameters.filenameExtension]));

for i = 1:length(files1)
    filename = fullfile(parameters.image_folder1, files1(i).name);
    disp('Loading data:');
    data = loadData(filename, parameters);
    maximumProjection = imadjust(max(data.imageAll, [], 3));
    [~, lengthPx, diameterPx] = measureGUI(maximumProjection);
    tendon = Tendon(lengthPx, diameterPx, parameters);
    
    line = {files1(i).name, num2str(tendon.volume), num2str(tendon.length),...
        num2str(tendon.diameter), num2str(tendon.depth)};
    string_line = strjoin(line, ',');
    fid = fopen(parameters.outfile_volume, 'a');
    fprintf(fid,'%s\n',string_line);
    fclose(fid);
end
for i = 1:length(files2)
    filename = fullfile(parameters.image_folder2, files2(i).name);
    disp('Loading data:');
    data = loadData(filename, parameters);
    maximumProjection = imadjust(max(data.imageAll, [], 3));
    [~, lengthPx, diameterPx] = measureGUI(maximumProjection);
    tendon = Tendon(lengthPx, diameterPx, parameters);
    
    line = {files2(i).name, num2str(tendon.volume), num2str(tendon.length),...
        num2str(tendon.diameter), num2str(tendon.depth)};
    string_line = strjoin(line, ',');
    fid = fopen(parameters.outfile_volume, 'a');
    fprintf(fid,'%s\n',string_line);
    fclose(fid);
end