%%NucSegmentation for a Series of Z-stacks
[allFileName, pathName, filtIndex] = uigetfile('../*.lsm', 'MultiSelect', 'on');
AllSpheroidResults = struct;

for fIndex = 1:length(allFileName) %Inital segmentation for all z-stacks in folder
    fIndex
    
    
    fileName    = [pathName allFileName{fIndex}];
    [info]      = lsmread(fileName, 'InfoOnly');
    
    
    [imageRaw]  = lsmread(fileName);
    imageOrg    = permute(squeeze(imageRaw(:,1,:,:,:)), [2 3 1]);  
    imageOrg    = im2single(imageOrg);
    ResSpheroid = struct; %All data is saved in matlab struct
    
    if info.dimC == 3
        greenOrg               = permute(squeeze(imageRaw(:,2,:,:,:)), [2 3 1]);  
        greenOrg               = im2single(greenOrg);
        redOrg                 = permute(squeeze(imageRaw(:,3,:,:,:)), [2 3 1]);  
        redOrg                 = im2single(redOrg);
        ResSpheroid.greenImage = greenOrg;
        ResSpheroid.redImage   = redOrg;
    end
    
    clear imageRaw
    
    ResSpheroid.imageInfo          = info;
    ResSpheroid.originalImage      = imageOrg;
    ResSpheroid.manuallyControlled = 0;
    ResSpheroid.pathName           = pathName;

    %%
    image                         = interpolateImage3D(imageOrg, info); %create isotrpic voxels
    segImage                      = segmentImage3D(image, 0.7, 0.05); %segment nuclei
    blurredSegImage               = segmentImage3D(image, 2, 0.1); % blurred segmention to remove small objects
    segImage                      = segImage.*blurredSegImage; %Take away all lonely pixels
    ResSpheroid.interpolatedImage = image;
    ResSpheroid.segmentedImage    = segImage;
    %%
    
    seed = seedGenerator3D(segImage); %generate catchment basins for watershed
    ws   = waterShedFromSeedImage(segImage, seed); %watershed separation
    %%
    firstWSNucProps = regionprops3(ws, 'Volume', 'Centroid','VoxelList');

    [tooSmall, properSize, ~] = volumeGating(firstWSNucProps, 0.7, 1.4); % find possible oversegmented nuclei
    firstCorrectedSeedImage = seed;

    for i = 1:length(tooSmall) %remove all seeds that generates small objects
       voxList = firstWSNucProps.VoxelList{tooSmall(i)};
       firstCorrectedSeedImage(sub2ind(size(image),voxList(:,2), voxList(:,1), voxList(:,3))) = false;
    end

    secondWS = waterShedFromSeedImage(segImage, firstCorrectedSeedImage); % second watershed separation


    secondWSNucProps = regionprops3(secondWS, 'Volume', 'Centroid','VoxelList');
    [~,~, tooBig]    = volumeGating(secondWSNucProps, 0.7, 1.4); %find all possible nuclei clusters for manual ahndling

    ResSpheroid.labelsForManualInspection = tooBig;
    ResSpheroid.waterShed                 = secondWS;
    ResSpheroid.firstCorrectedSeedImage = firstCorrectedSeedImage;
    
    AllSpheroidResults.ResSpheroid(fIndex) = ResSpheroid;
    
end

