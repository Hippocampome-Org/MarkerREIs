function [somataFileName, infersFileName] = current_marker_data(cells)

    % manually specifies location and type of data in cells
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Hippocampome_v1.3alpha_worksheets.csv
    hippocampomeVersion = cells{4,3};

    % indicates order of subregions
    nSubregions = 6;
    DG  = 1;
    CA3 = 2;
    CA2 = 3;
    CA1 = 4;
    SUB = 5;
    EC  = 6;
    
    subregionOrder = {'DG' 'CA3' 'CA2' 'CA1' 'SUB' 'EC'};
    
    nParcels = [4 5 4 4 3 6];
    
    % specify how many rows and columns contain header data
    markerIdRowNum = 1;
    markerOrigPaperOrderingRowNum = 4;
    markerNamesRowNum = 6;
    rowSkip = 7; % rows to skip
    
    colSkip = 16; % cols to skip
    classStatusColNum = 2;
    cellIdColNum = 3;
    subregionColNum = 4;
    uniqueIdColNum = 6;
    labelColNum = 7;
    
    plusOrMinusColNum = 8;
    AD_patternColNum = 9;
    projectingColNum = 10;
        
    abbrevColNum = labelColNum;
    
    nOfficialMarkers = 20;
    nOfficialMarkers_PlusMarkersWithInfs = 36;
    nTotalMarkers = 98;
    nUnofficialMarkers = nTotalMarkers - nOfficialMarkers;
    notesColNum = colSkip + nTotalMarkers + 1;
    hasInfColNum = colSkip + nTotalMarkers + 4;
    dataSubset_1_colNum = colSkip + nTotalMarkers + 5;
    dataSubset_2_colNum = colSkip + nTotalMarkers + 6;
    dataSubset_3_colNum = colSkip + nTotalMarkers + 7;
    dataSubset_4_colNum = colSkip + nTotalMarkers + 8;

    [nRows, nCols] = size(cells);
    nCells(nSubregions) = 0;

    for i = 1:nRows
        if ~isempty(cells{i,subregionColNum})
            if (strcmp(cells{i,classStatusColNum}, 'N'))
                cellSubregion = cells{i,subregionColNum};
                if strcmpi(cellSubregion, 'DG')
                    nCells(DG) = nCells(DG) + 1;
                elseif strcmpi(cellSubregion, 'CA3')
                    nCells(CA3) = nCells(CA3) + 1;
                elseif strcmpi(cellSubregion, 'CA2')
                    nCells(CA2) = nCells(CA2) + 1;
                elseif strcmpi(cellSubregion, 'CA1')
                    nCells(CA1) = nCells(CA1) + 1;
                elseif strcmpi(cellSubregion, 'SUB')
                    nCells(SUB) = nCells(SUB) + 1;
                elseif strcmpi(cellSubregion, 'EC')
                    nCells(EC) = nCells(EC) + 1;
                end
            end
        end
    end % i loop

    nAllCells = sum(nCells);
    nAllParcels = sum(nParcels);

    DGcells = DG*100 + (1:nCells(DG));
    CA3cells = CA3*100 + (1:nCells(CA3));
    CA2cells = CA2*100 + (1:nCells(CA2));
    CA1cells = CA1*100 + (1:nCells(CA1));
    SUBcells = SUB*100 + (1:nCells(SUB));
    ECcells = EC*100 + (1:nCells(EC));

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    somataFileName = './support_datafiles/_Hippocampome_somata_active_20170124.xlsx';
    infersFileName = './support_datafiles/_Hippocampome_inferences_20190528.xlsx';
    conflictLogFileName = './support_datafiles/_Conflict_Evaluation_Log_20160401-20170123.xlsx';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    clear i j nRows nCols

    save markers.mat *

