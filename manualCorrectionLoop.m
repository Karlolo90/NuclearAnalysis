%% Correctioon of automatic segmentation

for index = 1:length(AllSpheroidResults.ResSpheroid)
    index
   if AllSpheroidResults.ResSpheroid(index).manuallyControlled == 0
       uiwait(ManualCorrectionGUI(AllSpheroidResults.ResSpheroid(index)));
        %%
       AllSpheroidResults.ResSpheroid(index).manuallyControlled = 1;
       AllSpheroidResults.ResSpheroid(index).correctedLabels = correctedPixels;
   end 
end

