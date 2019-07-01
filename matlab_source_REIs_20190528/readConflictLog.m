function infConflictCode = readConflictLog(thisTypeID, thisMarker)
    load markers.mat conflictLogFileName
    logIDcol = 2;
    logMarkerCol = 3;
    logInterpCol = 4;
    
    [dummy1, dummy2, spreadsheetRaw] = xlsread(conflictLogFileName);    
    numLogRows = size(spreadsheetRaw,1);
    
    thisTypeID = str2double(thisTypeID);
    foundInLog = 0;

    % start at 2 because of header row in log
    for i=2:numLogRows
        if thisTypeID==spreadsheetRaw{i,logIDcol} && strcmpi(thisMarker, spreadsheetRaw{i,logMarkerCol})
            foundInLog = 1;
            interpText = spreadsheetRaw{i,logInterpCol};
            
            switch lower(interpText)
                case 'unresolved'
                    infConflictCode = '{a}';
                case 'species/protocol'
                    infConflictCode = '{b}';
                case 'subtypes'
                    infConflictCode = '{pi,ni}';
                otherwise
                    infConflictCode = '{pi,ni}';
            end
        end
    end
    
    if foundInLog==0
        infConflictCode = '{pi,ni}';
    end
end

