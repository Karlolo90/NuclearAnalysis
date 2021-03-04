function seedImage = seedGenerator3D(segImageIn)
    dist  = bwdist(~segImageIn); %Distance transform
    dist  = round(dist); %smooth
    dist  = imhmin(dist, 4); % remove small local variations
    seedImage = imregionalmax(dist); % find local maxima points
    seedImage = imdilate(seedImage, strel('sphere', 3)); %connect maxima in close proximity
    seedImage = imclose(seedImage, strel('sphere', 3));
    
end