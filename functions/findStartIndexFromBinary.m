function startIndex = findStartIndexFromBinary(data)
    mask = imbinarize(data.imageAll, 0.2);
    for i = 1:size(mask, 3)
        current = mask(:,:,i);
        if sum(current(:)) > 200
            startIndex = i;
            break
        end
    end
end