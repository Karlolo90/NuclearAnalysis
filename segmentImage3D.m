function segmentedImage = segmentImage3D(rawImageIn, filterSigma, threshSens)
    %rawImageIn       = imadjustn(rawImageIn);
    filtImage        = imgaussfilt3(rawImageIn, filterSigma); %0.7
    segThresh        = adaptthresh(filtImage, threshSens, 'NeighborhoodSize', 2*floor(size(rawImageIn)/8)+1); %0.05
    segmentedImage   = imbinarize(filtImage,segThresh);
    segmentedImage   = bwareaopen(segmentedImage, 3000);
    segmentedImage   = imopen(segmentedImage, strel('sphere', 3));
    segmentedImage   = imclose(segmentedImage, strel('sphere', 2));
    segmentedImage   = imfill(segmentedImage, 'holes');

end 