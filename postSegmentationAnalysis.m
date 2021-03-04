res24 = load('New nucleii data/20180123_24h_newData_corrected.mat');
res48 = load('New nucleii data/20180123_48h_newData_corrected.mat');
res96 = load('New nucleii data/20180123_96h_newData_corrected.mat');
%%
voxVol = res24.AllSpheroidResults.ResSpheroid(1).imageInfo.voxSizeX^3;
voxLen = res24.AllSpheroidResults.ResSpheroid(1).imageInfo.voxSizeX;

dnaCorr    = [];
dnaNorm    = [];
perimDist  = [];
volume     = [];
indexNuc   = [];
indexMCTS  = [];
indexPlate = [];
majorAxis  = [];
medAxis    = [];
minorAxis  = [];
extent     = [];
surfArea   = [];
nucAngle   = [];
nucAngle2  = [];
nucZAngle  = [];
eigVec1    = [];
eigVec2    = [];
eigVec3    = [];
eigVal     = [];
nucXYZ     = [];
mctsVol    = [];
mctsDia    = [];
mctsNucNum = [];
midNucVec  = [];
nucDens3   = [];
nucDens5   = [];
nucDens10  = [];

relVolume  = [];
relSurf    = [];
relMajAxis = [];
relMedAxis = [];
relMinAxis = [];

indexNucBig     = [];
indexPlateBig   = [];
indexMCTSBig    = [];
volBig          = [];
dnaNormBig      = [];
perimDistBig    = [];

indexNucSmall   = [];
indexPlateSmall = [];
volSmall        = [];
dnaNormSmall    = [];
perimDistSmall  = [];



