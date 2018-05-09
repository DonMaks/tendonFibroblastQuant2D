function bm = createBinaryMask(I, parameters)
    %adaptiveSensitivity: 0.4 #[0-1] 
    %medfiltWindowsize: 2 #increase for less fuzzy nuclei
    %watershedSensitivity: 1 #increase if oversegmented
    %cleanup: 1 # [0, 1, 2] 0: no cleanup, 1: cleanup before watershedSegmentation 2: cleanup after watershedSegmentation
    

    bw = imbinarize(I, 'adaptive', 'Sensitivity', parameters.adaptiveSensitivity);
    stats = regionprops(bw, 'Area', 'PixelIdxList');
    for i = 1:length(stats)
        if stats(i).Area > parameters.removeHugeArtefactsBeforeWatershed
            bw(stats(i).PixelIdxList)=0;
        end
    end
    bw_filt = medfilt2(bw, [parameters.medfiltWindowsize, parameters.medfiltWindowsize]);
    bm = bwwatershed(bw_filt, parameters.watershedSensitivity);
    
    