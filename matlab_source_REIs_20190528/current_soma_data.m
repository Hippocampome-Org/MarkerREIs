function current_soma_data()

    % somata file info
    somata_SubregionNameRowNum = 1;
    somata_LayerNameRowNum = 2;
    somata_ParcelIDRowNum = 3;
    somata_rowSkip = 3; % rows to skip
    
    somata_colSkip = 26; % cols to skip
    somata_CellStatusColNum = 1;
    somata_UniqueIDColNum = 3;
    somata_SubregionNameColNum = 4;
    somata_AD_patternColNum = 5;
    somata_ProjectingColNum = 6;
    somata_ProjectionPatterningColNum = 7;
    somata_NameColNum = 8;
    somata_AbbreviationColNum = 9;
    somata_EorIColNum = 18;
    
    somata_nSubregions = 6;
    somata_nDGparcels = 4;
    somata_nCA3parcels = 5;
    somata_nCA2parcels = 4;
    somata_nCA1parcels = 4;
    somata_nSUBparcels = 3;
    somata_nECparcels = 6;
    somata_parcel_matrix = [somata_nDGparcels somata_nCA3parcels somata_nCA2parcels somata_nCA1parcels somata_nSUBparcels somata_nECparcels];
    somata_nParcels = sum(somata_parcel_matrix);
    
    somata_nAllCells = 122;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    save somata.mat *

