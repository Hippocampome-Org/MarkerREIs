function [markerRefIds] = parse_marker_ref_ids(strng)

    idx = find(strng == '.');
    
    nIds = length(idx);

    for i = 1:length(idx)

        markerRefIds(i) = str2num(strng(idx-3));

    end % for i 

end % parse_marker_ref_ids