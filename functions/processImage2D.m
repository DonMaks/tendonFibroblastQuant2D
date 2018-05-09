function [ResultsSummary, ResultsTable, ratioImage, deadAliveImage] = processImage2D(data, parameters)

    
    pixelArea = prod(parameters.scale(1:2));
    
    connComp = bwconncomp(data.mask, 6);
    propConnComp = regionprops(connComp);
    n = length(propConnComp);
    Results = struct('index', {}, 'area', {}, 'meanAll', {}, 'stdAll', {},...
                     'maxAll', {}, 'minAll', {}, 'meanDead', {}, 'stdDead', {},...
                     'maxDead', {}, 'minDead', {}, 'ratio', {}, 'difference', {}, 'type', {}, 'nPixel', {});
    
    maskAlive = zeros(size(data.mask));
    maskDead = zeros(size(data.mask));
    maskArtefacts = zeros(size(data.mask));
    maskMerged = zeros(size(data.mask));
    
    flattend_all = data.maxAll(:);
    flattend_dead = data.maxDead(:);

    for i = 1:n
        % second approach
        pixelIndices = connComp.PixelIdxList(i);
        pixelIndices = pixelIndices{1};
        blobPixelAll = double(flattend_all(pixelIndices));
        blobPixelDead = double(flattend_dead(pixelIndices));
        channelsRatio = mean(blobPixelDead)/mean(blobPixelAll);
        area = propConnComp(i).Area;
        %centroid = propConnComp(i).Centroid;
        alive = channelsRatio < parameters.deathThresholdRatio; %a cell is alive if the ratio between the two channes is above a threshold
        

        if area > parameters.minSizePx && area < parameters.maxSizePx && alive %Right volume for being a nucleus and alive -> type = 1 = alive
            maskAlive(pixelIndices) = 1;
            type = 1;
        elseif area > parameters.minSizePx && area < parameters.maxSizePx && ~alive %Right volume but dead -> type = 0 = dead
            maskDead(pixelIndices) = 1;
            type = 0;
        elseif area <= parameters.minSizePx %Insufficient volume -> type = 2 = artefact
            maskArtefacts(pixelIndices) = 1;
            type = 2;
        elseif area >= parameters.maxSizePx
            maskMerged(pixelIndices) = 1;
            type = 3;
        end
        Results(end+1) = struct('index', {i}, 'area', {length(blobPixelAll)*pixelArea}, ... 
                                'meanAll', {mean(blobPixelAll)}, 'stdAll', {std(blobPixelAll)},...
                                'maxAll', {max(blobPixelAll)}, 'minAll', {min(blobPixelAll)},...
                                'meanDead', {mean(blobPixelDead)}, 'stdDead', {std(blobPixelDead)},...
                                'maxDead', {max(blobPixelDead)}, 'minDead', {min(blobPixelDead)},...
                                'ratio', {channelsRatio}, 'difference', {mean(blobPixelDead)-mean(blobPixelAll)},...
                                'type', {type}, 'nPixel', {length(blobPixelAll)});
    end
    
    areasPx = [Results.nPixel];
    alive = [Results.type] == 1;
    resultsArray = alive(areasPx>parameters.minSizePx & areasPx<parameters.maxSizePx);
    ResultsSummary = struct('name', {parameters.name}, ...
                            'cellsTotal', {length(resultsArray)},...
                            'cellsAlive', {sum(resultsArray)},...
                            'cellsDead', {sum(~resultsArray)}, ...
                            'artefacts', {length(alive)-length(resultsArray)}, ...
                            'percentageAlive', {sum(resultsArray)/length(resultsArray)}, ...
                            'parameters', {parameters});
    ResultsTable = struct2table(Results);
    %% Visualize
    
    if parameters.saveDeadAliveImage
        deadAliveImage = imoverlay(data.maxAll, maskAlive, [0 0.5 0]);
        deadAliveImage = imoverlay(deadAliveImage, maskDead, [0.5 0 0]);
        deadAliveImage = imoverlay(deadAliveImage, maskArtefacts, [0 0.15 0.35]);
        deadAliveImage = imoverlay(deadAliveImage, maskMerged, [0.15 0 0.35]);
        deadAliveImage = concatImages2D(im2uint8(data.maxAll), im2uint8(data.maxDead), deadAliveImage);
    else
        deadAliveImage = nan;
    end
    
    if parameters.saveRatioImage
        ncols = 20;
        masks = zeros([size(data.mask), ncols]);
        masks_flattend = masks(:);
        cmap = jet(ncols)*1;

        ratios = ResultsTable.ratio;
        areas = ResultsTable.nPixel;
        valid_areas = areas > parameters.minSizePx & areas < parameters.maxSizePx;
        ratios(~valid_areas) = mean(ratios);

        maxRatio = parameters.maximumExpectedRatio;
        minRatio = parameters.minimumExpectedRatio;
        ratios(ratios>maxRatio) = maxRatio;
        ratios(ratios<minRatio) = minRatio;
        ratios = ratios-minRatio;
        color = ratios * (ncols-1) / (maxRatio-minRatio);
        color_r = round(color);
        color_r(~valid_areas) = NaN;

        for i = 1:n
            pixelIndices = connComp.PixelIdxList{i};
            c = color_r(i);
            if ~isnan(c)
                realPixelIndices = pixelIndices + c * numel(data.mask);
                masks_flattend(realPixelIndices) = 1;
            end
        end

        masks = reshape(masks_flattend, size(masks));

        outImage = data.maxAll;
        for i = 1:size(masks, 3)
            outImage = imoverlay(outImage, masks(:,:,i), cmap(i, :));
        end
        ratioImage = concatImages2D(im2uint8(data.maxAll), im2uint8(data.maxDead), outImage);
    else
        ratioImage = nan;
    end
    
    
end