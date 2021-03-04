function interpolatedImage = interpolateImage3D(rawImageIn, info)
    xzRatio           = round(info.voxSizeZ/(info.voxSizeX));
    initSize          = size(rawImageIn);  
    interpolatedImage = zeros(512,512, (xzRatio*initSize(3)-1));
    interpolatedImage = im2single(interpolatedImage);
    i2 = 1;

    for i = 1:1:(initSize(3)-1)
        imPart = imresize3(rawImageIn(:,:,[i i+1]),[512 512 xzRatio+1]);
        for n = 1:xzRatio
            interpolatedImage(:,:,i2+n-1) = imPart(:,:,n);
        end
        i2 = i2 + xzRatio;
    end
end