for i = [1 3]
    i
    if i ==1
        mctsRes = res24.AllSpheroidResults.ResSpheroid;
    elseif i == 2
        mctsRes = res48.AllSpheroidResults.ResSpheroid;
    else
        mctsRes = res96.AllSpheroidResults.ResSpheroid;
    end
    for n = 1:length(mctsRes) 
        n
        [mctsPerim, nucDens] = getPerimeterNucDist(mctsRes(n).finalWatershed, mctsRes(n).nucleiiProps);
        mctsHull             = mctsPerim>0;
        mctsProps            = regionprops3(mctsHull, 'Centroid','Volume','EquivDiameter');
        if size(mctsProps,1) > 1
            [~,correct] = max(mctsProps.Volume);
            mctsProps   = mctsProps(correct,:);
        end
        
        %[~, proper, ~] = volumeGating(mctsRes(n).nucleiiProps, 0.6, 1.8);
        [tooSmall, proper, tooBig]  = volumeGating(mctsRes(n).nucleiiProps, 0.6, 1.8);
        tempIndex                   = ones(1,length(proper));
        indexNuc                    = [indexNuc proper'];
        indexNucBig                 = [indexNucBig tooBig'];
        indexPlateBig               = [indexPlateBig ones(1,length(tooBig))*i];
        indexMCTSBig                = [indexMCTSBig ones(1,length(tooBig))*n];
        indexPlateSmall             = [indexPlateSmall ones(1,length(tooSmall))*i];
        indexNucSmall               = [indexNucSmall tooSmall'];
        indexMCTS                   = [indexMCTS n*tempIndex];
        indexPlate                  = [indexPlate i*tempIndex];
        
        for k = 1:length(proper)
            xCent     = round(mctsRes(n).nucleiiProps.Centroid(proper(k),1));
            yCent     = round(mctsRes(n).nucleiiProps.Centroid(proper(k),2));
            zCent     = round(mctsRes(n).nucleiiProps.Centroid(proper(k),3));
            tempEvec  = mctsRes(n).nucleiiProps.EigenVectors{proper(k)};
            tempEvec  = tempEvec([2 1 3],:);
            tempEval  = mctsRes(n).nucleiiProps.EigenValues{proper(k)};
            nucXYZ    = [nucXYZ; [xCent yCent zCent]];
            eigVec1   = [eigVec1; tempEvec(:,1)'];
            eigVec2   = [eigVec2; tempEvec(:,2)'];
            eigVec3   = [eigVec3; tempEvec(:,3)'];
            eigVal    = [eigVal; tempEval'];
            eigNorm   = cross(tempEvec(:,1), tempEvec(:,2));
            perimDist = [perimDist mctsPerim(yCent, xCent, zCent)];
            centVec   = [xCent yCent zCent] - mctsProps.Centroid;
            midNucVec = [midNucVec; centVec];
            centNAng  = abs(90-acosd(dot(eigNorm,centVec)/(norm(eigNorm)*norm(centVec))));
            zAngle    = abs(90-acosd(dot(eigNorm,[0 0 1])/(norm(eigNorm)*norm([0 0 1]))));
            centAngE1 = abs(acosd(dot(tempEvec(:,1),centVec)/(norm(tempEvec(:,1))*norm(centVec))));
            nucAngle  = [nucAngle centNAng];
            nucAngle2 = [nucAngle2 centAngE1];
            nucZAngle = [nucZAngle zAngle];
        end
        
        
        nucInterDist              = pdist2(mctsRes(n).nucleiiProps.Centroid(proper,:), mctsRes(n).nucleiiProps.Centroid(proper,:), 'euclidean');
        [nucInterDist, distIndex] = sort(nucInterDist, 2);
        tempVol                   = mctsRes(n).nucleiiProps.Volume(proper);
        tempRelVolume             = [tempVol(distIndex(:,2)) tempVol(distIndex(:,3)) tempVol(distIndex(:,4)) tempVol(distIndex(:,5)) tempVol(distIndex(:,6))];
        tempRelVolume             = mean(tempRelVolume,2);
        tempSurf                  = mctsRes(n).nucleiiProps.SurfaceArea(proper);
        tempRelSurf               = [tempSurf(distIndex(:,2)) tempSurf(distIndex(:,3)) tempSurf(distIndex(:,4)) tempSurf(distIndex(:,5)) tempSurf(distIndex(:,6))];
        tempRelSurf               = mean(tempRelSurf,2);
        tempMajAxis               = mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,1);
        tempRelMajAxis            = [tempMajAxis(distIndex(:,2)) tempMajAxis(distIndex(:,3)) tempMajAxis(distIndex(:,4)) tempMajAxis(distIndex(:,5)) tempMajAxis(distIndex(:,6))];
        tempRelMajAxis            = mean(tempRelMajAxis,2);
        tempMedAxis               = mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,2);
        tempRelMedAxis            = [tempMedAxis(distIndex(:,2)) tempMedAxis(distIndex(:,3)) tempMedAxis(distIndex(:,4)) tempMedAxis(distIndex(:,5)) tempMedAxis(distIndex(:,6))];
        tempRelMedAxis            = mean(tempRelMedAxis,2);
        tempMinAxis               = mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,3);
        tempRelMinAxis            = [tempMinAxis(distIndex(:,2)) tempMinAxis(distIndex(:,3)) tempMinAxis(distIndex(:,4)) tempMinAxis(distIndex(:,5)) tempMinAxis(distIndex(:,6))];
        tempRelMinAxis            = mean(tempRelMinAxis,2);
        
        
        nucDens       = sort(nucDens,2);
        nucDens3cell  = mean(nucDens(proper,2:4),2);
        nucDens5cell  = mean(nucDens(proper,2:6),2);
        nucDens10cell = mean(nucDens(proper,2:11),2);
        
        nucDens3       = [nucDens3 nucDens3cell'];
        nucDens5       = [nucDens5 nucDens5cell'];
        nucDens10      = [nucDens10 nucDens10cell'];
        dnaCorr        = [dnaCorr mctsRes(n).corIntensity(proper)];
        dnaNorm        = [dnaNorm mctsRes(n).corIntensity(proper)./median(mctsRes(n).corIntensity(proper))];
        volume         = [volume mctsRes(n).nucleiiProps.Volume(proper)'];
        extent         = [extent mctsRes(n).nucleiiProps.Extent(proper)'];
        majorAxis      = [majorAxis mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,1)'];
        medAxis        = [medAxis mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,2)'];
        minorAxis      = [minorAxis mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,3)'];
        surfArea       = [surfArea mctsRes(n).nucleiiProps.SurfaceArea(proper)'];
        
        relVolume      = [relVolume mctsRes(n).nucleiiProps.Volume(proper)'./tempRelVolume'];
        relSurf        = [relSurf mctsRes(n).nucleiiProps.SurfaceArea(proper)'./tempRelSurf'];
        relMajAxis     = [relMajAxis mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,1)'./tempRelMajAxis'];
        relMedAxis     = [relMedAxis mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,2)'./tempRelMedAxis'];
        relMinAxis     = [relMinAxis mctsRes(n).nucleiiProps.PrincipalAxisLength(proper,3)'./tempRelMinAxis'];
        
        mctsVol    = [mctsVol mctsProps.Volume];
        mctsDia    = [mctsDia mctsProps.EquivDiameter];
        mctsNucNum = [mctsNucNum length(proper)];
        
        for k = 1:length(tooBig)
            xCent           = round(mctsRes(n).nucleiiProps.Centroid(tooBig(k),1));
            yCent           = round(mctsRes(n).nucleiiProps.Centroid(tooBig(k),2));
            zCent           = round(mctsRes(n).nucleiiProps.Centroid(tooBig(k),3));
            perimDistBig    = [perimDistBig mctsPerim(yCent, xCent, zCent)];
        end
        for k = 1:length(tooSmall)
            xCent           = round(mctsRes(n).nucleiiProps.Centroid(tooSmall(k),1));
            yCent           = round(mctsRes(n).nucleiiProps.Centroid(tooSmall(k),2));
            zCent           = round(mctsRes(n).nucleiiProps.Centroid(tooSmall(k),3));
            perimDistSmall  = [perimDistSmall mctsPerim(yCent, xCent, zCent)];
        end
        
        volBig          = [volBig mctsRes(n).nucleiiProps.Volume(tooBig)'];
        dnaNormBig      = [dnaNormBig mctsRes(n).corIntensity(tooBig)./median(mctsRes(n).corIntensity(proper))];
        volSmall        = [volSmall mctsRes(n).nucleiiProps.Volume(tooSmall)'];
        dnaNormSmall    = [dnaNormSmall mctsRes(n).corIntensity(tooSmall)./median(mctsRes(n).corIntensity(proper))];
    end
    
    
end
sphericity = pi^(1/3)*(6*volume).^(2/3)./surfArea;
load('cellCylceSVM_model.mat')
%% Sg2 Classification
xData = [dnaNorm; relVolume; relSurf; extent; relMajAxis; relMedAxis; relMinAxis; sphericity];

sg2_target = predict(cellCycleSVM_model, xData');


%% plotPreparations
perimDistMicron = perimDist*mctsRes(1).imageInfo.voxSizeX;

ind24 = indexPlate == 1;
ind48 = indexPlate == 2;
ind96 = indexPlate == 3;

ind24_non0 = indexPlate == 1 & perimDistMicron > 0;
ind48_non0 = indexPlate == 2 & perimDistMicron > 0;
ind96_non0 = indexPlate == 3 & perimDistMicron > 0;

sg2Pos_24 = length(find(sg2_target(ind24)==2))/sum(ind24);
sg2Pos_48 = length(find(sg2_target(ind48)==2))/sum(ind48);
sg2Pos_96 = length(find(sg2_target(ind96)==2))/sum(ind96);

layer10 = find(perimDistMicron > 0 & perimDistMicron <= 0.00001);
layer20 = find(perimDistMicron > 0.00001 & perimDistMicron <= 0.00003);
layer30 = find(perimDistMicron > 0.00003);
%allNon0 = [layer10 layer20 layer30];
allNon0 = zeros(1, length(dnaNorm));
allNon0(ind24_non0) = 1;
allNon0(ind96_non0) = 1;
allNon0 = allNon0==1;

layer10_24_sg2Pos = [];
layer20_24_sg2Pos = [];
layer30_24_sg2Pos = [];
layer10_48_sg2Pos = [];
layer20_48_sg2Pos = [];
layer30_48_sg2Pos = [];
layer10_96_sg2Pos = [];
layer20_96_sg2Pos = [];
layer30_96_sg2Pos = [];

scatterMajorMinor               = majorAxis./minorAxis;
scatterMajorInter               = majorAxis./medAxis;

for n = 1:10
    ind24_mcts = find(indexMCTS(ind24) == n);
    ind48_mcts = find(indexMCTS(ind48) == n);
    ind96_mcts = find(indexMCTS(ind96) == n);
    
    layer10_24_sg2Pos = [layer10_24_sg2Pos  length(find(dnaNorm(ind24_mcts(ismember(ind24_mcts,layer10)))>1.3))/length(ind24_mcts(ismember(ind24_mcts,layer10)))];
    layer20_24_sg2Pos = [layer20_24_sg2Pos  length(find(dnaNorm(ind24_mcts(ismember(ind24_mcts,layer20)))>1.3))/length(ind24_mcts(ismember(ind24_mcts,layer20)))];
    layer30_24_sg2Pos = [layer30_24_sg2Pos  length(find(dnaNorm(ind24_mcts(ismember(ind24_mcts,layer30)))>1.3))/length(ind24_mcts(ismember(ind24_mcts,layer30)))];
    
    layer10_48_sg2Pos = [layer10_48_sg2Pos  length(find(dnaNorm(ind48_mcts(ismember(ind48_mcts,layer10)))>1.3))/length(ind48_mcts(ismember(ind48_mcts,layer10)))];
    layer20_48_sg2Pos = [layer20_48_sg2Pos  length(find(dnaNorm(ind48_mcts(ismember(ind48_mcts,layer20)))>1.3))/length(ind48_mcts(ismember(ind48_mcts,layer20)))];
    layer30_48_sg2Pos = [layer30_48_sg2Pos  length(find(dnaNorm(ind48_mcts(ismember(ind48_mcts,layer30)))>1.3))/length(ind48_mcts(ismember(ind48_mcts,layer30)))];
    
    layer10_96_sg2Pos = [layer10_96_sg2Pos  length(find(dnaNorm(ind96_mcts(ismember(ind96_mcts,layer10)))>1.3))/length(ind96_mcts(ismember(ind96_mcts,layer10)))];
    layer20_96_sg2Pos = [layer20_96_sg2Pos  length(find(dnaNorm(ind96_mcts(ismember(ind96_mcts,layer20)))>1.3))/length(ind96_mcts(ismember(ind96_mcts,layer20)))];
    layer30_96_sg2Pos = [layer30_96_sg2Pos  length(find(dnaNorm(ind96_mcts(ismember(ind96_mcts,layer30)))>1.3))/length(ind96_mcts(ismember(ind96_mcts,layer30)))];
end

mean_vol24  = [];
mean_vol48  = [];
mean_vol96  = [];
mean_dens24 = [];
mean_dens48 = [];
mean_dens96 = [];
mean_ang24  = [];
mean_ang48  = [];
mean_ang96  = [];
mean_aRa24  = [];
mean_aRa96  = [];
mean_mRa24  = [];
mean_mRa96  = [];

std_vol24  = [];
std_vol48  = [];
std_vol96  = [];
std_dens24 = [];
std_dens48 = [];
std_dens96 = [];
std_ang24  = [];
std_ang48  = [];
std_ang96  = [];
std_aRa24  = [];
std_aRa96  = [];
std_mRa24  = [];
std_mRa96  = [];
layerGroup = zeros(length(perimDistMicron),1);

for n = 1:10
    mean_vol24  = [mean_vol24 mean(volume(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))*voxVol*10^18];
    mean_vol48  = [mean_vol48 mean(volume(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==2 & sg2_target' == 1)))*voxVol*10^18];
    mean_vol96  = [mean_vol96 mean(volume(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))*voxVol*10^18];
    mean_dens24 = [mean_dens24 mean(nucDens5(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))*voxLen*10^6];
    mean_dens48 = [mean_dens48 mean(nucDens5(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==2 & sg2_target' == 1)))*voxLen*10^6];
    mean_dens96 = [mean_dens96 mean(nucDens5(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))*voxLen*10^6];
    mean_ang24  = [mean_ang24 median(nucAngle(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))];
    mean_ang48  = [mean_ang48 median(nucAngle(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==2 & sg2_target' == 1)))];
    mean_ang96  = [mean_ang96 median(nucAngle(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))];

    mean_aRa24  = [mean_aRa24 mean(scatterMajorMinor(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))];
    mean_aRa96  = [mean_aRa96 mean(scatterMajorMinor(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))];
    mean_mRa24  = [mean_mRa24 mean(scatterMajorInter(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))];
    mean_mRa96  = [mean_mRa96 mean(scatterMajorInter(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))];
    
    std_vol24  = [std_vol24 std(volume(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))*voxVol*10^18];
    std_vol48  = [std_vol48 std(volume(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==2 & sg2_target' == 1)))*voxVol*10^18];
    std_vol96  = [std_vol96 std(volume(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))*voxVol*10^18];
    std_dens24 = [std_dens24 std(nucDens5(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))*voxLen*10^6];
    std_dens48 = [std_dens48 std(nucDens5(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==2 & sg2_target' == 1)))*voxLen*10^6];
    std_dens96 = [std_dens96 std(nucDens5(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))*voxLen*10^6];
    std_ang24  = [std_ang24 mad(nucAngle(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)),1)];
    std_ang48  = [std_ang48 mad(nucAngle(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==2 & sg2_target' == 1)),1)];
    std_ang96  = [std_ang96 mad(nucAngle(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)),1)];
    
    std_aRa24  = [std_aRa24 std(scatterMajorMinor(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))];
    std_aRa96  = [std_aRa96 std(scatterMajorMinor(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))];
    std_mRa24  = [std_mRa24 std(scatterMajorInter(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==1 & sg2_target' == 1)))];
    std_mRa96  = [std_mRa96 std(scatterMajorInter(find(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005 & indexPlate ==3 & sg2_target' == 1)))];
    
    layerGroup(perimDistMicron >= n*0.000005 & perimDistMicron < (n+1)*0.000005)    = n;
    
end

Bsg2Pos24  = [];
Bsg2Pos48  = [];
Bsg2Pos96  = [];
Bsg2Pos24N = [];
Bsg2Pos48N = [];
Bsg2Pos96N = [];

Bsg2Pos24_mean  = [];
Bsg2Pos48_mean  = [];
Bsg2Pos96_mean  = [];
Bsg2Pos24N_mean = [];
Bsg2Pos48N_mean = [];
Bsg2Pos96N_mean = [];


Bsg2Pos24_std  = [];
Bsg2Pos48_std  = [];
Bsg2Pos96_std  = [];
Bsg2Pos24N_std = [];
Bsg2Pos48N_std = [];
Bsg2Pos96N_std = [];

sg2Pos24_allMean = [];
sg2Pos48_allMean = [];
sg2Pos96_allMean = [];

sg2Pos24_allMeanN = [];
sg2Pos48_allMeanN = [];
sg2Pos96_allMeanN = [];

for n = 0:5
    
    Bsg2Pos24   = [Bsg2Pos24 length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 1 & sg2_target' == 2))];
    Bsg2Pos48   = [Bsg2Pos48 length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 2 & sg2_target' == 2))];
    Bsg2Pos96   = [Bsg2Pos96 length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 3 & sg2_target' == 2))];
    Bsg2Pos24N  = [Bsg2Pos24N length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 1 & sg2_target' == 2))/length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 1))];
    Bsg2Pos48N  = [Bsg2Pos48N length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 2 & sg2_target' == 2))/length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 2))];
    Bsg2Pos96N  = [Bsg2Pos96N length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 3 & sg2_target' == 2))/length(find(perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 3))];
    
    temp_mean24  = [];
    temp_mean48  = [];
    temp_mean96  = [];
    tempN_mean24 = [];
    tempN_mean48 = [];
    tempN_mean96 = [];
    for i = 1:10
        temp_mean24  = [temp_mean24 length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 1 & sg2_target' == 2))];
        temp_mean48  = [temp_mean48 length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 2 & sg2_target' == 2))];
        temp_mean96  = [temp_mean96 length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 3 & sg2_target' == 2))];
        tempN_mean24 = [tempN_mean24 length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 1 & sg2_target' == 2))...
                                     /length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 1))];
        tempN_mean48 = [tempN_mean48 length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 2 & sg2_target' == 2))...
                                     /length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 2))];
        tempN_mean96 = [tempN_mean96 length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 3 & sg2_target' == 2))...
                                      /length(find(indexMCTS == i & perimDistMicron >= n*0.00001 & perimDistMicron < (n+1)*0.00001 & indexPlate == 3))];
    end
    
    Bsg2Pos24_mean  = [Bsg2Pos24_mean mean(temp_mean24, 'omitnan')];
    Bsg2Pos48_mean  = [Bsg2Pos48_mean mean(temp_mean48, 'omitnan')];
    Bsg2Pos96_mean  = [Bsg2Pos96_mean mean(temp_mean96, 'omitnan')];
    Bsg2Pos24N_mean = [Bsg2Pos24N_mean mean(tempN_mean24, 'omitnan')];
    Bsg2Pos48N_mean = [Bsg2Pos48N_mean mean(tempN_mean48, 'omitnan')];
    Bsg2Pos96N_mean = [Bsg2Pos96N_mean mean(tempN_mean96, 'omitnan')];

    Bsg2Pos24_std  = [Bsg2Pos24_std std(temp_mean24, 'omitnan')];
    Bsg2Pos48_std  = [Bsg2Pos48_std std(temp_mean48, 'omitnan')];
    Bsg2Pos96_std  = [Bsg2Pos96_std std(temp_mean96, 'omitnan')];
    Bsg2Pos24N_std = [Bsg2Pos24N_std std(tempN_mean24, 'omitnan')];
    Bsg2Pos48N_std = [Bsg2Pos48N_std std(tempN_mean48, 'omitnan')];
    Bsg2Pos96N_std = [Bsg2Pos96N_std std(tempN_mean96, 'omitnan')];
    
    sg2Pos24_allMean = [sg2Pos24_allMean; temp_mean24];
    sg2Pos48_allMean = [sg2Pos48_allMean; temp_mean48];
    sg2Pos96_allMean = [sg2Pos96_allMean; temp_mean96];
    
    sg2Pos24_allMeanN = [sg2Pos24_allMeanN; tempN_mean24];
    sg2Pos48_allMeanN = [sg2Pos48_allMeanN; tempN_mean48];
    sg2Pos96_allMeanN = [sg2Pos96_allMeanN; tempN_mean96];
end