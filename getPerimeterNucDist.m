%% getMCTSPerimeter

function [perimDist, nucInterDist] = getPerimeterNucDist(ws,nucProps)
    nucInterDist  = pdist2(nucProps.Centroid, nucProps.Centroid, 'euclidean');
    meanInterDist = sort(nucInterDist,2);
    meanInterDist = mean(meanInterDist(:,2:6), 2);
    outlierIndex  = find(meanInterDist > 50);
    perimDist     = ws;
    
    for i = 1:length(outlierIndex)
        perimDist(perimDist==outlierIndex(i)) = 0;
    end
    perimDist(perimDist>0.5) = 1;
    perimDist                = imdilate(perimDist, ones(51,51,51));
    perimDist                = imerode(perimDist, ones(46,46,46));
    perimDist                = padarray(perimDist,[1 1 1]);
    perimDist                = bwdist(~perimDist,'quasi-euclidean');
    %perimDist                = imgaussfilt3(perimDist,10);
    perimDist                = perimDist(2:end-1, 2:end-1, 2:end-1);
    
end