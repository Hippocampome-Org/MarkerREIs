function apply_inferences(somataLoaded, infersLoaded)    
    load markers.mat
    load mij.mat
    load markerToggles.mat
    load isIncludeMarkers.mat
    if somataLoaded
        load somata.mat
        load sij.mat
    end
    if infersLoaded
        load infers.mat
    end
    
    corrREIcolor = [0.8 0.8 0.8];
    

    fprintf(1, '\nApplying inferences...\n');

    if isInferLog
        if isIncludeUntrackedMarkers_All
            howManyMarkers = 'all';
        elseif isIncludeOnlyOfficialMarkersAndMarkersWithInfs
            howManyMarkers = '32';
        else
            howManyMarkers = '';
        end
        
        OutFileName = sprintf('./_mij_plot_output/Inference_Applications_Log_%s_%s.csv', howManyMarkers, datestr(now, 'yyyymmdd_HHMMSS'));
        fout = fopen(OutFileName,'wt');
    end
    

    MijInferApplicationsNum = cell(nAllCells,nMarkersToPrint);
    MijInferApplicationsType = cell(nAllCells,nMarkersToPrint);
    MijInferApplicationsConfirm = zeros(nAllCells,nMarkersToPrint);
    MijInferApplicationsConfirmPos = zeros(nAllCells,nMarkersToPrint);
    MijInferApplicationsConfirmPos_PMIDs = cell(nAllCells,nMarkersToPrint);
    MijInferApplicationsConfirmNeg = zeros(nAllCells,nMarkersToPrint);
    MijInferApplicationsConfirmNeg_PMIDs = cell(nAllCells,nMarkersToPrint);
    
    MijInferApplicationsPos = zeros(nAllCells,nMarkersToPrint);
    MijInferApplicationsNeg = zeros(nAllCells,nMarkersToPrint);
    tempMijInferApplicationsPos = zeros(nAllCells,nMarkersToPrint);
    tempMijInferApplicationsNeg = zeros(nAllCells,nMarkersToPrint); 
    corrProdREIMatrixPos = zeros(nAllCells,nMarkersToPrint);
    corrProdREIMatrixNeg = zeros(nAllCells,nMarkersToPrint);

    MijBigResultsMatrix = cell(nAllCells,nMarkersToPrint);

    % overall totals
    infersApplied = zeros(numInfers,1);
    numInferApplications = 0;
    
    numInferConfirmations = 0;
    numInferInferConfirmations = 0;
    
    numPosInferKnownInfoConflicts = 0;
    numPosInferKnownInfoConflicts_unique = 0;
    numNegInferKnownInfoConflicts = 0;
    numNegInferKnownInfoConflicts_unique = 0;
    numInferInferConflicts = 0;
    numInferInferConflicts_unique = 0;
    
    numInferInferConflicts_diffPasses = 0;
    
    
    numPosInferNewInfoCases = 0;
    numNegInferNewInfoCases = 0;
    
    numPosCorrProdReiCases = 0;
    numNegCorrProdReiCases = 0;

    % totals by rule type
    infersPos = 0;
    infersNeg = 0;
    
    numAxonsProjNegTotal = 0;
    numAxonsProjNegNew = 0;
    numAxonsProjNegConflict = 0;
    numAxonsProjNegConflictInf = 0;
    numAxonsProjNegConfirm = 0;
    numAxonsProjNegConfirmInf = 0;
    
    numLayerNegTotal = 0;
    numLayerNegNew = 0;
    numLayerNegConflict = 0;
    numLayerNegConflictInf = 0;
    numLayerNegConfirm = 0;
    numLayerNegConfirmInf = 0;
    
    numPosNegTotal = 0;
    numPosNegNew = 0;
    numPosNegConflict = 0;
    numPosNegConflictInf = 0;
    numPosNegConfirm = 0;
    numPosNegConfirmInf = 0;
    
    numPosPosTotal = 0;
    numPosPosNew = 0;
    numPosPosConflict = 0;
    numPosPosConflictInf = 0;
    numPosPosConfirm = 0;
    numPosPosConfirmInf = 0;
    
    numContra_PosNegTotal = 0;
    numContra_PosNegNew = 0;
    numContra_PosNegConflict = 0;
    numContra_PosNegConflictInf = 0;
    numContra_PosNegConfirm = 0;
    numContra_PosNegConfirmInf = 0;
    
    numContra_PosPosTotal = 0;
    numContra_PosPosNew = 0;
    numContra_PosPosConflict = 0;
    numContra_PosPosConflictInf = 0;
    numContra_PosPosConfirm = 0;
    numContra_PosPosConfirmInf = 0;
        
    infResults = zeros(maxInferNum,6);
    
    conflictList = cell(1,3);
    conflictList{1,1} = {'Neuron type'};
    conflictList{1,2} = {'Marker'};
    conflictList{1,3} = {'Conflict type'};
    
    
    %% prepass to determine if threshold met %%
    
    fprintf(1, 'Pre-pass a...\n');
    for r_pre1=1:numInfers
        if strcmp(confidMetric, 'Binomial dist')
            thisConfid = infers_binConfid{r_pre1};
        elseif strcmp(confidMetric, 'Clopper-Pearson')
            thisConfid = infers_ClopPearConfid{r_pre1};
        end

        if (infers_percentTrue(r_pre1) == 100)
            % thresholdMet
            
        else          
            if ischar(infers_n{r_pre1})
                if strcmpi(infers_n{r_pre1}, 'okay') && isUseOkayInfs
                    
                    if isnan(infers_percentTrue(r_pre1)) % if percent times true is not given (and n is okay)
                        % thresholdMet
                        
                    else % if percent times true is given (and n is okay)
                        if strcmp(infers_inferType(r_pre1), 'Layer-neg') && infers_percentTrue(r_pre1) < 100
                            infers_dontuse{r_pre1} = 'below thresh';
                        elseif infers_percentTrue(r_pre1) < 90
                            infers_dontuse{r_pre1} = 'below thresh';
                        else
                            % thresholdMet
                        end
                    end
                else
                    infers_dontuse{r_pre1} = 'below thresh';
                end
            elseif (thisConfid >= str2double(threshValuePct))
                % thresholdMet
            else
                infers_dontuse{r_pre1} = 'below thresh';
            end
        end
    end
    
    
    %% prepass to combine above-thresh inferences if markers are the same %%
    
    fprintf(1, 'Pre-pass b...\n');
    for r_pre2_a=1:numInfers
        if isnan(infers_dontuse{r_pre2_a})
            
            for r_pre2_b=r_pre2_a+1:numInfers
                if isnan(infers_dontuse{r_pre2_b})
                    
                    if (strcmpi(infers_priNeurotrans{r_pre2_a}, 'ALL') && strcmpi(infers_priNeurotrans{r_pre2_b}, 'ALL') || ...
                        strcmpi(infers_priNeurotrans{r_pre2_a}, 'GLUT') && strcmpi(infers_priNeurotrans{r_pre2_b}, 'GLUT') || ...
                        strcmpi(infers_priNeurotrans{r_pre2_a}, 'GABA') && strcmpi(infers_priNeurotrans{r_pre2_b}, 'GABA'))
                    
                        changeScopeA = 1;
                        changeScopeB = 1;
                    
                    elseif (strcmpi(infers_priNeurotrans{r_pre2_a}, 'ALL') && strcmpi(infers_priNeurotrans{r_pre2_b}, 'GLUT') || ...
                        strcmpi(infers_priNeurotrans{r_pre2_a}, 'ALL') && strcmpi(infers_priNeurotrans{r_pre2_b}, 'GABA'))
                    
                        changeScopeA = 1;
                        changeScopeB = 0;
                        
                    elseif (strcmpi(infers_priNeurotrans{r_pre2_a}, 'GLUT') && strcmpi(infers_priNeurotrans{r_pre2_b}, 'ALL') || ...
                        strcmpi(infers_priNeurotrans{r_pre2_a}, 'GABA') && strcmpi(infers_priNeurotrans{r_pre2_b}, 'ALL'))
                    
                        changeScopeA = 0;
                        changeScopeB = 1;
                        
                    else
                        changeScopeA = 0;
                        changeScopeB = 0;
                    end
                    
                        
                    % for rule types with a single marker
                    if (strcmp(infers_inferType(r_pre2_a),'Axons-proj-neg') && strcmp(infers_inferType(r_pre2_b),'Axons-proj-neg')) || ...
                    (strcmp(infers_inferType(r_pre2_a),'Layer-neg') && strcmp(infers_inferType(r_pre2_b),'Layer-neg'))
                        
                        % if marker1 same
                        if strcmpi(char(deblank(infers_marker1(r_pre2_a))),char(deblank(infers_marker1(r_pre2_b))))                            
                            combinedApplicationScope = inferApplicationScope(r_pre2_a,:) | inferApplicationScope(r_pre2_b,:);
                            
                            if changeScopeA
                                inferApplicationScope(r_pre2_a,:) = combinedApplicationScope;
                            end
                            if changeScopeB
                                inferApplicationScope(r_pre2_b,:) = combinedApplicationScope;
                            end
                        end
                            
                    % for rule types with 2 markers
                    elseif strcmp(infers_inferType(r_pre2_a), infers_inferType(r_pre2_b))
                        
                        % if marker1 and marker2 same
                        if strcmpi(char(deblank(infers_marker1(r_pre2_a))),char(deblank(infers_marker1(r_pre2_b)))) && ...
                        strcmpi(char(deblank(infers_marker2(r_pre2_a))),char(deblank(infers_marker2(r_pre2_b))))
                            combinedApplicationScope = inferApplicationScope(r_pre2_a,:) | inferApplicationScope(r_pre2_b,:);
                            
                            if changeScopeA
                                inferApplicationScope(r_pre2_a,:) = combinedApplicationScope;
                            end
                            if changeScopeB
                                inferApplicationScope(r_pre2_b,:) = combinedApplicationScope;
                            end
                        end
                        
                    end
                end
            end
        end
    end
    

    %% prepare log file
    
    if isInferLog
        fprintf(fout, 'PASS,NUMBER,INF. TYPE,NEURON TYPE APPLIED TO,TYPE ID,INFERRED MARKER,FLAG DIR,REASON,PART OF CHAIN,NOVELTY,REF ID\n');
    end
    
    infApplicationMatrix = cell(1,5);
    nextRow = 1;
    
    pass = 1;


    %% begin passing through inferences; if a new inference was applied in a previous pass, take another pass to see if the matrix changes with this new info
    
    while pass==1 || (isChainInfs && ...
    (any(tempMijInferApplicationsPos(:)) || any(tempMijInferApplicationsNeg(:))) )

        if isInferLog
            fprintf(fout, '****************** PASS %d ******************\n', pass);            
        end
        MijInferApplicationsPos = MijInferApplicationsPos | tempMijInferApplicationsPos;
        MijInferApplicationsNeg = MijInferApplicationsNeg | tempMijInferApplicationsNeg;
        tempMijInferApplicationsPos = zeros(nAllCells,nMarkersToPrint);
        tempMijInferApplicationsNeg = zeros(nAllCells,nMarkersToPrint);
        
        %% loop through inferences
        
        numelMsg = 0;
        for r = 1:numInfers
            if isnan(infers_dontuse{r})
            
                msg = sprintf('[Pass %d] Processing inference %d of %d...\n', pass, r, numInfers);
                fprintf(repmat('\b',1,numelMsg));                
                fprintf(msg);
                numelMsg=numel(msg);

                thisInferNum = infers_inferNum(r);                

                cellInferSubreg = deblank(char(infers_subreg{r}));
                cellInferLayers = deblank(char(infers_layers{r}));
                cellInferExceptions = infers_exceptions{r};

                semiPos = strfind(infers_refIDs{r},';');
                if isempty(semiPos)
                    cellInferRefID = infers_refIDs{r};
                else
                    cellInferRefID = infers_refIDs{r}(1:semiPos-1);
                end
                
                cellInferPMID = infers_PMIDs{r};

                if strcmp(infers_inferType(r),'Axons-proj-neg')
                    isInferMorphBased = 1;              
                else
                    isInferMorphBased = 0;
                end


                %% loop through cell types and try to apply inference to each

                for c = 1:nAllCells
                    
                    % ensure all somata locations are within scope of the combined inferences AND 
                    % at least one soma location is in the original inference
                    if (isequal(inferApplicationScope(r,:) & somataLocations(c,:), somataLocations(c,:))) && ...
                    any(inferApplicationLayers(r,:) & somataLocations(c,:))                        
                
                        cellSubregion = deblank(char(cellSubregionsMarkers{c}));
                        cellPlusOrMinus = deblank(char(MijPlusOrMinus{c}));
                        cellADpattern = deblank(MijAD_pattern{c});
                        if ~isnan(MijProjecting{c})
                            cellProjecting = deblank(MijProjecting{c});
                        else
                            cellProjecting = '';
                        end        
                        cellLabel = deblank(cellLabelsMarkers{c});
                        cellID = deblank(cellUniqueIDsMarkers{c});


                        newOrConflictInfo = 'not applied';

                        if isInferMorphBased

                            %% Axons-proj-neg                            
                                
                            if strcmp(infers_inferType(r),'Axons-proj-neg') && ...                                
                            ~isnan(MijProjecting{c}) && ...
                            (strcmpi(infers_priNeurotrans(r), 'ALL') || ...
                                (strcmpi(infers_priNeurotrans(r), 'GABA') && strcmp(MijPlusOrMinus(c),'(-)')) || ...
                                (strcmpi(infers_priNeurotrans(r), 'GLUT') && strcmp(MijPlusOrMinus(c),'(+)')))

                                for m0 = nMarkersToPrint:-1:1
                                    % loop through and find inference marker 1;
                                    % ensure a this rule wasn't applied (on a
                                    % previous pass)

                                    if strcmpi(char(deblank(infers_marker1(r))), char(deblank(markerLabels(m0)))) ...
                                    && sum(MijInferApplicationsNum{c,m0}==infers_inferNum(r)) == 0

                                        thisNumLevels = MijNumLevels(c,m0);

                                        if(thisNumLevels < 2)
                                            mixedData = 0;
                                            thisCellContains = MijLevels{c,m0};

                                            if isNoMixedAtK_1Pass
                                                if (sum(find(thisCellContains==2))>0 && MijInferApplicationsPos(c,m0)) || ...
                                                ((sum(find(thisCellContains==1))>0 || sum(find(thisCellContains==3))>0) && MijInferApplicationsNeg(c,m0)) || ...
                                                (MijInferApplicationsPos(c,m0) && MijInferApplicationsNeg(c,m0))
                                                    mixedData = 1;
                                                end
                                            end
                                        else
                                            mixedData = 1;
                                        end %if (thisNumLevels == 1)

                                        if ~mixedData
                                            % if matrix is already negative, this inf confirms
                                            if sum(find(thisCellContains==2))>0
                                                if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                    numAxonsProjNegConfirm = numAxonsProjNegConfirm + 1;
                                                    numInferConfirmations = numInferConfirmations + 1;
                                                    newOrConflictInfo = 'confirm DE';
                                                    infResults(thisInferNum,4) = infResults(thisInferNum,4) + 1;

                                                    MijInferApplicationsConfirm(c,m0) = 1;
                                                    MijInferApplicationsConfirmNeg(c,m0) = 1;

                                                    newCorrProdREI = 0;
                                                    fillWedge = 1;
                                                    addToLog = 1;
                                                else
                                                    fillWedge = 0;
                                                    addToLog = 1;
                                                end

                                            % new negative wedge
                                            else
                                                fillColor = 'k';
                                                
                                                % conflict with matrix
                                                if sum(find(thisCellContains==1))>0 || sum(find(thisCellContains==3))>0
                                                    
                                                    if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                        numAxonsProjNegConflict = numAxonsProjNegConflict + 1;
                                                        numNegInferKnownInfoConflicts = numNegInferKnownInfoConflicts + 1;
                                                        if isempty(MijBigResultsMatrix{c,m0})
                                                            numNegInferKnownInfoConflicts_unique = numNegInferKnownInfoConflicts_unique + 1;
                                                        end
                                                        newOrConflictInfo = 'conflict with DE';
                                                        infResults(thisInferNum,2) = infResults(thisInferNum,2) + 1;

                                                        MijBigResultsMatrix{c,m0} = 1.5;  % green & black
                                                        conflictNum = size(conflictList,1);
                                                        conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                        conflictList{conflictNum+1,2} = char(deblank(infers_marker1(r)));
                                                        conflictList{conflictNum+1,3} = 'DE';

                                                        newCorrProdREI = 0;
                                                        if isOverrideMixedLaterPass
                                                            fillWedge = 0;
                                                        else
                                                            fillWedge = 1;
                                                        end
                                                        addToLog = 1;
                                                    else
                                                        fillWedge = 0;
                                                        addToLog = 1;
                                                    end

                                                % confirm another inf
                                                elseif MijInferApplicationsNeg(c,m0)==1 || tempMijInferApplicationsNeg(c,m0)==1
                                                    if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                        numAxonsProjNegConfirmInf = numAxonsProjNegConfirmInf + 1;
                                                        numInferInferConfirmations = numInferInferConfirmations + 1;
                                                        if MijInferApplicationsNeg(c,m0)==1
                                                            newOrConflictInfo = 'confirm inf (prev pass)';
                                                        elseif tempMijInferApplicationsNeg(c,m0)==1
                                                            newOrConflictInfo = 'confirm inf (this pass)';
                                                        end
                                                        infResults(thisInferNum,5) = infResults(thisInferNum,5) + 1;

                                                        MijInferApplicationsConfirm(c,m0) = 1;
                                                        MijInferApplicationsConfirmNeg(c,m0) = 1;
                                                        MijInferApplicationsConfirmNeg_PMIDs{c,m0} = [MijInferApplicationsConfirmNeg_PMIDs{c,m0} ';' cellInferPMID];

                                                        newCorrProdREI = 0;
                                                        fillWedge = 1;
                                                        addToLog = 1;
                                                    else
                                                        fillWedge = 0;
                                                        addToLog = 1;
                                                    end

                                                % conflict with another inf from prev pass
                                                elseif MijInferApplicationsPos(c,m0)==1   
                                                    if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                        if isOverrideMixedLaterPass
                                                            newCorrProdREI = 0;
                                                            fillWedge = 0;
                                                            addToLog = 0;
                                                        else
                                                            newCorrProdREI = 0;
                                                            fillWedge = 1;
                                                            addToLog = 1;

                                                            numAxonsProjNegConflictInf = numAxonsProjNegConflictInf + 1;
                                                            numInferInferConflicts_diffPasses = numInferInferConflicts_diffPasses + 2;

                                                            if MijBigResultsMatrix{c,m0} ~= 0
                                                                numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                            end

                                                            [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m0}, ...
                                                                numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                            thisConflictNum = MijInferApplicationsNum{c,m0};
                                                            thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                            thisConflictType = infers_inferType{thisConflictPos(1)};

                                                            [numAxonsProjNegNew, numLayerNegNew, ...
                                                                numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                            newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (prev pass)'];

                                                            infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                            MijBigResultsMatrix{c,m0} = 0;
                                                        end
                                                    else
                                                        fillWedge = 0;
                                                        addToLog = 1;
                                                    end
                                                    
                                                % conflict with another inf from this pass
                                                elseif tempMijInferApplicationsPos(c,m0)==1
                                                    if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                        numAxonsProjNegConflictInf = numAxonsProjNegConflictInf + 1;
                                                        numInferInferConflicts = numInferInferConflicts + 2;
                                                        if MijBigResultsMatrix{c,m0} ~= 0
                                                            numInferInferConflicts_unique = numInferInferConflicts_unique + 1;
                                                            numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                        end

                                                        [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                            numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                            numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m0}, ...
                                                            numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                            numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                        thisConflictNum = MijInferApplicationsNum{c,m0};
                                                        thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                        thisConflictType = infers_inferType{thisConflictPos(1)};

                                                        [numAxonsProjNegNew, numLayerNegNew, ...
                                                            numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                            numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                            numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                            numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                        newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (this pass)'];

                                                        infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                        MijBigResultsMatrix{c,m0} = 0;

                                                        conflictNum = size(conflictList,1);
                                                        conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                        conflictList{conflictNum+1,2} = char(deblank(infers_marker1(r)));
                                                        conflictList{conflictNum+1,3} = 'INF';

                                                        newCorrProdREI = 0;
                                                        fillWedge = 1;
                                                        addToLog = 1;
                                                    else
                                                        fillWedge = 0;
                                                        addToLog = 1;
                                                    end                                                                                                    

                                                % new info to this pass
                                                else
                                                    newOrConflictInfo = 'new this pass';
                                                    infResults(thisInferNum,1) = infResults(thisInferNum,1) + 1;

                                                    MijBigResultsMatrix{c,m0} = -1;
                                                    MijInferApplicationsConfirmNeg_PMIDs{c,m0} = cellInferPMID;
                                                                                                                                                            
                                                    if isColorCorrProdREIDifferently && (thisInferNum >= firstCorrProdREInum)
                                                        fillColor = corrREIcolor;
                                                        if corrProdREIMatrixNeg(c,m0)==0                                                            
                                                            numNegCorrProdReiCases = numNegCorrProdReiCases + 1;
                                                            newCorrProdREI = 1;
                                                        else
                                                            newCorrProdREI = 0;
                                                        end
                                                    else
                                                        numAxonsProjNegNew = numAxonsProjNegNew + 1;
                                                        numNegInferNewInfoCases = numNegInferNewInfoCases + 1;
                                                        newCorrProdREI = 0;
                                                    end
                                                    
                                                    fillWedge = 1;
                                                    addToLog = 1;
                                                end

                                                % fill in new or conflicting wedge
                                                if isIncludeAxonInfers && ((~isAllowInfOnSubtypes && fillWedge) || isAllowInfOnSubtypes)                                                    
                                                    fill([m0+1 m0+1 m0+0.5], [c c+1 c+0.5], fillColor);
                                                end
                                            end

                                            
                                            % an inference was applied
                                            if (thisInferNum < firstCorrProdREInum) || newCorrProdREI
                                                % update counters
                                                if ~newCorrProdREI
                                                    numInferApplications = numInferApplications + 1;
                                                    infersNeg = infersNeg + 1;
                                                    numAxonsProjNegTotal = numAxonsProjNegTotal + 1;
                                                    
                                                    tempMijInferApplicationsNeg(c,m0) = 1;
                                                else
                                                    corrProdREIMatrixNeg(c,m0) = 1;
                                                end

                                                infersApplied(r) = 1;

                                                if isempty(MijInferApplicationsNum{c,m0})
                                                    MijInferApplicationsNum{c,m0} = infers_inferNum(r);
                                                else
                                                    MijInferApplicationsNum{c,m0} = [MijInferApplicationsNum{c,m0} infers_inferNum(r)];
                                                end
                                                MijInferApplicationsType(c,m0) = infers_inferType(r);                                                

                                                primaryNTtext = lower(infers_priNeurotrans{r});
                                                primaryNTtext = strrep(primaryNTtext, 'glut', 'Glutamatergic');
                                                primaryNTtext = strrep(primaryNTtext, 'gaba', 'GABAergic');

                                                if ~newCorrProdREI
                                                    infTypeCode = negInfCode;
                                                    reasonText = [primaryNTtext ' types with projecting axons are known to be ' char(deblank(infers_marker1(r))) ' negative'];
                                                else
                                                    infTypeCode = negCorProdREI_negInf_Code;
                                                    reasonText = [primaryNTtext ' types with projecting axons are known to be ' char(deblank(infers_marker1(r))) ' negative -- by an inter-matrix data correlation analysis utilizing Barnard''s exact test (see help)'];
                                                end
                                                    

                                                % add to log
                                                if isInferLog && addToLog                                                
                                                    fprintf(fout, '%d,infer %d,%s,%s %s%s%s %s,%s,%s,negative,%s,,%s,%s\n', ...
                                                        pass, thisInferNum, infers_inferType{r}, cellSubregion, cellPlusOrMinus, cellADpattern, cellProjecting, cellLabel, cellID, ...
                                                        char(deblank(infers_marker1(r))), reasonText, newOrConflictInfo, cellInferRefID);
                                                end

                                                % add to spreadsheet
                                                if isOutputHybridSheet && addToLog
                                                    infApplicationMatrix(nextRow,1:5) = {c m0 thisInferNum infTypeCode reasonText};
                                                    nextRow = nextRow + 1;
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                        else % infer is not morph based
                        
                            if strcmpi(infers_priNeurotrans(r), 'ALL') || ...
                                (strcmpi(infers_priNeurotrans(r), 'GABA') && strcmp(MijPlusOrMinus(c),'(-)')) || ...
                                (strcmpi(infers_priNeurotrans(r), 'GLUT') && strcmp(MijPlusOrMinus(c),'(+)'))

                                    for m1 = nMarkersToPrint:-1:1
                                        % loop through and find inference marker 1;
                                        % ensure a this rule wasn't applied (on a
                                        % previous pass)

                                        subtypesTrigger = 0;
                                        if strcmpi(char(deblank(infers_marker1(r))), char(deblank(markerLabels(m1))))                                        
                                            thisNumLevels = MijNumLevels(c,m1);                                            

                                            if(thisNumLevels < 2)
                                                thisCellContains = MijLevels{c,m1};
                                                mixedData = 0;
                                                
                                                if isNoMixedAtK_1Pass
                                                    if (sum(find(thisCellContains==2))>0 && MijInferApplicationsPos(c,m1)) || ...
                                                    ((sum(find(thisCellContains==1))>0 || sum(find(thisCellContains==3))>0) && MijInferApplicationsNeg(c,m1)) || ...
                                                    (MijInferApplicationsPos(c,m1) && MijInferApplicationsNeg(c,m1))
                                                        mixedData = 1;
                                                    end
                                                end
                                            elseif MijMixedFlagCodes(c,m1)==1 && isAllowInfOnSubtypes
                                                mixedData = 1;
                                                subtypesTrigger = 1;
                                            else
                                                thisCellContains = 0;
                                                mixedData = 1;
                                            end %if (thisNumLevels == 1)

                                            
                                            %% Layer-neg %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            if ~mixedData && strcmp(infers_inferType(r),'Layer-neg') ...
                                            && sum(MijInferApplicationsNum{c,m1}==infers_inferNum(r)) == 0

                                                % if matrix is already negative, this inf confirms
                                                if sum(find(thisCellContains==2))>0
                                                    if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                        numLayerNegConfirm = numLayerNegConfirm + 1;
                                                        numInferConfirmations = numInferConfirmations + 1;
                                                        newOrConflictInfo = 'confirm DE';
                                                        infResults(thisInferNum,4) = infResults(thisInferNum,4) + 1;

                                                        MijInferApplicationsConfirm(c,m1) = 1;
                                                        MijInferApplicationsConfirmNeg(c,m1) = 1;

                                                        newCorrProdREI = 0;
                                                        fillWedge = 1;
                                                        addToLog = 1;
                                                    else
                                                        fillWedge = 0;
                                                        addToLog = 1;
                                                    end

                                                % new negative wedge
                                                else
                                                    fillColor = 'k';
                                                    
                                                    % conflict with matrix
                                                    if sum(find(thisCellContains==1))>0 || sum(find(thisCellContains==3))>0
                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                            numLayerNegConflict = numLayerNegConflict + 1;
                                                            numNegInferKnownInfoConflicts = numNegInferKnownInfoConflicts + 1;
                                                            if isempty(MijBigResultsMatrix{c,m1})
                                                                numNegInferKnownInfoConflicts_unique = numNegInferKnownInfoConflicts_unique + 1;
                                                            end
                                                            newOrConflictInfo = 'conflict with DE';
                                                            infResults(thisInferNum,2) = infResults(thisInferNum,2) + 1;

                                                            MijBigResultsMatrix{c,m1} = 1.5;  % green & black

                                                            conflictNum = size(conflictList,1);
                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker1(r)));
                                                            conflictList{conflictNum+1,3} = 'DE';

                                                            newCorrProdREI = 0;
                                                            if isOverrideMixedLaterPass
                                                                fillWedge = 0;
                                                            else
                                                                fillWedge = 1;
                                                            end
                                                            addToLog = 1;
                                                        else
                                                            fillWedge = 0;
                                                            addToLog = 1;
                                                        end

                                                    % confirm another inf
                                                    elseif MijInferApplicationsNeg(c,m1)==1 || tempMijInferApplicationsNeg(c,m1)==1
                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                            numLayerNegConfirmInf = numLayerNegConfirmInf + 1;
                                                            numInferInferConfirmations = numInferInferConfirmations + 1;
                                                            if MijInferApplicationsNeg(c,m1)==1
                                                                newOrConflictInfo = 'confirm inf (prev pass)';
                                                            elseif tempMijInferApplicationsNeg(c,m1)==1
                                                                newOrConflictInfo = 'confirm inf (this pass)';
                                                            end
                                                            infResults(thisInferNum,5) = infResults(thisInferNum,5) + 1;

                                                            MijInferApplicationsConfirm(c,m1) = 1;
                                                            MijInferApplicationsConfirmNeg(c,m1) = 1;
                                                            MijInferApplicationsConfirmNeg_PMIDs{c,m1} = [MijInferApplicationsConfirmNeg_PMIDs{c,m1} ';' cellInferPMID];

                                                            newCorrProdREI = 0;
                                                            fillWedge = 1;
                                                            addToLog = 1;
                                                        else
                                                            fillWedge = 0;
                                                            addToLog = 1;
                                                        end

                                                    % conflict with another inf from prev pass
                                                    elseif MijInferApplicationsPos(c,m1)==1  
                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                            if isOverrideMixedLaterPass
                                                                newCorrProdREI = 0;
                                                                fillWedge = 0;
                                                                addToLog = 0;
                                                            else
                                                                newCorrProdREI = 0;
                                                                fillWedge = 1;
                                                                addToLog = 1;

                                                                numLayerNegConflictInf = numLayerNegConflictInf + 1;
                                                                numInferInferConflicts_diffPasses = numInferInferConflicts_diffPasses + 2;

                                                                if MijBigResultsMatrix{c,m1} ~= 0
                                                                    numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                                end

                                                                [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                    numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                    numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m1}, ...
                                                                    numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                    numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                                thisConflictNum = MijInferApplicationsNum{c,m1};
                                                                thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                [numAxonsProjNegNew, numLayerNegNew, ...
                                                                    numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                    numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                    numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                    numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (prev pass)'];

                                                                infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                MijBigResultsMatrix{c,m1} = 0;
                                                            end
                                                        else                                                            
                                                            fillWedge = 0;
                                                            addToLog = 1;
                                                        end
                                                     
                                                    % conflict with another inf from this pass
                                                    elseif tempMijInferApplicationsPos(c,m1)==1
                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                            numLayerNegConflictInf = numLayerNegConflictInf + 1;
                                                            numInferInferConflicts = numInferInferConflicts + 2;
                                                            if MijBigResultsMatrix{c,m1} ~= 0
                                                                numInferInferConflicts_unique = numInferInferConflicts_unique + 1;
                                                                numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                            end                                                    

                                                            [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m1}, ...
                                                                numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                            thisConflictNum = MijInferApplicationsNum{c,m1};
                                                            thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                            thisConflictType = infers_inferType{thisConflictPos(1)};

                                                            [numAxonsProjNegNew, numLayerNegNew, ...
                                                                numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                            newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (this pass)'];

                                                            infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                            MijBigResultsMatrix{c,m1} = 0;

                                                            conflictNum = size(conflictList,1);
                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker1(r)));
                                                            conflictList{conflictNum+1,3} = 'INF';

                                                            newCorrProdREI = 0;
                                                            fillWedge = 1;
                                                            addToLog = 1;
                                                        else
                                                            fillWedge = 0;
                                                            addToLog = 1;
                                                        end

                                                    % new info to this pass
                                                    else
                                                        newOrConflictInfo = 'new this pass';
                                                        infResults(thisInferNum,1) = infResults(thisInferNum,1) + 1;

                                                        MijBigResultsMatrix{c,m1} = -1;
                                                        MijInferApplicationsConfirmNeg_PMIDs{c,m1} = cellInferPMID;
                                                        
                                                        if isColorCorrProdREIDifferently && (thisInferNum >= firstCorrProdREInum)
                                                            fillColor = corrREIcolor;
                                                            if corrProdREIMatrixNeg(c,m1)==0                                                                
                                                                numNegCorrProdReiCases = numNegCorrProdReiCases + 1;
                                                                newCorrProdREI = 1;
                                                            else
                                                                newCorrProdREI = 0;
                                                            end
                                                        else
                                                            numLayerNegNew = numLayerNegNew + 1;
                                                            numNegInferNewInfoCases = numNegInferNewInfoCases + 1;
                                                            newCorrProdREI = 0;
                                                        end
                                                        
                                                        fillWedge = 1;
                                                        addToLog = 1;
                                                    end

                                                    if isIncludeLayerInfers && ((~isAllowInfOnSubtypes && fillWedge) || isAllowInfOnSubtypes)
                                                        fill([m1+1 m1+1 m1+0.5], [c c+1 c+0.5], fillColor);
                                                    end
                                                end

                                                % an inference was applied
                                                if (thisInferNum < firstCorrProdREInum) || newCorrProdREI
                                                    % update counters
                                                    if ~newCorrProdREI
                                                        numInferApplications = numInferApplications + 1;
                                                        infersNeg = infersNeg + 1;
                                                        numLayerNegTotal = numLayerNegTotal + 1;
                                                        
                                                        tempMijInferApplicationsNeg(c,m1) = 1;
                                                    else
                                                        corrProdREIMatrixNeg(c,m1) = 1;
                                                    end

                                                    infersApplied(r) = 1;

                                                    if isempty(MijInferApplicationsNum{c,m1})
                                                        MijInferApplicationsNum{c,m1} = infers_inferNum(r);
                                                    else
                                                        MijInferApplicationsNum{c,m1} = [MijInferApplicationsNum{c,m1} infers_inferNum(r)];
                                                    end
                                                    MijInferApplicationsType(c,m1) = infers_inferType(r);                                                    

                                                    primaryNTtext = lower(infers_priNeurotrans{r});
                                                    primaryNTtext = strrep(primaryNTtext, 'all', 'Glutamatergic and GABAergic');
                                                    primaryNTtext = strrep(primaryNTtext, 'glut', 'Glutamatergic');
                                                    primaryNTtext = strrep(primaryNTtext, 'gaba', 'GABAergic');
                                                    cellInferSubregText = cellInferSubreg;
                                                    cellInferSubregText = strrep(cellInferSubregText, ',', ' &');

                                                    if ~newCorrProdREI
                                                        infTypeCode = negInfCode;
                                                        reasonText = [primaryNTtext ' types in ' cellInferSubregText ' ' cellInferLayers ' are negative for ' char(deblank(infers_marker1(r)))];
                                                    else
                                                        infTypeCode = negCorProdREI_negInf_Code;
                                                        reasonText = [primaryNTtext ' types in ' cellInferSubregText ' ' cellInferLayers ' are negative for ' char(deblank(infers_marker1(r))) ' -- by an inter-matrix data correlation analysis utilizing Barnard''s exact test (see help)'];
                                                    end

                                                    if isInferLog && addToLog
                                                        fprintf(fout, '%d,infer %d,%s,%s %s%s%s %s,%s,%s,negative,%s,,%s,%s\n', ...
                                                            pass, thisInferNum, infers_inferType{r}, cellSubregion, cellPlusOrMinus, cellADpattern, cellProjecting, cellLabel, cellID, ...
                                                            char(deblank(infers_marker1(r))), reasonText, newOrConflictInfo, cellInferRefID);
                                                    end

                                                    if isOutputHybridSheet && addToLog
                                                        infApplicationMatrix(nextRow,1:5) = {c m1 thisInferNum infTypeCode reasonText};
                                                        nextRow = nextRow + 1;
                                                    end
                                                end



                                            % if not a layer-neg inf, look at marker 2
                                            elseif (~mixedData || subtypesTrigger) && isempty(strfind(infers_inferType{r},'Layer-neg'))                                                    
                                                for m2 = nMarkersToPrint:-1:1
                                                    thisNumLevelsNewMarker = MijNumLevels(c,m2);

                                                    if(thisNumLevelsNewMarker < 2)
                                                        thisCellContainsNewMarker = MijLevels{c,m2};
                                                        mixedDataNewMarker = 0;

                                                        % commented out below in order to stop infs from being applied
                                                        % to squares that already have DE-DE conflicts but allow them 
                                                        % to be applied to squares that already have DE-INF or INF-INF
                                                        % conflicts (to gather additional conflicting or confirmatory evidence)
                                                        
