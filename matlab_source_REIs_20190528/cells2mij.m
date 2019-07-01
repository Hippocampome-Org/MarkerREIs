function [areConverted] = cells2mij(csvFile, somataLoaded)
% hippocampome network graphics analysis
% 200904122120 David J. Halimton
%
% adapted from R to MATLAB 20090504 Diek W. Wheeler

    % retrieve markers data (manually stored in
    % current_markers_data)
    load markers.mat
    load markerToggles.mat
    if somataLoaded
        load somata.mat
        load sij.mat
    end    

    
    areConverted = 0;
    
    [nRows,nCols] = size(csvFile); 
        
    if ~isPrintAllActiveRows
        if isPrintOnlyRowsWithInfs
            usageVector = csvFile(rowSkip+1:nRows,hasInfColNum);
        elseif isPrintDataSubset1
            usageVector = csvFile(rowSkip+1:nRows,dataSubset_1_colNum);
        elseif isPrintDataSubset2
            usageVector = csvFile(rowSkip+1:nRows,dataSubset_2_colNum);
        elseif isPrintDataSubset3
            usageVector = csvFile(rowSkip+1:nRows,dataSubset_3_colNum);
        elseif isPrintDataSubset4
            usageVector = csvFile(rowSkip+1:nRows,dataSubset_4_colNum);
        end

        for i=1:length(usageVector)
            if isempty(usageVector{i})
                usageVector{i} = NaN;
            end
        end

        nAllCells = sum(cell2mat(usageVector)==1);
    end

    
    if isIncludeUntrackedMarkers_All
        nMarkersToPrint = nOfficialMarkers + nUnofficialMarkers;
    elseif isIncludeOnlyOfficialMarkersAndMarkersWithInfs
        nMarkersToPrint = nOfficialMarkers_PlusMarkersWithInfs;
    else
        nMarkersToPrint = nOfficialMarkers;
    end

    % initialize arrays & Mij matrix
    for i=1:nAllCells
        for j=1:nMarkersToPrint
            MijLevels{i,j} = 0;
        end
    end
    
    MijHaveInfo = zeros(nAllCells, nMarkersToPrint);
    MijTildes = zeros(nAllCells, nMarkersToPrint);
    MijCurly = cell(nAllCells,nMarkersToPrint);
    MijNumLevels = zeros(nAllCells, nMarkersToPrint);
    MijMethods = 3*ones(nAllCells, nMarkersToPrint);
    MijSpecies = 3*ones(nAllCells, nMarkersToPrint); 
    MijMixedFlagCodes = zeros(nAllCells, nMarkersToPrint);

    % retrieve marker names and save for plotting    
    markerLabels = csvFile(markerNamesRowNum,(1:nTotalMarkers)+colSkip);
    markerOrigPaperOrder = csvFile(markerOrigPaperOrderingRowNum,(1:nTotalMarkers)+colSkip);
    
    % retrieve cell labels and save for plotting    
    %cellUniqueIDsMarkers = csvFile((1:nAllCells)+rowSkip,uniqueIdColNum);
    %cellLabelsMarkers = csvFile((1:nAllCells)+rowSkip,labelColNum);
    %cellAbbrevsMarkers = csvFile((1:nAllCells)+rowSkip,abbrevColNum);
    
        
    iCell = 0;
    
    % loop over rows (cell types)
    for row = (rowSkip+1):nRows
        %if ~isempty(csvFile{row,cellIdColNum})
        if (csvFile{row,classStatusColNum} == 'N')
            
            if isPrintAllActiveRows || ...
                    (isPrintOnlyRowsWithInfs && usageVector{row-rowSkip}==1) || ...
                    (isPrintDataSubset1 && usageVector{row-rowSkip}==1) || ...
                    (isPrintDataSubset2 && usageVector{row-rowSkip}==1) || ...
                    (isPrintDataSubset3 && usageVector{row-rowSkip}==1) || ...
                    (isPrintDataSubset4 && usageVector{row-rowSkip}==1)
                
                iCell = iCell + 1;

                cellUniqueIDsMarkers(iCell) = csvFile(row,uniqueIdColNum);
                cellSubregionsMarkers{iCell} = csvFile(row,subregionColNum);
                cellLabelsMarkers{iCell} = csvFile{row,labelColNum};
                cellAbbrevsMarkers{iCell} = csvFile{row,abbrevColNum};
                MijPlusOrMinus{iCell} = csvFile{row,plusOrMinusColNum};
                MijAD_pattern{iCell} = num2str(csvFile{row,AD_patternColNum});

                indexSubregion = strfind(subregionOrder, cellSubregionsMarkers{iCell});
                index = find(not(cellfun('isempty', indexSubregion)));

                while length(MijAD_pattern{iCell}) < nParcels(index)
                    MijAD_pattern{iCell} = ['0' MijAD_pattern{iCell}];
                end

                MijProjecting{iCell} = csvFile{row,projectingColNum};


                % loop over columns (markers)
                for iMarker = 1:nTotalMarkers
                    col = iMarker + colSkip;

                    excelCellContents = csvFile{row,col};                
                    if ~isnan(excelCellContents)
                        if isnumeric(excelCellContents)
                            excelCellContents = num2str(excelCellContents);
                        end
                        excelCellContents = excelCellContents((isspace(excelCellContents))==0);
                        excelCellContents(strfind(excelCellContents,'"')) = [];
                    end

                    [MijHaveInfo(iCell,iMarker), MijTildes(iCell,iMarker), MijCurly{iCell,iMarker}, ...
                         MijNumLevels(iCell,iMarker), MijLevels{iCell,iMarker}, MijMethods(iCell,iMarker), ...
                         MijSpecies(iCell,iMarker), MijMixedFlagCodes(iCell,iMarker)] = parse_marker_codes(excelCellContents);                     
                end % for iMarker
                
            else
                thisCellSubregion = csvFile{row,subregionColNum};
                
                if strcmpi(thisCellSubregion, 'DG')
                    nCells(DG) = nCells(DG) - 1;
                elseif strcmpi(thisCellSubregion, 'CA3')
                    nCells(CA3) = nCells(CA3) - 1;
                elseif strcmpi(thisCellSubregion, 'CA2')
                    nCells(CA2) = nCells(CA2) - 1;
                elseif strcmpi(thisCellSubregion, 'CA1')
                    nCells(CA1) = nCells(CA1) - 1;
                elseif strcmpi(thisCellSubregion, 'SUB')
                    nCells(SUB) = nCells(SUB) - 1;
                elseif strcmpi(thisCellSubregion, 'EC')
                    nCells(EC) = nCells(EC) - 1;
                end
            end % if isPrintAllActiveRows || ...
        end % if (csvFile{row,classStatusColNum} == 'N')
    end % for iRow

    DGcells = DG*100 + 1:nCells(DG);
    CA3cells = CA3*100 + 1:nCells(CA3);
    CA2cells = CA2*100 + 1:nCells(CA2);
    CA1cells = CA1*100 + 1:nCells(CA1);
    SUBcells = SUB*100 + 1:nCells(SUB);
    ECcells = EC*100 + 1:nCells(EC);
    
    
    MijOverall = zeros(nAllCells,nOfficialMarkers);
    MijPos = zeros(nAllCells,nOfficialMarkers);
    MijNeg = zeros(nAllCells,nOfficialMarkers);

    for m=1:nAllCells
        for n=1:nOfficialMarkers
            if MijNumLevels(m,n) == 0

            elseif MijNumLevels(m,n) == 1
                if MijLevels{m,n} == 1
                    MijOverall(m,n) = 1;
                    MijPos(m,n) = 1;
                elseif MijLevels{m,n} == 2
                    MijOverall(m,n) = 2;
                    MijNeg(m,n) = 1;
                elseif MijLevels{m,n} == 3
                    MijOverall(m,n) = 1;
                    MijPos(m,n) = 1;
                end
            else
                hasMixedFlag = 0;
                for p=1:MijNumLevels(m,n)
                    thisLevels = MijLevels{m,n}{1};

                    if thisLevels(p) == 2
                        hasMixedFlag = 1;
                    end
                end
                
                if hasMixedFlag
                    MijOverall(m,n) = 4;
                    MijPos(m,n) = 1;
                    MijNeg(m,n) = 1;
                else % fake mixed flag due to pos and wk pos (no neg)
                    MijOverall(m,n) = 1;
                    MijPos(m,n) = 1;                    
                end
            end
        end
    end
    
    
    if isIncludeUntrackedMarkers_All
        %
    elseif isIncludeOnlyOfficialMarkersAndMarkersWithInfs
        MijCurly(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        MijTildes(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        MijHaveInfo(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        MijLevels(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        MijNumLevels(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        MijMethods(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        MijSpecies(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        MijMixedFlagCodes(:,nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        markerLabels(nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
        markerOrigPaperOrder(nOfficialMarkers_PlusMarkersWithInfs+1:nTotalMarkers) = [];
    else
        MijCurly(:,nOfficialMarkers+1:nTotalMarkers) = [];
        MijTildes(:,nOfficialMarkers+1:nTotalMarkers) = [];
        MijHaveInfo(:,nOfficialMarkers+1:nTotalMarkers) = [];
        MijLevels(:,nOfficialMarkers+1:nTotalMarkers) = [];
        MijNumLevels(:,nOfficialMarkers+1:nTotalMarkers) = [];
        MijMethods(:,nOfficialMarkers+1:nTotalMarkers) = [];
        MijSpecies(:,nOfficialMarkers+1:nTotalMarkers) = [];
        MijMixedFlagCodes(:,nOfficialMarkers+1:nTotalMarkers) = [];
        markerLabels(nOfficialMarkers+1:nTotalMarkers) = [];
        markerOrigPaperOrder(nOfficialMarkers+1:nTotalMarkers) = [];
    end

    
    cellUniqueIDsMarkers = strrep(cellUniqueIDsMarkers,'-','');

    areConverted = 1;

    save 'mij.mat' MijTildes MijHaveInfo MijCurly MijLevels MijNumLevels MijMethods MijSpecies MijMixedFlagCodes markerLabels markerOrigPaperOrder ...
        nMarkersToPrint ...
        MijOverall MijPos MijNeg ...
        cellUniqueIDsMarkers cellSubregionsMarkers cellLabelsMarkers cellAbbrevsMarkers MijPlusOrMinus ...
        MijAD_pattern MijProjecting ...
        nAllCells nCells DGcells CA3cells CA2cells CA1cells SUBcells ECcells

end % cells2mij
