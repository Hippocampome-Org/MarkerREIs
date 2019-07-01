%% convert 0/1 to 'NO'/'YES' %%
function [theStr] = bin2str(binaryNumber)
    if binaryNumber == 0
        theStr = 'NO';
    elseif binaryNumber == 1
        theStr = 'YES';
    end 
end