function bw_out = bwwatershed(bw, watershedSensitivity)
    
    bw = ~bwareaopen(~bw, 10);
    D = bwdist(~bw);
    D = -D;
    %D(~bw) = Inf;
    mask = imextendedmin(D, watershedSensitivity);
    
    D2 = imimposemin(D, mask);
    L = watershed(D2);
    L(~bw) = 0;
    bw_out = L;
    bw_out(bw_out>1) = 1;
    bw_out=imbinarize(bw_out);
end