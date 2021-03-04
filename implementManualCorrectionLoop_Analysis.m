%% Implement manual correrction of seeds
% load resultstruct before running script
if ~isfield(AllSpheroidResults.ResSpheroid, 'nucleiiProps')
   AllSpheroidResults.ResSpheroid(1).nucleiiProps = []; 
end

for index = 1:length(AllSpheroidResults.ResSpheroid)
    if isempty(AllSpheroidResults.ResSpheroid(index).nucleiiProps)
    index
    sphereMask              = logical(zeros(size(AllSpheroidResults.ResSpheroid(index).interpolatedImage)));
    corIndex                = AllSpheroidResults.ResSpheroid(index).correctedLabels;
    tooBig                  = AllSpheroidResults.ResSpheroid(index).labelsForManualInspection;
    finalCorrectedSeedImage = AllSpheroidResults.ResSpheroid(index).firstCorrectedSeedImage;
    
    WSNucProps = regionprops3(AllSpheroidResults.ResSpheroid(index).waterShed, 'Volume', 'Centroid','VoxelList');
    
    for i = 1:length(AllSpheroidResults.ResSpheroid(index).labelsForManualInspection) %remove seeds generating nuclei clusters
        if ismember(tooBig(i), corIndex) 
            
            voxList = WSNucProps.VoxelList{tooBig(i)};
            finalCorrectedSeedImage(sub2ind(size(AllSpheroidResults.ResSpheroid(index).interpolatedImage),voxList(:,2), voxList(:,1), voxList(:,3))) = false;
        end
    end

    for i = 1:size(AllSpheroidResults.ResSpheroid(index).correctedLabels, 1) %Introduce manual seeds
        pixel  = AllSpheroidResults.ResSpheroid(index).correctedLabels(i, 2:4);
        radius = AllSpheroidResults.ResSpheroid(index).correctedLabels(i, 5);

        sphere               = strel('sphere', radius);
        xSpace               = (pixel(2)-radius):1:(pixel(2)+radius);
        ySpace               = (pixel(1)-radius):1:(pixel(1)+radius);
        zSpace               = (pixel(3)-radius):1:(pixel(3)+radius);

        sphereMask(xSpace,ySpace,zSpace) = logical(sphere.Neighborhood);

    end
    finalCorrectedSeedImage(sphereMask) = true; %Final seed mask
    
    % final watershed before analsyis
    if isfield(AllSpheroidResults.ResSpheroid, 'segmentedImage') && ~isempty(AllSpheroidResults.ResSpheroid(index).segmentedImage) 
        finalWS       = waterShedFromSeedImage(AllSpheroidResults.ResSpheroid(index).segmentedImage, finalCorrectedSeedImage);
    else
        AllSpheroidResults.ResSpheroid(index).segmentedImage = segmentImage3D(AllSpheroidResults.ResSpheroid(index).interpolatedImage, 0.7, 0.05);
        finalWS       = waterShedFromSeedImage(AllSpheroidResults.ResSpheroid(index).segmentedImage, finalCorrectedSeedImage);
    end
        
    trueSlices    = 1:2:size(AllSpheroidResults.ResSpheroid(index).interpolatedImage, 3);
    trueWS        = finalWS(:,:,trueSlices); 
    finalNucProps = regionprops3(finalWS, AllSpheroidResults.ResSpheroid(index).interpolatedImage, 'all');
    trueNucProps  = regionprops3(trueWS, AllSpheroidResults.ResSpheroid(index).originalImage,'Centroid', 'VoxelValues');
    
    
    properSize   = find(finalNucProps.Volume < median(finalNucProps.Volume)*1.3 & median(finalNucProps.Volume*0.7) < finalNucProps.Volume); % Volume gating
    sumIntensity = zeros(1, size(finalNucProps,1));
    corIntensity = zeros(1, size(finalNucProps,1));
    sumTrueInten = zeros(1, size(finalNucProps,1));
    corTrueInten = zeros(1, size(finalNucProps,1));
    trueZDist    = zeros(1, size(finalNucProps,1));
    trueZDist2   = zeros(1, size(finalNucProps,1));
    centerDist   = zeros(1, size(finalNucProps,1));
    centerDist2  = zeros(1, size(finalNucProps,1));
    mctsHull     = zeros(size(AllSpheroidResults.ResSpheroid(index).segmentedImage));

    for i = 1:size(mctsHull, 3)
        mctsHull(:,:,i) = bwconvhull(AllSpheroidResults.ResSpheroid(index).segmentedImage(:,:,i)); %create MCTS hull
    end

    centerMCTS = regionprops3(mctsHull, 'Centroid');
    centerMCTS = round(centerMCTS.Centroid);
    centerMCTS = [206 206 (size(AllSpheroidResults.ResSpheroid(index).segmentedImage,3)/2)];
    centerMCTS2 = [206 206 (size(AllSpheroidResults.ResSpheroid(index).originalImage,3)/2)];

    for i = 1:size(finalNucProps,1)
        xyz            = round(finalNucProps.Centroid(i,1:3));
        xyz2           = round(trueNucProps.Centroid(i,1:3));
        if isempty(find(AllSpheroidResults.ResSpheroid(index).segmentedImage(xyz(2),xyz(1),:),1))
            trueZDist(i)  = 0;
            trueZDist2(i)  = 0;
        else
        trueZDist(i)    = finalNucProps.Centroid(i,3)-find(AllSpheroidResults.ResSpheroid(index).segmentedImage(xyz(2),xyz(1),:),1); % calculate z-distance within MCTS
        centerDist(i)   = sqrt(sum((xyz-centerMCTS).^2)); % calculate distance from MCTS center
        centerDist2(i)  = sqrt(sum((xyz2-centerMCTS2).^2));
        trueZDist2(i)   = trueNucProps.Centroid(i,3)-find(AllSpheroidResults.ResSpheroid(index).segmentedImage(xyz2(2),xyz2(1),trueSlices),1);
        sumIntensity(i) = sum(finalNucProps.VoxelValues{i,1}); % measure DNA content
        sumTrueInten(i) = sum(trueNucProps.VoxelValues{i,1});
        end
    end

    intensityFit  = polyfit(trueZDist(properSize), sumIntensity(properSize),1); % correct intensity for z-depth
    intensityFit2 = polyfit(trueZDist2(properSize), sumTrueInten(properSize),1);

    for i=1:length(sumIntensity)% correct intensity for z-depth
        corrRatio = (-intensityFit(1)*trueZDist(i)+intensityFit(2))/intensityFit(2);
        corIntensity(i) = sumIntensity(i)*corrRatio; 
        corrRatio2 = (-intensityFit2(1)*trueZDist2(i)+intensityFit2(2))/intensityFit2(2);
        corTrueInten(i) = sumTrueInten(i)*corrRatio2; 
    end
    
    % Uppdate all the results
    AllSpheroidResults.ResSpheroid(index).finalWatershed = finalWS;
    AllSpheroidResults.ResSpheroid(index).mctsHull       = mctsHull;
    AllSpheroidResults.ResSpheroid(index).nucleiiProps   = finalNucProps;
    AllSpheroidResults.ResSpheroid(index).zDistance      = trueZDist;
    AllSpheroidResults.ResSpheroid(index).sumIntensity   = sumIntensity;
    AllSpheroidResults.ResSpheroid(index).corIntensity   = corIntensity;
    AllSpheroidResults.ResSpheroid(index).centerDist     = centerDist;
    AllSpheroidResults.ResSpheroid(index).sumTrueIntensity = sumTrueInten;
    AllSpheroidResults.ResSpheroid(index).corTrueIntensity = corTrueInten;
    AllSpheroidResults.ResSpheroid(index).trueCenterDist   = centerDist2;
    AllSpheroidResults.ResSpheroid(index).trueZDistance    = trueZDist2;
    end
end