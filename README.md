# tendonFibroblastQuant2D
Quantification of 2 channel confocal microscopy images into dead and alive cells based on nuclear staining.

### Instructions:
1. Download the repository as a .zip and extract it on your computer. 
   - The 'functions' folder needs to be in the same folder as 'tendonFibroblastQuant2D.m'
2. Put your image-stacks into a folder labeled 'Images'
3. In the 'tendonFibroblastQuant2D.m'-file specify your parameters
   - parameters.root_folder has to be set to be the parent directory of your 'Images' folder
4. Run the script 
   - your results are in the folder Results2D_dd-month-yyyy_hh-mm-ss

### Results:
For every image file an .csv Outputfile with the same name is generated containing raw measurements. The file 00_Parameters.txt contains the settings used in your analysis. The file '01_ResultsSummary.csv' contains dead/alive cell counts for every image based on the parameters specified in the beginning (deathThresholdRatio, etc...). Depending on your settings up to two visualizations are saved per input image (color coded ratios '_ratios.png' and dead/alive/artefact in '_deadAlive.png'). Finally for every image the raw measurements are saved to 'image_name.csv'.

### Example:
Your 2 channel image stacks are at the location 'C:\Users\DonMaks\Data\Experiment_09-05-2018\Images'
- In the file 'tendonFibroblastQuant2D.m' set parameters.root_folder = 'C:\Users\DonMaks\Data\Experiment_09-05-2018\'
- Run the file (the functions folder has to be in the same directory as your M-file)
- Your results are in a folder named 'C:\Users\DonMaks\Data\Experiment_09-05-2018\Results2D_2018-May-10_12-15-32'
