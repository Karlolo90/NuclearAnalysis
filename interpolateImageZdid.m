function interImage = interpolateImageZdid(inImage);

[m,n,k] = size(inImage);
ratio = k/m;
[x,y,z] = meshgrid(1:m,1:n,1:k);
[xq,yq,zq] = meshgrid(1:m,1:n,ratio:ratio:k);

interImage = interp3(x,y,z,inImage,xq,yq,zq,'linear',0);
end