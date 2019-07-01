function [somataLoaded] = cells2sij(somataFile)
% hippocampome network graphics analysis
% 200904122120 David J. Halimton
%
% adapted from R to MATLAB 20090504 Diek W. Wheeler

    load mij.mat cellUniqueIDsMarkers cellLabelsMarkers nAllCells
    load somata.mat

    
    cellIDsDiff = 0;

    [nRows,nCols] = size(somataFile);

    somataLocations = zeros(somata_nAllCells, somata_nParcels);

    
    somaFileIDarray = cell2mat(somataFile(somata_rowSkip+1:nRows,somata_UniqueIDColNum));
    cellUniqueIDsMarkersNums = str2double(cellUniqueIDsMarkers);
    
    numNotFound = 0;
    for i = 1:length(cellUniqueIDsMarkersNums)        
        if isempty(find(ismember(cellUniqueIDsMarkersNums(i), somaFileIDarray)))
            cellUniqueIDsMarkersNums(i)
            numNotFound = numNotFound + 1;
        end
    end
            
    % initialize arrays & Mij matrix
    if numNotFound > 0
        somataLoaded = 0;
        
        strng = sprintf('\n\nWarning: unable to load somata because information is missing for %d unique ID(s).\nPress any key to continue.', numNotFound);
        disp(strng)
        pause
        return
        
    else
        % loop over rows (cell types)
        for row = somata_rowSkip+1:nRows
            if strcmp(somataFile{row, somata_CellStatusColNum}, 'N')
                thisSomataUniqueID = num2str(somataFile{row,somata_UniqueIDColNum});
                %thisSomataUniqueID = [thisSomataUniqueID(1) '-' thisSomataUniqueID(2:4)];

                iCell = ismember(cellUniqueIDsMarkers, thisSomataUniqueID);

                iParcel = 0;

                % loop over columns (parcels)
                for col = somata_colSkip+1:somata_colSkip+somata_nParcels
                    iParcel = iParcel + 1;

                    if ~isnan(somataFile{row, col})
                        somataLocations(iCell,iParcel) = somataFile{row, col};
                    end
                end % for col
            end % if strcmp 'N'
        end % for row        
        
        
        somataLoaded = 1;
        
        parcelCounter = 1;
        
        DGsomataLocations = somataLocations(:,parcelCounter:parcelCounter+somata_nDGparcels-1);
        parcelCounter = parcelCounter + somata_nDGparcels;
        
        CA3somataLocations = somataLocations(:,parcelCounter:parcelCounter+somata_nCA3parcels-1);
        parcelCounter = parcelCounter + somata_nCA3parcels;
        
        CA2somataLocations = somataLocations(:,parcelCounter:parcelCounter+somata_nCA2parcels-1);
        parcelCounter = parcelCounter + somata_nCA2parcels;
        
        CA1somataLocations = somataLocations(:,parcelCounter:parcelCounter+somata_nCA1parcels-1);
        parcelCounter = parcelCounter + somata_nCA1parcels;
        
        SUBsomataLocations = somataLocations(:,parcelCounter:parcelCounter+somata_nSUBparcels-1);
        parcelCounter = parcelCounter + somata_nSUBparcels;
        
        ECsomataLocations = somataLocations(:,parcelCounter:parcelCounter+somata_nECparcels-1);

    end
    
    save 'sij.mat' somataLocations DGsomataLocations CA3somataLocations CA2somataLocations ...
        CA1somataLocations SUBsomataLocations ECsomataLocations

end % cells2sij