%                                                         if isNoMixedAtK_1Pass
%                                                             if (sum(find(thisCellContainsNewMarker==2))>0 && MijInferApplicationsPos(c,m2)) || ...
%                                                             ((sum(find(thisCellContainsNewMarker==1))>0 || sum(find(thisCellContainsNewMarker==3))>0) && MijInferApplicationsNeg(c,m2)) || ...
%                                                             (MijInferApplicationsPos(c,m2) && MijInferApplicationsNeg(c,m2))
%                                                                 mixedDataNewMarker = 1;
%                                                             end
%                                                         end
                                                    else
                                                        thisCellContainsNewMarker = 0;
                                                        mixedDataNewMarker = 1;
                                                    end %if (thisNumLevels == 1)                                                    

                                                    if ~mixedDataNewMarker ...
                                                    && strcmpi(char(deblank(infers_marker2(r))), char(deblank(markerLabels(m2)))) ...
                                                    && sum(MijInferApplicationsNum{c,m2}==infers_inferNum(r)) == 0                                                

                                                        %% Pos-neg                                                            
                                                        if strcmpi(infers_inferType(r),'Pos-neg') ...
                                                        && ( sum(find(thisCellContains==1))>0 || sum(find(thisCellContains==3))>0 || ...
                                                        (MijInferApplicationsPos(c,m1)==1 && isChainInfs) )

                                                            % determine if info is part of a chain of infs
                                                            if sum(find(thisCellContains==1))==0 && sum(find(thisCellContains==3))==0
                                                                chainInfo = 'yes';
                                                            else
                                                                chainInfo = '';
                                                            end

                                                            % if matrix is already negative, this inf confirms
                                                            if sum(find(thisCellContainsNewMarker==2))
                                                                exception = 0;
                                                                
                                                                if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI                                                                    
                                                                    numPosNegConfirm = numPosNegConfirm + 1;
                                                                    numInferConfirmations = numInferConfirmations + 1;
                                                                    newOrConflictInfo = 'confirm DE';
                                                                    infResults(thisInferNum,4) = infResults(thisInferNum,4) + 1;

                                                                    MijInferApplicationsConfirm(c,m2) = 1;
                                                                    MijInferApplicationsConfirmNeg(c,m2) = 1;

                                                                    newCorrProdREI = 0;
                                                                    fillWedge = 1;
                                                                    addToLog = 1;
                                                                else
                                                                    fillWedge = 0;
                                                                    addToLog = 1;
                                                                end

                                                            % new negative wedge
                                                            else
                                                                exception = 0;
                                                                fillColor = 'k';
                                                                
                                                                if isnan(cellInferExceptions) % cells2infers set to temporarily ignore all exceptions
                                                                    % conflict with matrix
                                                                    if sum(find(thisCellContainsNewMarker==1))>0 || sum(find(thisCellContainsNewMarker==3))>0
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numPosNegConflict = numPosNegConflict + 1;
                                                                            numNegInferKnownInfoConflicts = numNegInferKnownInfoConflicts + 1;
                                                                            if isempty(MijBigResultsMatrix{c,m2})
                                                                                numNegInferKnownInfoConflicts_unique = numNegInferKnownInfoConflicts_unique + 1;
                                                                            end
                                                                            newOrConflictInfo = 'conflict with DE';
                                                                            infResults(thisInferNum,2) = infResults(thisInferNum,2) + 1;

                                                                            MijBigResultsMatrix{c,m2} = 1.5;  % green & black

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'DE';

                                                                            newCorrProdREI = 0;
                                                                            if isOverrideMixedLaterPass
                                                                                fillWedge = 0;
                                                                            else
                                                                                fillWedge = 1;
                                                                            end
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % confirm another inf
                                                                    elseif MijInferApplicationsNeg(c,m2)==1 || tempMijInferApplicationsNeg(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numPosNegConfirmInf = numPosNegConfirmInf + 1;
                                                                            numInferInferConfirmations = numInferInferConfirmations + 1;
                                                                            if MijInferApplicationsNeg(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (prev pass)';
                                                                            elseif tempMijInferApplicationsNeg(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (this pass)';
                                                                            end
                                                                            infResults(thisInferNum,5) = infResults(thisInferNum,5) + 1;

                                                                            MijInferApplicationsConfirm(c,m2) = 1;
                                                                            MijInferApplicationsConfirmNeg(c,m2) = 1;
                                                                            MijInferApplicationsConfirmNeg_PMIDs{c,m2} = [MijInferApplicationsConfirmNeg_PMIDs{c,m2} ';' cellInferPMID];

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % conflict with another inf from prev pass
                                                                    elseif MijInferApplicationsPos(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            if isOverrideMixedLaterPass
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 0;
                                                                                addToLog = 0;
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 1;
                                                                                addToLog = 1;

                                                                                numPosNegConflictInf = numPosNegConflictInf + 1;
                                                                                numInferInferConflicts_diffPasses = numInferInferConflicts_diffPasses + 2;

                                                                                if MijBigResultsMatrix{c,m2} ~= 0
                                                                                    numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                                                end                                                                    

                                                                                [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                    numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                    numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                    numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                    numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);                                                                                                                                                                                                           

                                                                                thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                                thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                                thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                                [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                    numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                    numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                    numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                    numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                                newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (prev pass)'];

                                                                                infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                                MijBigResultsMatrix{c,m2} = 0;
                                                                            end
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end
                                                                        
                                                                    % conflict with another inf from this pass
                                                                    elseif tempMijInferApplicationsPos(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numPosNegConflictInf = numPosNegConflictInf + 1;
                                                                            numInferInferConflicts = numInferInferConflicts + 2;
                                                                            if MijBigResultsMatrix{c,m2} ~= 0
                                                                                numInferInferConflicts_unique = numInferInferConflicts_unique + 1;
                                                                                numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                                            end                                                                    

                                                                            [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);                                                                                                                                                                                                           

                                                                            thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                            thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                            thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                            [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                            newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (this pass)'];

                                                                            infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                            MijBigResultsMatrix{c,m2} = 0;

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'INF';

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % new info to this pass
                                                                    else
                                                                        newOrConflictInfo = 'new this pass';
                                                                        infResults(thisInferNum,1) = infResults(thisInferNum,1) + 1;

                                                                        MijBigResultsMatrix{c,m2} = -1;
                                                                        MijInferApplicationsConfirmNeg_PMIDs{c,m2} = cellInferPMID;
                                                                        
                                                                        if isColorCorrProdREIDifferently && (thisInferNum >= firstCorrProdREInum)
                                                                            fillColor = corrREIcolor;
                                                                            if corrProdREIMatrixNeg(c,m2)==0                                                                                
                                                                                numNegCorrProdReiCases = numNegCorrProdReiCases + 1;
                                                                                newCorrProdREI = 1;                                                                               
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                            end
                                                                        else
                                                                            numPosNegNew = numPosNegNew + 1;
                                                                            numNegInferNewInfoCases = numNegInferNewInfoCases + 1;
                                                                            newCorrProdREI = 0;
                                                                        end                                                                        
                                                                        
                                                                        fillWedge = 1;
                                                                        addToLog = 1;
                                                                    end

                                                                    if isIncludeProbInfers && ((~isAllowInfOnSubtypes && fillWedge) || isAllowInfOnSubtypes)
                                                                        fill([m2+1 m2+1 m2+0.5], [c c+1 c+0.5], fillColor);%[0 1 1]                                                                    
                                                                    end

                                                                else
                                                                    %exception code

                                                                end % if isnan(cellInferExceptions)
                                                            end % if sum(find(thisCellContainsNewMarker==2))

                                                            if ~exception
                                                                % an inference was applied
                                                                if (thisInferNum < firstCorrProdREInum) || newCorrProdREI
                                                                    % update counters
                                                                    if ~newCorrProdREI
                                                                        numInferApplications = numInferApplications + 1;
                                                                        infersNeg = infersNeg + 1;
                                                                        numPosNegTotal = numPosNegTotal + 1;
                                                                        
                                                                        tempMijInferApplicationsNeg(c,m2) = 1;
                                                                    else
                                                                        corrProdREIMatrixNeg(c,m2) = 1;
                                                                    end

                                                                    infersApplied(r) = 1;

                                                                    if isempty(MijInferApplicationsNum{c,m2})
                                                                        MijInferApplicationsNum{c,m2} = infers_inferNum(r);
                                                                    else
                                                                        MijInferApplicationsNum{c,m2} = [MijInferApplicationsNum{c,m2} infers_inferNum(r)];
                                                                    end
                                                                    MijInferApplicationsType(c,m2) = infers_inferType(r);                                                                    

                                                                    primaryNTtext = lower(infers_priNeurotrans{r});
                                                                    primaryNTtext = strrep(primaryNTtext, 'all', 'Glutamatergic and GABAergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'glut', 'Glutamatergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'gaba', 'GABAergic');
                                                                    cellInferSubregText = cellInferSubreg;
                                                                    cellInferSubregText = strrep(cellInferSubregText, ',', ' &');

                                                                    if ~newCorrProdREI
                                                                        infTypeCode = negInfCode;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '+ types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '-'];
                                                                    else
                                                                        infTypeCode = negCorProdREI_negInf_Code;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '+ types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '- -- by an inter-matrix data correlation analysis utilizing Barnard''s exact test (see help)'];
                                                                    end

                                                                    if isInferLog && addToLog
                                                                        fprintf(fout, '%d,infer %d,%s,%s %s%s%s %s,%s,%s,negative,%s,%s,%s,%s\n', ...
                                                                            pass, thisInferNum, infers_inferType{r}, cellSubregion, cellPlusOrMinus, cellADpattern, cellProjecting, cellLabel, cellID, ...
                                                                            char(deblank(infers_marker2(r))), reasonText, chainInfo, newOrConflictInfo, cellInferRefID);
                                                                    end

                                                                    if isOutputHybridSheet && addToLog
                                                                        infApplicationMatrix(nextRow,1:5) = {c m2 thisInferNum infTypeCode reasonText};
                                                                        nextRow = nextRow + 1;
                                                                    end
                                                                end
                                                            end % if ~exception


                                                        %% Pos-Pos
                                                        elseif strcmpi(infers_inferType(r),'Pos-pos') ...
                                                        && ( sum(find(thisCellContains==1))>0 || sum(find(thisCellContains==3))>0 || ...
                                                        (MijInferApplicationsPos(c,m1)==1 && isChainInfs) )

                                                            if sum(find(thisCellContains==1))==0 && sum(find(thisCellContains==3))==0
                                                                chainInfo = 'yes';
                                                            else
                                                                chainInfo = '';
                                                            end

                                                            % if matrix is already positive, this inf confirms
                                                            if sum(find(thisCellContainsNewMarker==1))>0 || sum(find(thisCellContainsNewMarker==3))>0
                                                                exception = 0;
                                                                
                                                                if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI                                                                    
                                                                    numPosPosConfirm = numPosPosConfirm + 1;
                                                                    numInferConfirmations = numInferConfirmations + 1;
                                                                    newOrConflictInfo = 'confirm DE';
                                                                    infResults(thisInferNum,4) = infResults(thisInferNum,4) + 1;

                                                                    MijInferApplicationsConfirm(c,m2) = 1;
                                                                    MijInferApplicationsConfirmPos(c,m2) = 1;

                                                                    newCorrProdREI = 0;
                                                                    fillWedge = 1;
                                                                    addToLog = 1;
                                                                else
                                                                    fillWedge = 0;
                                                                    addToLog = 1;
                                                                end

                                                            % new positive wedge
                                                            else
                                                                exception = 0;
                                                                fillColor = 'k';
                                                                
                                                                if isnan(cellInferExceptions) % cells2infers set to temporarily ignore all exceptions                                                                    
                                                                    % conflict with matrix
                                                                    if sum(find(thisCellContainsNewMarker==2))
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numPosPosConflict = numPosPosConflict + 1;
                                                                            numPosInferKnownInfoConflicts = numPosInferKnownInfoConflicts + 1;
                                                                            if isempty(MijBigResultsMatrix{c,m2})
                                                                                numPosInferKnownInfoConflicts_unique = numPosInferKnownInfoConflicts_unique + 1;
                                                                            end
                                                                            newOrConflictInfo = 'conflict with DE';
                                                                            infResults(thisInferNum,2) = infResults(thisInferNum,2) + 1;

                                                                            MijBigResultsMatrix{c,m2} = -1.5; % blue & black

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'DE';

                                                                            newCorrProdREI = 0;
                                                                            if isOverrideMixedLaterPass
                                                                                fillWedge = 0;
                                                                            else
                                                                                fillWedge = 1;
                                                                            end
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % confirm another inf
                                                                    elseif MijInferApplicationsPos(c,m2)==1 || tempMijInferApplicationsPos(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numPosPosConfirmInf = numPosPosConfirmInf + 1;
                                                                            numInferInferConfirmations = numInferInferConfirmations + 1;
                                                                            if MijInferApplicationsPos(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (prev pass)';
                                                                            elseif tempMijInferApplicationsPos(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (this pass)';
                                                                            end
                                                                            infResults(thisInferNum,5) = infResults(thisInferNum,5) + 1;

                                                                            MijInferApplicationsConfirm(c,m2) = 1;
                                                                            MijInferApplicationsConfirmPos(c,m2) = 1;
                                                                            MijInferApplicationsConfirmPos_PMIDs{c,m2} = [MijInferApplicationsConfirmPos_PMIDs{c,m2} ';' cellInferPMID];

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % conflict with another inf from prev pass
                                                                    elseif MijInferApplicationsNeg(c,m2)==1                                                                        
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            if isOverrideMixedLaterPass
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 0;
                                                                                addToLog = 0;
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 1;
                                                                                addToLog = 1;

                                                                                numInferInferConflicts_diffPasses = numInferInferConflicts_diffPasses + 2;
                                                                                numPosPosConflictInf = numPosPosConflictInf + 1;

                                                                                if MijBigResultsMatrix{c,m2} ~= 0
                                                                                    numNegInferNewInfoCases = numNegInferNewInfoCases - 1;
                                                                                end                                                                    

                                                                                [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                    numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                    numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                    numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                    numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                                                thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                                thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                                thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                                [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                    numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                    numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                    numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                    numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                                newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (prev pass)'];

                                                                                infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                                MijBigResultsMatrix{c,m2} = 0;
                                                                            end
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end
                                                                        
                                                                    % conflict with another inf from this pass
                                                                    elseif tempMijInferApplicationsNeg(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numPosPosConflictInf = numPosPosConflictInf + 1;
                                                                            numInferInferConflicts = numInferInferConflicts + 2;
                                                                            if MijBigResultsMatrix{c,m2} ~= 0
                                                                                numInferInferConflicts_unique = numInferInferConflicts_unique + 1;
                                                                                numNegInferNewInfoCases = numNegInferNewInfoCases - 1;
                                                                            end                                                                    

                                                                            [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                                            thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                            thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                            thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                            [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                            newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (this pass)'];

                                                                            infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                            MijBigResultsMatrix{c,m2} = 0;

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'INF';

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % new info to this pass
                                                                    else
                                                                        newOrConflictInfo = 'new this pass';
                                                                        infResults(thisInferNum,1) = infResults(thisInferNum,1) + 1;

                                                                        MijBigResultsMatrix{c,m2} = 1;
                                                                        MijInferApplicationsConfirmPos_PMIDs{c,m2} = cellInferPMID;
                                                                        
                                                                        if isColorCorrProdREIDifferently && (thisInferNum >= firstCorrProdREInum)
                                                                            fillColor = corrREIcolor;
                                                                            if corrProdREIMatrixPos(c,m2)==0                                                                                
                                                                                numPosCorrProdReiCases = numPosCorrProdReiCases + 1;
                                                                                newCorrProdREI = 1;
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                            end
                                                                        else
                                                                            numPosPosNew = numPosPosNew + 1;
                                                                            numPosInferNewInfoCases = numPosInferNewInfoCases + 1;
                                                                            newCorrProdREI = 0;
                                                                        end
                                                                        
                                                                        fillWedge = 1;
                                                                        addToLog = 1;
                                                                    end

                                                                    if isIncludeProbInfers && ((~isAllowInfOnSubtypes && fillWedge) || isAllowInfOnSubtypes)
                                                                        fill([m2 m2+0.5 m2], [c c+0.5 c+1], fillColor);
                                                                    end

                                                                else
                                                                    %exception code

                                                                end % if isnan(cellInferExceptions)
                                                            end % if sum(find(thisCellContainsNewMarker==1))>0 || sum(find(thisCellContainsNewMarker==3))>0

                                                            if ~exception
                                                                % an inference was applied
                                                                if (thisInferNum < firstCorrProdREInum) || newCorrProdREI
                                                                    % update counters
                                                                    if ~newCorrProdREI
                                                                        numInferApplications = numInferApplications + 1;
                                                                        infersPos = infersPos + 1;
                                                                        numPosPosTotal = numPosPosTotal + 1;
                                                                        
                                                                        tempMijInferApplicationsPos(c,m2) = 1;
                                                                    else
                                                                        corrProdREIMatrixPos(c,m2) = 1;
                                                                    end

                                                                    infersApplied(r) = 1;

                                                                    if isempty(MijInferApplicationsNum{c,m2})
                                                                        MijInferApplicationsNum{c,m2} = infers_inferNum(r);
                                                                    else
                                                                        MijInferApplicationsNum{c,m2} = [MijInferApplicationsNum{c,m2} infers_inferNum(r)];
                                                                    end
                                                                    MijInferApplicationsType(c,m2) = infers_inferType(r);                                                                    

                                                                    primaryNTtext = lower(infers_priNeurotrans{r});
                                                                    primaryNTtext = strrep(primaryNTtext, 'all', 'Glutamatergic and GABAergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'glut', 'Glutamatergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'gaba', 'GABAergic');
                                                                    cellInferSubregText = cellInferSubreg;
                                                                    cellInferSubregText = strrep(cellInferSubregText, ',', ' &');

                                                                    if ~newCorrProdREI
                                                                        infTypeCode = posInfCode;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '+ types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '+'];
                                                                    else
                                                                        infTypeCode = posCorProdREI_posInf_Code;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '+ types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '+ -- by an inter-matrix data correlation analysis utilizing Barnard''s exact test (see help)'];
                                                                    end

                                                                    if isInferLog && addToLog
                                                                        fprintf(fout, '%d,infer %d,%s,%s %s%s%s %s,%s,%s,positive,%s,%s,%s,%s\n', ...
                                                                            pass, thisInferNum, infers_inferType{r}, cellSubregion, cellPlusOrMinus, cellADpattern, cellProjecting, cellLabel, cellID, ...
                                                                            char(deblank(infers_marker2(r))), reasonText, chainInfo, newOrConflictInfo, cellInferRefID);
                                                                    end

                                                                    if isOutputHybridSheet && addToLog
                                                                        infApplicationMatrix(nextRow,1:5) = {c m2 thisInferNum infTypeCode reasonText};
                                                                        nextRow = nextRow + 1;
                                                                    end
                                                                end
                                                            end % if ~exception


                                                        %% Contra-PosNeg                                                            
                                                        elseif ~isempty(strfind(infers_inferType{r},'Contra:pos-neg')) ...
                                                        && ( sum(find(thisCellContains==1))>0 || sum(find(thisCellContains==3))>0 || ...
                                                        (MijInferApplicationsPos(c,m1)==1 && isChainInfs) )
                                                    
                                                            if sum(find(thisCellContains==1))==0 && sum(find(thisCellContains==3))==0
                                                                chainInfo = 'yes';
                                                            else
                                                                chainInfo = '';
                                                            end

                                                            % if matrix is already negative, this inf confirms
                                                            if sum(find(thisCellContainsNewMarker==2))>0
                                                                exception = 0;
                                                                
                                                                if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI                                                                    
                                                                    numContra_PosNegConfirm = numContra_PosNegConfirm + 1;
                                                                    numInferConfirmations = numInferConfirmations + 1;
                                                                    newOrConflictInfo = 'confirm DE';
                                                                    infResults(thisInferNum,4) = infResults(thisInferNum,4) + 1;

                                                                    MijInferApplicationsConfirm(c,m2) = 1;
                                                                    MijInferApplicationsConfirmNeg(c,m2) = 1;

                                                                    newCorrProdREI = 0;
                                                                    fillWedge = 1;
                                                                    addToLog = 1;
                                                                else
                                                                    fillWedge = 0;
                                                                    addToLog = 1;
                                                                end

                                                            % new negative wedge
                                                            else
                                                                exception = 0;
                                                                fillColor = 'k';
                                                                
                                                                if isnan(cellInferExceptions) % cells2infers set to temporarily ignore all exceptions                                                                    
                                                                    % conflict with matrix
                                                                    if sum(find(thisCellContainsNewMarker==1))>0 || sum(find(thisCellContainsNewMarker==3))>0
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numContra_PosNegConflict = numContra_PosNegConflict + 1;
                                                                            numNegInferKnownInfoConflicts = numNegInferKnownInfoConflicts + 1;
                                                                            if isempty(MijBigResultsMatrix{c,m2})
                                                                                numNegInferKnownInfoConflicts_unique = numNegInferKnownInfoConflicts_unique + 1;
                                                                            end
                                                                            newOrConflictInfo = 'conflict with DE';
                                                                            infResults(thisInferNum,2) = infResults(thisInferNum,2) + 1;

                                                                            MijBigResultsMatrix{c,m2} = 1.5;  % green & black

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'DE';

                                                                            newCorrProdREI = 0;
                                                                            if isOverrideMixedLaterPass
                                                                                fillWedge = 0;
                                                                            else
                                                                                fillWedge = 1;
                                                                            end
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % confirm another inf
                                                                    elseif MijInferApplicationsNeg(c,m2)==1 || tempMijInferApplicationsNeg(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numContra_PosNegConfirmInf = numContra_PosNegConfirmInf + 1;
                                                                            numInferInferConfirmations = numInferInferConfirmations + 1;
                                                                            if MijInferApplicationsNeg(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (prev pass)';
                                                                            elseif tempMijInferApplicationsNeg(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (this pass)';
                                                                            end
                                                                            infResults(thisInferNum,5) = infResults(thisInferNum,5) + 1;

                                                                            MijInferApplicationsConfirm(c,m2) = 1;
                                                                            MijInferApplicationsConfirmNeg(c,m2) = 1;
                                                                            MijInferApplicationsConfirmNeg_PMIDs{c,m2} = [MijInferApplicationsConfirmNeg_PMIDs{c,m2} ';' cellInferPMID];

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % conflict with another inf from prev pass
                                                                    elseif MijInferApplicationsPos(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            if isOverrideMixedLaterPass
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 0;
                                                                                addToLog = 0;
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 1;
                                                                                addToLog = 1;

                                                                                numContra_PosNegConflictInf = numContra_PosNegConflictInf + 1;
                                                                                numInferInferConflicts_diffPasses = numInferInferConflicts_diffPasses + 2;

                                                                                if MijBigResultsMatrix{c,m2} ~= 0
                                                                                    numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                                                end                                                                    

                                                                                [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                    numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                    numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                    numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                    numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                                                thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                                thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                                thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                                [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                    numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                    numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                    numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                    numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                                newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (prev pass)'];

                                                                                infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                                MijBigResultsMatrix{c,m2} = 0;
                                                                            end
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end
                                                                        
                                                                    % conflict with another inf from this pass
                                                                    elseif tempMijInferApplicationsPos(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numContra_PosNegConflictInf = numContra_PosNegConflictInf + 1;
                                                                            numInferInferConflicts = numInferInferConflicts + 2;
                                                                            if MijBigResultsMatrix{c,m2} ~= 0
                                                                                numInferInferConflicts_unique = numInferInferConflicts_unique + 1;
                                                                                numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                                            end                                                                    

                                                                            [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                                            thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                            thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                            thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                            [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                            newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (this pass)'];

                                                                            infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                            MijBigResultsMatrix{c,m2} = 0;

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'INF';

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % new info to this pass
                                                                    else
                                                                        newOrConflictInfo = 'new this pass';
                                                                        infResults(thisInferNum,1) = infResults(thisInferNum,1) + 1;

                                                                        MijBigResultsMatrix{c,m2} = -1;
                                                                        MijInferApplicationsConfirmNeg_PMIDs{c,m2} = cellInferPMID;
                                                                        
                                                                        if isColorCorrProdREIDifferently && (thisInferNum >= firstCorrProdREInum)
                                                                            fillColor = corrREIcolor;
                                                                            if corrProdREIMatrixNeg(c,m2)==0                                                                                
                                                                                numNegCorrProdReiCases = numNegCorrProdReiCases + 1;
                                                                                newCorrProdREI = 1;
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                            end
                                                                        else
                                                                            numContra_PosNegNew = numContra_PosNegNew + 1;
                                                                            numNegInferNewInfoCases = numNegInferNewInfoCases + 1;
                                                                            newCorrProdREI = 0;
                                                                        end
                                                                        
                                                                        fillWedge = 1;
                                                                        addToLog = 1;
                                                                    end

                                                                    if isIncludeProbInfers && ((~isAllowInfOnSubtypes && fillWedge) || isAllowInfOnSubtypes)
                                                                        fill([m2+1 m2+1 m2+0.5], [c c+1 c+0.5], fillColor);
                                                                    end

                                                                else
                                                                    % exception code

                                                                end % if isnan(cellInferExceptions)
                                                            end % if sum(find(thisCellContainsNewMarker==2))>0

                                                            if ~exception
                                                                % an inference was applied
                                                                if (thisInferNum < firstCorrProdREInum) || newCorrProdREI
                                                                    % update counters
                                                                    if ~newCorrProdREI
                                                                        numInferApplications = numInferApplications + 1;
                                                                        infersNeg = infersNeg + 1;
                                                                        numContra_PosNegTotal = numContra_PosNegTotal + 1;
                                                                        
                                                                        tempMijInferApplicationsNeg(c,m2) = 1;
                                                                    else
                                                                        corrProdREIMatrixNeg(c,m2) = 1;
                                                                    end

                                                                    infersApplied(r) = 1;

                                                                    % mark with negative inf number to indicate contrapos
                                                                    if isempty(MijInferApplicationsNum{c,m2})
                                                                        MijInferApplicationsNum{c,m2} = infers_inferNum(r);
                                                                    else
                                                                        MijInferApplicationsNum{c,m2} = [MijInferApplicationsNum{c,m2} infers_inferNum(r)];
                                                                    end
                                                                    MijInferApplicationsType(c,m2) = infers_inferType(r);                                                                    

                                                                    primaryNTtext = lower(infers_priNeurotrans{r});
                                                                    primaryNTtext = strrep(primaryNTtext, 'all', 'Glutamatergic and GABAergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'glut', 'Glutamatergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'gaba', 'GABAergic');
                                                                    cellInferSubregText = cellInferSubreg;
                                                                    cellInferSubregText = strrep(cellInferSubregText, ',', ' &');

                                                                    if ~newCorrProdREI
                                                                        infTypeCode = contraPosNeg_negInf_Code;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '+ types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '- -- by contrapositive logic'];
                                                                    else
                                                                        infTypeCode = negCorProdREI_negInf_Code;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '+ types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '- -- by contrapositive logic and by an inter-matrix data correlation analysis utilizing Barnard''s exact test (see help)'];
                                                                    end

                                                                    if isInferLog && addToLog
                                                                        fprintf(fout, '%d,infer %d,%s,%s %s%s%s %s,%s,%s,negative,%s,%s,%s,%s\n', ...
                                                                            pass, thisInferNum, infers_inferType{r}, cellSubregion, cellPlusOrMinus, cellADpattern, cellProjecting, cellLabel, cellID, ...
                                                                            char(deblank(infers_marker2(r))), reasonText, chainInfo, newOrConflictInfo, cellInferRefID);
                                                                    end

                                                                    if isOutputHybridSheet && addToLog
                                                                        infApplicationMatrix(nextRow,1:5) = {c m2 thisInferNum infTypeCode reasonText};
                                                                        nextRow = nextRow + 1;
                                                                    end
                                                                end
                                                            end % ~exception


                                                        %% Contra-PosPos
                                                        elseif ~isempty(strfind(infers_inferType{r},'Contra:pos-pos')) ...
                                                        && ( sum(find(thisCellContains==2))>0 || ...
                                                        (MijInferApplicationsNeg(c,m1)==1 && isChainInfs) )

                                                            if sum(find(thisCellContains==2))==0
                                                                chainInfo = 'yes';
                                                            else
                                                                chainInfo = '';
                                                            end                                                

                                                            if sum(find(thisCellContainsNewMarker==2))>0
                                                                exception = 0;
                                                                
                                                                if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI                                                                    
                                                                    numContra_PosPosConfirm = numContra_PosPosConfirm + 1;
                                                                    numInferConfirmations = numInferConfirmations + 1;
                                                                    newOrConflictInfo = 'confirm DE';
                                                                    infResults(thisInferNum,4) = infResults(thisInferNum,4) + 1;

                                                                    MijInferApplicationsConfirm(c,m2) = 1;
                                                                    MijInferApplicationsConfirmNeg(c,m2) = 1;

                                                                    newCorrProdREI = 0;
                                                                    fillWedge = 1;
                                                                    addToLog = 1;
                                                                end

                                                            % new negative wedge
                                                            else
                                                                exception = 0;
                                                                fillColor = 'k';
                                                                
                                                                if isnan(cellInferExceptions) % cells2infers set to temporarily ignore all exceptions                                                                    
                                                                    % conflict with matrix
                                                                    if sum(find(thisCellContainsNewMarker==1))>0 || sum(find(thisCellContainsNewMarker==3))>0
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numContra_PosPosConflict = numContra_PosPosConflict + 1;
                                                                            numNegInferKnownInfoConflicts = numNegInferKnownInfoConflicts + 1;
                                                                            if isempty(MijBigResultsMatrix{c,m2})
                                                                                numNegInferKnownInfoConflicts_unique = numNegInferKnownInfoConflicts_unique + 1;
                                                                            end
                                                                            newOrConflictInfo = 'conflict with DE';
                                                                            infResults(thisInferNum,2) = infResults(thisInferNum,2) + 1;

                                                                            MijBigResultsMatrix{c,m2} = 1.5;  % green & black

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'DE';

                                                                            newCorrProdREI = 0;
                                                                            if isOverrideMixedLaterPass
                                                                                fillWedge = 0;
                                                                            else
                                                                                fillWedge = 1;
                                                                            end
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % confirm another inf
                                                                    elseif MijInferApplicationsNeg(c,m2)==1 || tempMijInferApplicationsNeg(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numContra_PosPosConfirmInf = numContra_PosPosConfirmInf + 1;
                                                                            numInferInferConfirmations = numInferInferConfirmations + 1;
                                                                            if MijInferApplicationsNeg(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (prev pass)';
                                                                            elseif tempMijInferApplicationsNeg(c,m2)==1
                                                                                newOrConflictInfo = 'confirm inf (this pass)';
                                                                            end
                                                                            infResults(thisInferNum,5) = infResults(thisInferNum,5) + 1;

                                                                            MijInferApplicationsConfirm(c,m2) = 1;
                                                                            MijInferApplicationsConfirmNeg(c,m2) = 1;
                                                                            MijInferApplicationsConfirmNeg_PMIDs{c,m2} = [MijInferApplicationsConfirmNeg_PMIDs{c,m2} ';' cellInferPMID];

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % conflict with another inf from prev pass
                                                                    elseif MijInferApplicationsPos(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            if isOverrideMixedLaterPass
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 0;
                                                                                addToLog = 0;
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                                fillWedge = 1;
                                                                                addToLog = 1;

                                                                                numContra_PosPosConflictInf = numContra_PosPosConflictInf + 1;
                                                                                numInferInferConflicts_diffPasses = numInferInferConflicts_diffPasses + 2;

                                                                                if MijBigResultsMatrix{c,m2} ~= 0
                                                                                    numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                                                end                                                                    

                                                                                [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                    numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                    numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                    numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                    numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                                                thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                                thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                                thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                                [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                    numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                    numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                    numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                    numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                                newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (prev pass)'];

                                                                                infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                                MijBigResultsMatrix{c,m2} = 0;
                                                                            end
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end
                                                                        
                                                                    % conflict with another inf from this pass
                                                                    elseif tempMijInferApplicationsPos(c,m2)==1
                                                                        if (thisInferNum < firstCorrProdREInum) % if not a correlation-produced REI
                                                                            numContra_PosPosConflictInf = numContra_PosPosConflictInf + 1;
                                                                            numInferInferConflicts = numInferInferConflicts + 2;
                                                                            if MijBigResultsMatrix{c,m2} ~= 0
                                                                                numInferInferConflicts_unique = numInferInferConflicts_unique + 1;
                                                                                numPosInferNewInfoCases = numPosInferNewInfoCases - 1;
                                                                            end                                                                    

                                                                            [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
                                                                                numPosNegConflictInf, numPosPosConflictInf, numContra_PosNegConflictInf, ...
                                                                                numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferApplicationsType{c,m2}, ...
                                                                                numAxonsProjNegConflictInf, numLayerNegConflictInf, numPosNegConflictInf, ...
                                                                                numPosPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf);

                                                                            thisConflictNum = MijInferApplicationsNum{c,m2};
                                                                            thisConflictPos = find(infers_inferNum==thisConflictNum(1));
                                                                            thisConflictType = infers_inferType{thisConflictPos(1)};

                                                                            [numAxonsProjNegNew, numLayerNegNew, ...
                                                                                numPosNegNew, numPosPosNew, numContra_PosNegNew, ...
                                                                                numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
                                                                                numAxonsProjNegNew, numLayerNegNew, numPosNegNew, ...
                                                                                numPosPosNew, numContra_PosNegNew, numContra_PosPosNew);

                                                                            newOrConflictInfo = ['conflict with inf (' num2str(thisConflictNum) ') (this pass)'];

                                                                            infResults(thisInferNum,3) = infResults(thisInferNum,3) + 1;

                                                                            MijBigResultsMatrix{c,m2} = 0;

                                                                            conflictNum = size(conflictList,1);
                                                                            conflictList{conflictNum+1,1} = [cellSubregion ' ' cellPlusOrMinus cellADpattern cellProjecting ' ' cellLabel];
                                                                            conflictList{conflictNum+1,2} = char(deblank(infers_marker2(r)));
                                                                            conflictList{conflictNum+1,3} = 'INF';

                                                                            newCorrProdREI = 0;
                                                                            fillWedge = 1;
                                                                            addToLog = 1;
                                                                        else
                                                                            fillWedge = 0;
                                                                            addToLog = 1;
                                                                        end

                                                                    % new info to this pass
                                                                    else
                                                                        newOrConflictInfo = 'new this pass';
                                                                        infResults(thisInferNum,1) = infResults(thisInferNum,1) + 1;

                                                                        MijBigResultsMatrix{c,m2} = -1;
                                                                        MijInferApplicationsConfirmNeg_PMIDs{c,m2} = cellInferPMID;
                                                                        
                                                                        if isColorCorrProdREIDifferently && (thisInferNum >= firstCorrProdREInum)
                                                                            fillColor = corrREIcolor;
                                                                            if corrProdREIMatrixNeg(c,m2)==0                                                                                
                                                                                numNegCorrProdReiCases = numNegCorrProdReiCases + 1;
                                                                                newCorrProdREI = 1;
                                                                            else
                                                                                newCorrProdREI = 0;
                                                                            end
                                                                        else
                                                                            numContra_PosPosNew = numContra_PosPosNew + 1;
                                                                            numNegInferNewInfoCases = numNegInferNewInfoCases + 1;
                                                                            newCorrProdREI = 0;
                                                                        end
                                                                        
                                                                        fillWedge = 1;
                                                                        addToLog = 1;
                                                                    end

                                                                    if isIncludeProbInfers && ((~isAllowInfOnSubtypes && fillWedge) || isAllowInfOnSubtypes)
                                                                        fill([m2+1 m2+1 m2+0.5], [c c+1 c+0.5], fillColor);
                                                                    end

                                                                else
                                                                    % exception code

                                                                end % if isnan(cellInferExceptions)
                                                            end % if sum(find(thisCellContainsNewMarker==2))>0

                                                            if ~exception
                                                                % an inference was applied
                                                                if (thisInferNum < firstCorrProdREInum) || newCorrProdREI
                                                                    % update counters
                                                                    if ~newCorrProdREI
                                                                        numInferApplications = numInferApplications + 1;
                                                                        infersNeg = infersNeg + 1;
                                                                        numContra_PosPosTotal = numContra_PosPosTotal + 1;
                                                                        
                                                                        tempMijInferApplicationsNeg(c,m2) = 1;
                                                                    else
                                                                        corrProdREIMatrixNeg(c,m2) = 1;
                                                                    end                                                                    

                                                                    infersApplied(r) = 1;

                                                                    % mark with negative inf number to indicate contrapos
                                                                    if isempty(MijInferApplicationsNum{c,m2})
                                                                        MijInferApplicationsNum{c,m2} = infers_inferNum(r);
                                                                    else
                                                                        MijInferApplicationsNum{c,m2} = [MijInferApplicationsNum{c,m2} infers_inferNum(r)];
                                                                    end
                                                                    MijInferApplicationsType(c,m2) = infers_inferType(r);                                                                    

                                                                    primaryNTtext = lower(infers_priNeurotrans{r});
                                                                    primaryNTtext = strrep(primaryNTtext, 'all', 'Glutamatergic and GABAergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'glut', 'Glutamatergic');
                                                                    primaryNTtext = strrep(primaryNTtext, 'gaba', 'GABAergic');
                                                                    cellInferSubregText = cellInferSubreg;
                                                                    cellInferSubregText = strrep(cellInferSubregText, ',', ' &');

                                                                    if ~newCorrProdREI
                                                                        infTypeCode = contraPosPos_negInf_Code;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '- types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '- -- by contrapositive logic'];
                                                                    else
                                                                        infTypeCode = negCorProdREI_negInf_Code;
                                                                        reasonText = [primaryNTtext ' ' char(deblank(infers_marker1(r))) '- types in ' cellInferSubregText ' ' cellInferLayers ' are probably ' char(deblank(infers_marker2(r))) '- -- by contrapositive logic and by an inter-matrix data correlation analysis utilizing Barnard''s exact test (see help)'];
                                                                    end

                                                                    if isInferLog && addToLog
                                                                        fprintf(fout, '%d,infer %d,%s,%s %s%s%s %s,%s,%s,negative,%s,%s,%s,%s\n', ...
                                                                            pass, thisInferNum, infers_inferType{r}, cellSubregion, cellPlusOrMinus, cellADpattern, cellProjecting, cellLabel, cellID, ...
                                                                            char(deblank(infers_marker2(r))), reasonText, chainInfo, newOrConflictInfo, cellInferRefID);
                                                                    end

                                                                    if isOutputHybridSheet && addToLog
                                                                        infApplicationMatrix(nextRow,1:5) = {c m2 thisInferNum infTypeCode reasonText};
                                                                        nextRow = nextRow + 1;
                                                                    end
                                                                end
                                                            end % if ~exception

                                                        end % if (infers_inferType(r),'Prob-neg') elseif 'Prob-pos'
                                                    end %if strcmpi(deblank(infers_marker1(r)), deblank(markerLabels(m2)))
                                                end %for m2
                                            end %if strcmp(infers_inferType(r),'Layer-neg')
                                        end %if infers_marker1
                                    end %for m1

                            end %if strcmpi(infers_priNeurotrans(r), 'ALL') || ...
                        end %if isInferMorphBased
                    end %if (isequal(inferApplicationLayers(r,:) & somataLocations(c,:), somataLocations(c,:)))
                end %for c               
            end %if isnan(infers_dontuse(r))
        end %for r

        pass = pass + 1;
        
    end %while
    
    MijInferApplicationsPos = MijInferApplicationsPos | tempMijInferApplicationsPos;
    MijInferApplicationsNeg = MijInferApplicationsNeg | tempMijInferApplicationsNeg;
        
    numPosInfFlagsByType = sum(MijInferApplicationsPos,2);
    numNegInfFlagsByType = sum(MijInferApplicationsNeg,2);
    numConfirmingInfFlagsByType = sum(MijInferApplicationsConfirm,2);
    numConfirmingNegInfFlagsByType = sum(MijInferApplicationsConfirmNeg,2);
    numConfirmingPosInfFlagsByType = sum(MijInferApplicationsConfirmPos,2);

    if isInferLog
        fclose(fout);
    end
    
    save inference_data.mat *
    
    
    for i=1:maxInferNum
        infResults(i,6) = (infResults(i,2) + infResults(i,3)) / (infResults(i,4) + infResults(i,5));
    end
    save infResults.mat infResults

end






function [numAxonsProjNegConflictInf, numLayerNegConflictInf, ...
    numProbNegConflictInf, numProbPosConflictInf, numContra_PosNegConflictInf, ...
    numContra_PosPosConflictInf] = determineInfInfConflictSourceAndAddToConflictCount(MijInferTypeInPlay, ...
    numAxonsProjNegConflictInf, numLayerNegConflictInf, numProbNegConflictInf, ...
    numProbPosConflictInf, numContra_PosNegConflictInf, numContra_PosPosConflictInf)


    if ~isempty(strfind(MijInferTypeInPlay,'Contra:pos-neg'))
        MijInferTypeInPlay = 'Contra:pos-neg';
    elseif ~isempty(strfind(MijInferTypeInPlay,'Contra:pos-pos'))
        MijInferTypeInPlay = 'Contra:pos-pos';
    end
        
    switch MijInferTypeInPlay
        case 'Axons-proj-neg'
            numAxonsProjNegConflictInf = numAxonsProjNegConflictInf + 1;
        case 'Layer-neg'
            numLayerNegConflictInf = numLayerNegConflictInf + 1;
        case 'Pos-neg'      
            numProbNegConflictInf = numProbNegConflictInf + 1;
        case 'Pos-pos'
            numProbPosConflictInf = numProbPosConflictInf + 1;
        case 'Contra:pos-neg'
            numContra_PosNegConflictInf = numContra_PosNegConflictInf + 1;
        case 'Contra:pos-pos'
            numContra_PosPosConflictInf = numContra_PosPosConflictInf + 1;
    end
end % function


function [numAxonsProjNegNew, numLayerNegNew, ...
    numProbNegNew, numProbPosNew, numContra_PosNegNew, ...
    numContra_PosPosNew] = determineInfInfConflictSourceAndSubtractFromNewCount(thisConflictType, ...
    numAxonsProjNegNew, numLayerNegNew, numProbNegNew, ...
    numProbPosNew, numContra_PosNegNew, numContra_PosPosNew)


    if ~isempty(strfind(thisConflictType,'Contra:pos-neg'))
        thisConflictType = 'Contra:pos-neg';
    elseif ~isempty(strfind(thisConflictType,'Contra:pos-pos'))
        thisConflictType = 'Contra:pos-pos';
    end
        
    switch thisConflictType
        case 'Axons-proj-neg'
            numAxonsProjNegNew = numAxonsProjNegNew - 1;
        case 'Layer-neg'
            numLayerNegNew = numLayerNegNew - 1;
        case 'Pos-neg'      
            numProbNegNew = numProbNegNew - 1;
        case 'Pos-pos'
            numProbPosNew = numProbPosNew - 1;
        case 'Contra:pos-neg'
            numContra_PosNegNew = numContra_PosNegNew - 1;
        case 'Contra:pos-pos'
            numContra_PosPosNew = numContra_PosPosNew - 1;
    end
end % function