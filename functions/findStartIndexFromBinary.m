function startIndex = findStartIndexFromBinary(data)

    mask = zeros(size(data.imageAll), 'logical');
    for i = 1:size(mask, 3)
        mask(:,:,i) = imbinarize(data.imageAll(:,:,i), 0.2);
    end
    
    for i = 1:size(mask, 3)
        current = mask(:,:,i);
        if sum(current(:)) > 200
            startIndex = i;
            break
        end
    end
end