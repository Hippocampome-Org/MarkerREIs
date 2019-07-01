function [markerLevel] = parse_marker_presence_levels(strng)

    idx = find(strng == '.');
    
    nLevels = length(idx);

    for i = 1:nLevels

        levels(i) = str2num(strng(idx(i)-3));

    end % for i 

    if (sum(levels) == nLevels*levels(1)) % all levels in current
                                          % spreadsheet cell are identical

        markerLevel = levels(1);
        
    else
        
        markerLevel = 5;
        
    end
    
    % 0 = unknown
    % 1 = positive
    % 2 = negative
    % 3 = weak positive
    % 4 = signal in some but not all neurons of this type
    % 5 = conflicting data

end % parse_marker_presence_levels
