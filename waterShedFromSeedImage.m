function waterShedImage = waterShedFromSeedImage(SegImageIn, seedImageIn)

    dist  = bwdist(~SegImageIn); %Distance transform
    dist  = round(dist); 
    dist  = imhmin(dist, 5); % remove all local variations in distance
    maskImage = imimposemin(-dist, seedImageIn); %Impose catchment basins
    maskImage(~SegImageIn) = Inf;
    waterShedImage = watershed(maskImage);
    waterShedImage(~SegImageIn) = 0;

end