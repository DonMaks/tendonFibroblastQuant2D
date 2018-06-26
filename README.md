# tendonFibroblastQuant2D
__tendonFibroblastQuant2D.m__
Quantification of 2 channel confocal microscopy images into dead and alive cells based on nuclear staining. Processes images in 'Images' Folder.

__tendonFibroblastCountOvergrown.m__
Estimate the number of cells in crowded images which cannot be processed with the original script. Processes images in 'CrowdedImages' folder.

__volumeMeasurement.m__
Manually measure length and diameter of the z-projected tendon image stack to estimate the volume based on the measurement depth and assumig a cylindrical tendon.

### Instructions:
1. Download the repository as a .zip and extract it on your computer. 
   - A directory named 'tendonFibroblastQuant2D will be genrated containing a 'functions' folder and four M-files ('loadParameters.m',          'tendonFibroblastCountOvergrown.m', 'tendonFibroblastQuant2D.m' and 'volumeMeasurement.m'.
2. Put your image-stacks into a folder labeled 'Images', if your dataset contains overgrown images which cannot be evaluated by the regular image processing pipeline put them in a folder labeled 'CrowdedImages'.
3. In the 'loadParameters.m'-file specify your parameters
   - parameters are in sections 'general', a'dditional for Quant2D' and 'additional for CountOvergrown', specifie the ones needed for the script you inted to run.
   - parameters.root_folder has to be set to be the parent directory of your 'Images' folder
3. Run the script 'tendonFibroblastQuant2D.m'
   - your results are in the folder Results2D_dd-month-yyyy_hh-mm-ss
4. Run the script 'tendonFibroblastCountOvergrown.m'
   - your results are in the folder ResultsCrowded_dd-month-yyyy_hh-mm-ss
5. Run the script 'volumeMeasurement.m'
   -your results are in the file 01_VolumeSummary.csv in the root directory specified in 'loadParameters.m'

### Results:
__tendonFibroblastQuant2D.m__ For every image file an .csv Outputfile with the same name is generated containing raw measurements. The file 00_Parameters.txt contains the settings used in your analysis. The file '01_ResultsSummary.csv' contains dead/alive cell counts for every image based on the parameters specified in 'loadParameters.m'. Depending on your settings up to three visualizations are saved per input image (mean intensity plot '_plot.png' color coded ratios '_ratios.png' and dead/alive/artefact in '_deadAlive.png').  Finally for every image the raw measurements are saved to 'image_name.csv'

__tendonFibroblastCountOvergrown.m__ The file 00_Parameters.txt contains the settings used in your analysis. The file '01_ResultsSummary.csv' contains cell counts for every image based on the allChannel and the parameters specified in 'loadParameters.m'. Depending on your settings up to two visualizations are saved per input image (mean intensity plot '_plot.png' and z-projection stack with outlined segmentation '_vis.tif').

__volumeMeasurement.m__ The file 01_VolumeSummary.csv is generated containing your measurements.

### Example:
Your regular 2 channel image stacks are at the location 'C:\Users\DonMaks\Data\Experiment_09-05-2018\Images', your crowded 2 channel image stacks are at the location 'C:\Users\DonMaks\Data\Experiment_09-05-2018\CrowdedImages'
- In the file 'loadParameters.m' set parameters.root_folder = 'C:\Users\DonMaks\Data\Experiment_09-05-2018\'
- Run the three scripts 'tendonFibroblastQuant2D.m', 'tendonFibroblastCountOvergrown.m' and  'volumeMeasurement.m'
- Your mortality analysis results are in a folder named 'C:\Users\DonMaks\Data\Experiment_09-05-2018\Results2D_2018-May-10_12-15-32'
- Your crowded images counts are in a folder named 'C:\Users\DonMaks\Data\Experiment_09-05-2018\ResultsCrowded_2018-May-10_12-15-32'
- Your volume meausrements are in the file 'C:\Users\DonMaks\Data\Experiment_09-05-2018\01_VolumeSummary.csv'
