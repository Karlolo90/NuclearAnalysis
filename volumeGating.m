function [small, proper, big] = volumeGating(nucPropsIn, lowLimit, highLimit)

    big     = find(nucPropsIn.Volume > median(nucPropsIn.Volume)*highLimit);
    proper  = find(nucPropsIn.Volume < median(nucPropsIn.Volume)*highLimit & median(nucPropsIn.Volume*lowLimit) < nucPropsIn.Volume);
    small   = find(nucPropsIn.Volume < median(nucPropsIn.Volume)*lowLimit);

end