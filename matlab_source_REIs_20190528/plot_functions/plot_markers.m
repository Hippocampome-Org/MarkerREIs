function plot_markers(cellsMarkers, somataLoaded, infersLoaded)    
    load markers.mat
    load mij.mat
    load markerToggles.mat
    load isIncludeMarkers.mat
    if somataLoaded
        load somata.mat
        load sij.mat
    end


    % Green-blue color scheme
    posColor = [0 1 0];       % positive = green
    posTildeColor = [0.7 1.0 0.7];       % positive = green
%     wkPosColor = [1.0 0.6 0.0];     % weakly positive = orange
%     wkPosTildeColor = [1.0 0.9 0.6];     % weakly positive = orange
    wkPosColor = posColor;
    wkPosTildeColor = posTildeColor;
    negColor = [0.0 0.0 1.0];       % negative = blue
    negTildeColor = [0.56 0.67 1.0];       % negative = blue
%     mixedColor1 = [0.4 0 0.4];
    mixedColor2 = [1 0 0];
    mixedColor3 = [1 0.6 0];
    mixedColor4 = [0.6 0 0.6];
    
    questionColor = [1.0 0.1 0.6];      % question = pink
    noInfoColor = [0.95 0.95 0.95];    % no information = gray
    unknownColor = [1.0 1.0 1.0];   % unknown = white
    
    corrREIcolor = [0.8 0.8 0.8];
    
    
    count_posDE = 0;
    count_negDE = 0;
    count_mixedSubtypes = 0;
    count_mixedConflict = 0;
    count_mixedSpecProt = 0;
    count_mixedSubcellExp = 0;
    count_question = 0;
    count_noInfo = 0;
    count_searching = 0;
    count_posInf = 0;
    count_negInf = 0;
    count_posDE_negInf = 0;
    count_posInf_negDE = 0;

    count_posDE_conf = 0;
    count_negDE_conf = 0;
    count_posInf_conf = 0;
    count_negInf_conf = 0;
    
    numInfInfConflicts_unresolved = 0;
    numInfInfConflicts_specProt = 0;
    numInfInfConflicts_subtypes = 0;
    
    
    %% set up page %% 
    
    displayFontSize = 6;
    vStart = -6;  %-6.3;  % for parent paper figure
    vEnd = nAllCells+5;
    hNamespace = 20;    %11; % for parent paper figure
    hStart = 0 - hNamespace;
    hLegendspace = 25;
    hLegendStart = nMarkersToPrint + 7;
    hLegendEnd = hLegendStart + hLegendspace;
    hEnd = hLegendEnd;
    
    line_width = 1; 
    

    newplot
    clf('reset'); cla('reset');
    
    
    %% set plot parameters to control page size and axes

    set(gcf, 'color', 'w');
    set(gcf, 'PaperUnits', 'inches');
    %set(gcf, 'PaperSize', [8 11]);
    set(gcf, 'PaperSize', [16 16]);
    set(gcf, 'PaperPositionMode', 'manual');
    %set(gcf, 'PaperPosition', [0 0 8 11]);   
    set(gcf, 'PaperPosition', [0 0 16 16]);   
    set(gca, 'Position', get(gca, 'OuterPosition') - get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);   

    axis([hStart hEnd vStart vEnd])
    axis ij
    axis equal
    axis off
    hold on

    
    %% plot empty grid
    MijPlot = zeros(nAllCells+1, nMarkersToPrint+1);
    colormap([1.0 1.0 1.0;]);
    pcolor(MijPlot);
    
    
    %% APPLY inferences %%

    apply_inferences(somataLoaded, infersLoaded);
    load inference_data.mat    
    
    
    %% PLOT %%
    fprintf(1, 'Plotting matrix...');
    
    isIncludeSpeciesMethods = 0;

    for i = 1:nAllCells
        for j = nMarkersToPrint:-1:1
            
            cellUnk = 0;
            cellPos = 0;
            cellNeg = 0;
            cellWkPos = 0;
            
            emptyButContainsInfResults = 0;

            % interpret levels here        
            thisNumLevels = MijNumLevels(i,j);
            
            % if a flag to fill in
            if (thisNumLevels ~= 0)
                if thisNumLevels==0
                    thisCellContains = 0;
                    emptyButContainsInfResults = 1;
                elseif thisNumLevels==1
                    thisCellContains = MijLevels{i,j};
                else
                    thisCellContains = MijLevels{i,j};              
                    thisCellContains = thisCellContains{1,1};
                end

                
                if find(thisCellContains == -2)     % we have a question
                    fill([j j+1 j+1 j], [i i i+1 i+1], questionColor);
                    count_question = count_question + 1;
                end
                if find(thisCellContains == -1)     % no info
                    cellUnk = 1;
                    if ~(isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers) || ((isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers) && (MijInferApplicationsPos(i,j)==0 && MijInferApplicationsNeg(i,j)==0 && corrProdREIMatrixPos(i,j)==0 && corrProdREIMatrixNeg(i,j)==0))
                        %fill([j j+1 j+1 j], [i i i+1 i+1], noInfoColor);
                        fill([j j+1 j+1 j], [i i i+1 i+1], 'w');
                        count_noInfo = count_noInfo + 1;
                    end
                end
                
                
                if find(thisCellContains==1)        % positive
                    cellPos = 1;                                        
                    if isempty(MijBigResultsMatrix{i,j}) % empty if no infs OR only inf confirms
                        MijBigResultsMatrix{i,j} = 2;                        
                    end
                end
                if find(thisCellContains==3)        % wk positive
                    cellWkPos = 1;                    
                    if isempty(MijBigResultsMatrix{i,j}) % empty if no infs OR only inf confirms
                        MijBigResultsMatrix{i,j} = 2;
                    end
                end
                if find(thisCellContains==2)        % negative
                    cellNeg = 1;                    
                    if isempty(MijBigResultsMatrix{i,j}) % empty if no infs OR only inf confirms
                        MijBigResultsMatrix{i,j} = -2;
                    end
                end
                
                if (cellNeg && (cellPos || cellWkPos))                    
                    switch MijMixedFlagCodes(i,j)
                        case 1 % subtypes                            
                            MijBigResultsMatrix{i,j} = 10;

                        case 2 % conflicting data
                            MijBigResultsMatrix{i,j} = 20;
                            
                        case 3 % species/protocol differences
                            MijBigResultsMatrix{i,j} = 30;
                            
                        case 4 % subcellular expression differences                            
                            MijBigResultsMatrix{i,j} = 40;
                            
                        otherwise
                            MijBigResultsMatrix{i,j} = 10;
                    end
                end
                
                
                
                if ~isempty(MijBigResultsMatrix{i,j})
                    switch MijBigResultsMatrix{i,j}
                        case 2 % pos DE (green)
                            if MijTildes(i,j)
                                fill([j j+0.5 j], [i i+0.5 i+1], posTildeColor);
                            else
                                fill([j j+0.5 j], [i i+0.5 i+1], posColor);
                            end

                            count_posDE = count_posDE + 1;

                            if MijInferApplicationsConfirmPos(i,j)==1
                                plot(j+0.2, i+0.5, '.w', 'MarkerSize', 5);
                                count_posDE_conf = count_posDE_conf + 1;
                            end
                            
                        case -2 % neg DE (blue)
                            if MijTildes(i,j)
                                fill([j+1 j+1 j+0.5], [i i+1 i+0.5], negTildeColor);
                            else
                                fill([j+1 j+1 j+0.5], [i i+1 i+0.5], negColor);
                            end
                            
                            count_negDE = count_negDE + 1;
                            
                            if MijInferApplicationsConfirmNeg(i,j)==1
                                plot(j+0.8, i+0.5, '.w', 'MarkerSize', 5);
                                count_negDE_conf = count_negDE_conf + 1;
                            end
                            
                            
                        case 1.5 % pos DE-inf (green-black)
                            fill([j j+0.5 j], [i i+0.5 i+1], posColor);
                            
                            count_posDE_negInf = count_posDE_negInf + 1;
                            
                            if MijInferApplicationsConfirmPos(i,j)==1
                                plot(j+0.2, i+0.5, '.w', 'MarkerSize', 5);
                                count_posDE_conf = count_posDE_conf + 1;
                            end                                                        
                            
                        case -1.5 % inf-neg DE (black-blue)
                            fill([j+1 j+1 j+0.5], [i i+1 i+0.5], negColor);
                            
                            count_posInf_negDE = count_posInf_negDE + 1;
                            
                            if MijInferApplicationsConfirmNeg(i,j)==1
                                plot(j+0.8, i+0.5, '.w', 'MarkerSize', 5);
                                count_negDE_conf = count_negDE_conf + 1;
                            end                                                       

                            
                        case 1 % pos inf (pos black)
                            count_posInf = count_posInf + 1;
                            
                            if MijInferApplicationsConfirmPos(i,j)==1                                                                
                                theseConfirmingPMIDs = MijInferApplicationsConfirmPos_PMIDs{i,j};
                                uniquePMIDs = unique(strsplit(theseConfirmingPMIDs, ';'));
                                
                                plot(j+0.2, i+0.5, '.w', 'MarkerSize', 5);
                                count_posInf_conf = count_posInf_conf + 1;
                            end
                            
                        case -1 % neg inf (neg black)
                            count_negInf = count_negInf + 1;
                            
                            if MijInferApplicationsConfirmNeg(i,j)==1
                                theseConfirmingPMIDs = MijInferApplicationsConfirmNeg_PMIDs{i,j};
                                uniquePMIDs = unique(strsplit(theseConfirmingPMIDs, ';'));
                                
                                plot(j+0.8, i+0.5, '.w', 'MarkerSize', 5);
                                count_negInf_conf = count_negInf_conf + 1;
                            end                            
                        

                        case 0 % inf-inf (black-black)
                            if (isIncludeAxonInfers && isIncludeLayerInfers && isIncludeProbInfers) 
                                infConflictCode = determineInfInfConflictSrc(i,j);

                                switch infConflictCode
                                    case '{a}'
                                        fill([j j+1 j+1 j], [i i i+1 i+1], 'w');
                                        fill([j j+0.5 j+1], [i+1 i+0.5 i+1], 'k');
                                        numInfInfConflicts_unresolved = numInfInfConflicts_unresolved + 1;

                                    case '{b}'
                                        fill([j j+1 j+1 j], [i i i+1 i+1], 'w');
                                        fill([j j+1 j+0.5], [i i i+0.5], 'k');
                                        numInfInfConflicts_specProt = numInfInfConflicts_specProt + 1;

                                    otherwise
                                        numInfInfConflicts_subtypes = numInfInfConflicts_subtypes + 1;
                                        % leave as double black flag
                                end
                            end

                        case 10 % pos DE-neg DE mix subtypes (blue-green)
                            fill([j j+0.5 j], [i i+0.5 i+1], posColor);
                            fill([j+1 j+1 j+0.5], [i i+1 i+0.5], negColor);
                            count_mixedSubtypes = count_mixedSubtypes + 1;

                        case 20 % pos DE-neg DE mix conflict (red)
                            fill([j j+0.5 j+1], [i+1 i+0.5 i+1], mixedColor2);
                            count_mixedConflict = count_mixedConflict + 1;

                        case 30 % pos DE-neg DE mix species/prot (orange)
                            fill([j j+1 j+0.5], [i i i+0.5], mixedColor3);
                            count_mixedSpecProt = count_mixedSpecProt + 1;
                            
                        case 40 % pos DE-neg DE mix sub-cellular differences
                            fill([j j+1 j+0.5], [i i i+0.5], mixedColor4);
                            count_mixedSubcellExp = count_mixedSubcellExp + 1;

                    end
                end
                
            else
                if ~(isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers) || ((isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers) && (MijInferApplicationsPos(i,j)==0 && MijInferApplicationsNeg(i,j)==0))
                    count_searching = count_searching + 1;
                end
            end %if thisNumLevels ~= 0
        end % for j
    end % for i

    
    if isIncludePrintedMarkers_Summary || isIncludeUnprintedMarkers_Summary
        blackFlagMatrix = ~cellfun('isempty', MijBigResultsMatrix);
        anyFlagMatrix = blackFlagMatrix | MijHaveInfo;
        cutoff = nOfficialMarkers_PlusMarkersWithInfs;  %nMarkersToPrint;
        MijPrintedSummary_All = sum(anyFlagMatrix(:,1:cutoff), 2);
        MijUnprintedSummary_All = sum(anyFlagMatrix(:,cutoff+1:nTotalMarkers), 2);
        
        if isIncludePrintedMarkers_Summary && isIncludeUnprintedMarkers_Summary
            fill([nMarkersToPrint+2 nMarkersToPrint+6 nMarkersToPrint+6 nMarkersToPrint+2], [1 1 nAllCells+1 nAllCells+1], 'white');     
            line([nMarkersToPrint+4, nMarkersToPrint+4], [1, nAllCells+1], 'linewidth', line_width, 'color', [0 0 0])
        else
            fill([nMarkersToPrint+2 nMarkersToPrint+4 nMarkersToPrint+4 nMarkersToPrint+2], [1 1 nAllCells+1 nAllCells+1], 'white');
        end

        for k=1:nAllCells
            if isIncludePrintedMarkers_Summary
                strng = sprintf('%d', MijPrintedSummary_All(k));
                text(nMarkersToPrint+3, k+0.55, strng, 'HorizontalAlignment', 'center', 'FontSize', displayFontSize, 'Color', 'k');

                line([nMarkersToPrint+2 nMarkersToPrint+4], [k+1, k+1], 'linewidth', line_width, 'color', [0 0 0])
            end
            
            if isIncludeUnprintedMarkers_Summary
                strng = sprintf('%d', MijUnprintedSummary_All(k));
                
                if isIncludePrintedMarkers_Summary                    
                    line([nMarkersToPrint+4 nMarkersToPrint+6], [k+1, k+1], 'linewidth', line_width, 'color', [0 0 0])
                    text(nMarkersToPrint+5, k+0.55, strng, 'HorizontalAlignment', 'center', 'FontSize', displayFontSize, 'Color', 'k');                    
                else
                    line([nMarkersToPrint+2 nMarkersToPrint+4], [k+1, k+1], 'linewidth', line_width, 'color', [0 0 0])
                    text(nMarkersToPrint+3, k+0.55, strng, 'HorizontalAlignment', 'center', 'FontSize', displayFontSize, 'Color', 'k');                                        
                end
            end               
        end       

        if isIncludePrintedMarkers_Summary
            text(nMarkersToPrint+3, 0.5, '"Official"', 'rotation', 90, 'FontSize', displayFontSize, 'Color', 'k');

            %strng = sprintf('%d', sum(MijUnprintedSummary_Pos) + sum(MijUnprintedSummary_Neg) + sum(MijUnprintedSummary_Mix));
            %text(nMarkersToPrint+3, nAllCells+1.5, strng, 'rotation', 180, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
        end
        
        if isIncludeUnprintedMarkers_Summary
            if isIncludePrintedMarkers_Summary
                myTextPos = nMarkersToPrint+5;
            else
                myTextPos = nMarkersToPrint+3;
            end
            
            text(myTextPos, 0.5, 'Additional', 'rotation', 90, 'FontSize', displayFontSize, 'Color', 'k');

            %strng = sprintf('%d', sum(MijPrintedSummary_Pos) + sum(MijPrintedSummary_Neg) + sum(MijPrintedSummary_Mix) + sum(numPosInfFlagsByType) + sum(numNegInfFlagsByType) - sum(numConfirmingInfFlagsByType));
            %text(myTextPos, nAllCells+1.5, strng, 'rotation', 180, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
        end
    end
    

    %% print axes %%
    fprintf(1, '\nPlotting axes...');
    
    % insert empty row and column at top and left of cell array for cell &
    % marker labels
    MijBigResultsMatrix(2:end+1,:) = MijBigResultsMatrix;
    MijBigResultsMatrix(1,:) = {''};
    MijBigResultsMatrix(:,4:end+3) = MijBigResultsMatrix;
    MijBigResultsMatrix(:,1:3) = {''};
    
    % Print marker group headings
    
    % halfway bet 1&4
    text(2.5, vStart+1, {'Ca^{2+}', 'binding', 'proteins'}, ...
        'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
    % halfway bet 4&18
    text(11, vStart+1, {'Receptors'}, ...
        'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
    % halfway bet 18&22
    text(20, vStart+1, {'Transporters/', 'channels'}, ...
        'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');    
    % halfway bet 22&31
    text(26.5, vStart+1, {'Neuropeptides'}, ...
        'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
    % halfway bet 31&34
    text(32.5, vStart+1, {'Enzymes'}, ...
        'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
    % halfwawy bet 34&36
    text(35, vStart+1, {'Matrix proteins'}, ...
        'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
    % halfway bet 36&38
    text(37, vStart+1, {'Transcription', 'factors'}, ...
        'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');    
    if isIncludeUntrackedMarkers_All
        text((nOfficialMarkers + nUnofficialMarkers/2), vStart+1, 'Others', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
    end    
    
    
    % print marker names across top x-axis AND col totals at bottom
    
    MijHaveInfoColSums = sum((MijHaveInfo | MijInferApplicationsPos | MijInferApplicationsNeg), 1);
        
    for j = 1:nMarkersToPrint
        if (markerOrigPaperOrder{j} <= 20)
            text(j+0.5, 0.5, markerLabels{j}, 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'k');
        else
            text(j+0.5, 0.5, markerLabels{j}, 'rotation', 90, 'FontSize', displayFontSize, 'Color', 'k');
        end
        MijBigResultsMatrix{1,j+3} = markerLabels{j};
        
        strng = sprintf('%d', MijHaveInfoColSums(j));
        text(j+0.5, nAllCells+1.5, strng, 'rotation', 90, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'Color', 'k');        
            
        if isIncludeAllColTotals
            MijAllFlagSum = sum(MijPos(:,j)) + sum(MijInferApplicationsPos(:,j)) - sum(MijInferApplicationsConfirmPos(:,j)) ...
                + sum(MijNeg(:,j)) + sum(MijInferApplicationsNeg(:,j)) - sum(MijInferApplicationsConfirmNeg(:,j)) ...
                - MijHaveInfoColSums(j);
            strng = sprintf('%d', MijAllFlagSum);
            text(j+0.5, nAllCells+3, strng, 'rotation', 90, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'Color', 'k');        

            MijPosNegRatios = (sum(MijPos(:,j)) + sum(MijInferApplicationsPos(:,j)) - sum(MijInferApplicationsConfirmPos(:,j))) / ...
                (sum(MijNeg(:,j)) + sum(MijInferApplicationsNeg(:,j)) - sum(MijInferApplicationsConfirmNeg(:,j)));
            strng = sprintf('%.2g', MijPosNegRatios);        
            text(j+0.5, nAllCells+4.5, strng, 'rotation', 90, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'Color', 'k');
        end
    end
    
    text(0.5, nAllCells+2, 'Types with information', 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'Color', 'k');
    if isIncludeAllColTotals
        text(0.5, nAllCells+3.5, 'Num mixed', 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'Color', 'k');
        text(0.5, nAllCells+5, 'Ratio pos/neg', 'HorizontalAlignment', 'right', 'FontSize', displayFontSize, 'Color', 'k');
    end
   
    
    % plot labels and a/d patterns
    for i = 1:nAllCells
        cellID = cellUniqueIDsMarkers{i};
        
        clear cellLabel
        cellLabel = cellLabelsMarkers{i};
        cellLabel = deblank(cellLabel);

        plusOrMinus = deblank(char(MijPlusOrMinus{i}));
        
        
        if ~somataLoaded
            AD_pattern = deblank(MijAD_pattern{i});
        else
            cellSubregion = cellSubregionsMarkers{i};
            cellSubregion = deblank(cellSubregion);

            if strcmp(cellSubregion, 'DG')
                subregionNum = 1;
                current_subregion_somataLocations = DGsomataLocations;
            elseif strcmp(cellSubregion, 'CA3')
                subregionNum = 2;
                current_subregion_somataLocations = CA3somataLocations;
            elseif strcmp(cellSubregion, 'CA2')
                subregionNum = 3;
                current_subregion_somataLocations = CA2somataLocations;
            elseif strcmp(cellSubregion, 'CA1')
                subregionNum = 4;
                current_subregion_somataLocations = CA1somataLocations;
            elseif strcmp(cellSubregion, 'SUB')
                subregionNum = 5;
                current_subregion_somataLocations = SUBsomataLocations;
            elseif strcmp(cellSubregion, 'EC')
                subregionNum = 6;
                current_subregion_somataLocations = ECsomataLocations;
            end

            temp_AD_pattern = deblank(MijAD_pattern{i});
            AD_pattern = '';
            
            for j=1:somata_parcel_matrix(subregionNum)
                if current_subregion_somataLocations(i,j) == 0
                    AD_pattern = [AD_pattern temp_AD_pattern(j)];
                else
                    AD_pattern = [AD_pattern '\bf{\color[rgb]{0.5 0 0}' temp_AD_pattern(j) '}\rm'];
                end
            end
        end
                        
        if ~isnan(MijProjecting{i})
            projecting = deblank(MijProjecting{i});
        else
            projecting = '';
        end        

        if (strcmp(plusOrMinus,'(-)'))
            labelColor = [0.375 0.375 0.375];
        else
            labelColor = [0 0 0];
        end
        
%         % to print with numeric patterns and plus-minuses
%         strng = sprintf('%s %s%s', cellLabel, plusOrMinus, AD_pattern);
%         text(0, i+0.4, strng, 'color', labelColor, ...
%             'BackgroundColor', 'white', 'Margin', 0.1, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize);
%         text(0, i+0.4, projecting, 'color', labelColor, ...
%             'BackgroundColor', 'white', 'Margin', 0.1, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize);

%         % to print names and numeric patterns
        strng = sprintf('%s', AD_pattern);
        text(-1, i+0.4, strng, 'color', labelColor, ...
            'HorizontalAlignment', 'center', 'FontSize', displayFontSize);
        strng = sprintf('%s', cellLabel);
        text(-3, i+0.4, strng, 'color', labelColor, ...
            'HorizontalAlignment', 'right', 'FontSize', displayFontSize);

%         % to print names only
%         strng = sprintf('%s', cellLabel);
%         text(0.5, i+0.55, strng, 'color', labelColor, ...
%             'Margin', 0.1, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize);
        
        strng = sprintf('%s', cellID);
        MijBigResultsMatrix{i+1,1} = strng;
        strng = sprintf('%s %s', cellSubregion{1}, cellLabel);
        MijBigResultsMatrix{i+1,2} = strng;
        strng = sprintf('%s', plusOrMinus);
        MijBigResultsMatrix{i+1,3} = strng;
        
    end % for i    

    
    % print heavy lines
    DGline = nCells(DG) + 1;
    CA3line = DGline + nCells(CA3);
    CA2line = CA3line + nCells(CA2);
    CA1line = CA2line + nCells(CA1);
    SUBline = CA1line + nCells(SUB);
    %ECline = SUBline + nCells(EC);
    
    if isIncludeUnprintedMarkers_Summary || isIncludePrintedMarkers_Summary
        hLineEnd = nMarkersToPrint + 1;
    else
        hLineEnd = nMarkersToPrint + 2;
    end

    % horizontal lines
    line([hStart*2/3, hLineEnd], [DGline, DGline], 'linewidth', line_width, 'color', [0 0 0])
    line([hStart*2/3, hLineEnd], [CA3line, CA3line], 'linewidth', line_width, 'color', [0 0 0])
    line([hStart*2/3, hLineEnd], [CA2line, CA2line], 'linewidth', line_width, 'color', [0 0 0])
    line([hStart*2/3, hLineEnd], [CA1line, CA1line], 'linewidth', line_width, 'color', [0 0 0])
    line([hStart*2/3, hLineEnd], [SUBline, SUBline], 'linewidth', line_width, 'color', [0 0 0])
    
    if isIncludeAllColTotals
        vEnd = nAllCells+3;
    else
        vEnd = nAllCells+1;
    end
    
    % vertical lines
    line([1, 1], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])
    line([4, 4], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])
    line([18, 18], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])
    line([22, 22], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])
    line([31, 31], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])
    line([34, 34], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])         
    line([36, 36], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])     
    line([38, 38], [vStart+1.5, vEnd], 'linewidth', line_width, 'color', [0 0 0])     
    
    
    % print subregion
    DGstart = 1 + nCells(DG)/2;
    CA3start = 1 + nCells(DG) + nCells(CA3)/2;
    CA2start = 1 + nCells(DG) + nCells(CA3) + nCells(CA2)/2;
    CA1start = 1 + nCells(DG) + nCells(CA3) + nCells(CA2) + nCells(CA1)/2;
    SUBstart = 1 + nCells(DG) + nCells(CA3) + nCells(CA2) + nCells(CA1) + ...
        nCells(SUB)/2;
    ECstart = 1 + nCells(DG) + nCells(CA3) + nCells(CA2) + nCells(CA1) + ...
        nCells(SUB) + nCells(EC)/2;

    if (nCells(DG) ~= 0)
        text(hStart, DGstart+0.3, 'DG', 'HorizontalAlignment', 'center', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold');
    end
    if (nCells(CA3) ~= 0)
        text(hStart, CA3start, 'CA3', 'HorizontalAlignment', 'center', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold');
    end
    if (nCells(CA2) ~= 0)
        text(hStart, CA2start, 'CA2', 'HorizontalAlignment', 'center', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold');
    end
    if (nCells(CA1) ~= 0)
        text(hStart, CA1start, 'CA1', 'HorizontalAlignment', 'center', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold');
    end
    if (nCells(SUB) ~= 0)
        text(hStart, SUBstart, 'SUB', 'HorizontalAlignment', 'center', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold');
    end
    if (nCells(EC) ~= 0)
        text(hStart, ECstart, 'EC', 'HorizontalAlignment', 'center', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold');
    end
    
    
    %% print legend    
    if isPrintLegend
        fprintf(1, '\nPrinting legend...');
        displayFontSize = displayFontSize + 1;
        
        numBoxes = nAllCells*nMarkersToPrint;


        fill([hLegendStart hLegendStart+1 hLegendStart+1 hLegendStart], [1 1 2 2], unknownColor);
        fill([hLegendStart hLegendStart+0.5 hLegendStart], [1 1.5 2], posColor);
        strng = sprintf('positive (%d) [%d unique confirmations]', count_posDE, count_posDE_conf);
        text(hLegendStart+2, 1.5, strng, 'FontSize', displayFontSize, 'Color', 'black');

        fill([hLegendStart hLegendStart+1 hLegendStart+1 hLegendStart], [3 3 4 4], unknownColor);
        fill([hLegendStart+1 hLegendStart+1 hLegendStart+0.5], [3 4 3.5], negColor);
        strng = sprintf('negative (%d) [%d unique confirmations]', count_negDE, count_negDE_conf);
        text(hLegendStart+2, 3.5, strng, 'FontSize', displayFontSize, 'Color', 'black');       
        
        % mixed flag entries                
        fill([hLegendStart hLegendStart+1 hLegendStart+1 hLegendStart], [5 5 6 6], unknownColor);
        fill([hLegendStart hLegendStart+0.5 hLegendStart], [5 5.5 6], posColor);
        fill([hLegendStart+1 hLegendStart+1 hLegendStart+0.5], [5 6 5.5], negColor);
        strng = sprintf('pos & neg (subtypes) (%d)', count_mixedSubtypes);
        text(hLegendStart+2, 5.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
        
        fill([hLegendStart hLegendStart+1 hLegendStart+1 hLegendStart], [7 7 8 8], unknownColor);
        fill([hLegendStart hLegendStart+0.5 hLegendStart+1], [8 7.5 8], mixedColor2);
        strng = sprintf('pos & neg (unresolved) (%d)', count_mixedConflict);
        text(hLegendStart+2, 7.5, strng, 'FontSize', displayFontSize, 'Color', 'black');              
        
        fill([hLegendStart hLegendStart+1 hLegendStart+1 hLegendStart], [9 9 10 10], unknownColor);
        fill([hLegendStart hLegendStart+1 hLegendStart+0.5], [9 9 9.5], mixedColor3);
        strng = sprintf('pos & neg (species/protocol diff) (%d)', count_mixedSpecProt);
        text(hLegendStart+2, 9.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
        
        fill([hLegendStart hLegendStart+1 hLegendStart+1 hLegendStart], [11 11 12 12], unknownColor);
            fill([hLegendStart hLegendStart+1 hLegendStart+0.5], [11 11 11.5], mixedColor4);
        strng = sprintf('pos & neg (subcellular exp diff) (%d)', count_mixedSubcellExp);
        text(hLegendStart+2, 11.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
        
        fill([hLegendStart hLegendStart+1 hLegendStart+1 hLegendStart], [13 13 14 14], questionColor);
        strng = sprintf('feedback/review needed (%.0f)', count_question);
        text(hLegendStart+2, 13.5, strng, 'FontSize', displayFontSize, 'Color', 'black');   
        

        if (isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers)
            strng = sprintf('%d REI rules in database (%d inferences used)', numInfers, sum(infersApplied));
            text(hLegendStart, 20, strng, 'FontSize', displayFontSize, 'Color', 'black');  
            
            strng = sprintf('%d traditional REI applications', numInferApplications);
            text(hLegendStart, 22, strng, 'FontSize', displayFontSize, 'Color', 'black');   
            
                strng = sprintf(' \\bullet %d confirm direct evidence (white dot)', numInferConfirmations);
                text(hLegendStart+2, 24, strng, 'FontSize', displayFontSize, 'Color', 'black');
                
%                 strng = sprintf(' \\bullet %d confirm inferences (white dot)', numInferInferConfirmations);
%                 text(hLegendStart+2, 24, strng, 'FontSize', displayFontSize, 'Color', 'black');

                strng = sprintf(' \\bullet %d lead to black triangles', numInferApplications-numInferConfirmations);
                text(hLegendStart+2, 26, strng, 'FontSize', displayFontSize, 'Color', 'black');            
    
                    strng = sprintf(' \\bullet %d applications would conflict with direct evidence', numPosInferKnownInfoConflicts+numNegInferKnownInfoConflicts);
                    text(hLegendStart+4, 28, strng, 'FontSize', displayFontSize, 'Color', 'black');
                
                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [29 29 30 30], unknownColor);
                        fill([hLegendStart+6 hLegendStart+6.5 hLegendStart+6], [29 29.5 30], posColor);        
                        fill([hLegendStart+7 hLegendStart+7 hLegendStart+6.5], [29 30 29.5], 'k');
                        %plot(hLegendStart+6.8, 29.5, '.k', 'MarkerSize',5);
                        strng = sprintf('positive; would-be negative REI (%d)', count_posDE_negInf);
                        text(hLegendStart+8, 29.5, strng, 'FontSize', displayFontSize, 'Color', 'black');

                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [31 31 32 32], unknownColor);
                        fill([hLegendStart+7 hLegendStart+7 hLegendStart+6.5], [31 32 31.5], negColor);
                        fill([hLegendStart+6 hLegendStart+6.5 hLegendStart+6], [31 31.5 32], 'k');
                        %plot(hLegendStart+6.2, 31.5, '.k', 'MarkerSize',5);                        
                        strng = sprintf('negative; would-be positive REI (%d)', count_posInf_negDE);
                        text(hLegendStart+8, 31.5, strng, 'FontSize', displayFontSize, 'Color', 'black');                        

                    strng = sprintf(' \\bullet %d applications conflict with another REI applied during the same pass', numInferInferConflicts);
                    text(hLegendStart+4, 34, strng, 'FontSize', displayFontSize, 'Color', 'black');      

                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [35 35 36 36], unknownColor);                    
                        fill([hLegendStart+6 hLegendStart+6.5 hLegendStart+7], [36 35.5 36], 'k');
                        strng = sprintf('conflicting REI: unresolved (%d)', numInfInfConflicts_unresolved);
                        text(hLegendStart+8, 35.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
                        
                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [37 37 38 38], unknownColor);
                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+6.5], [37 37 37.5], 'k');                        
                        strng = sprintf('conflicting REI: spec/prot diffs (%d)', numInfInfConflicts_specProt);
                        text(hLegendStart+8, 37.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
                        
                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [39 39 40 40], unknownColor);
                        fill([hLegendStart+6 hLegendStart+6.5 hLegendStart+6], [39 39.5 40], 'k');        
                        fill([hLegendStart+7 hLegendStart+7 hLegendStart+6.5], [39 40 39.5], 'k');
                        strng = sprintf('conflicting REI: subtypes (%d)', numInfInfConflicts_subtypes);
                        text(hLegendStart+8, 39.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
                        
                    strng = sprintf(' \\bullet %d applications conflict with another REI applied during a previous pass', numInferInferConflicts_diffPasses);
                    text(hLegendStart+4, 42, strng, 'FontSize', displayFontSize, 'Color', 'black');
                    
                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [43 43 44 44], unknownColor);
                        fill([hLegendStart+6 hLegendStart+6.5 hLegendStart+6], [43 43.5 44], 'k');        
                        fill([hLegendStart+7 hLegendStart+7 hLegendStart+6.5], [43 44 43.5], 'k');
                        strng = sprintf('conflicting REI: unknown (%d)', numInferInferConflicts_diffPasses/2);
                        text(hLegendStart+8, 43.5, strng, 'FontSize', displayFontSize, 'Color', 'black');

                    strng = sprintf(' \\bullet %d applications provide non-conflicting info', numPosInferNewInfoCases+numNegInferNewInfoCases+numInferInferConfirmations);
                    text(hLegendStart+4, 46, strng, 'FontSize', displayFontSize, 'Color', 'black');

                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [47 47 48 48], unknownColor);
                        fill([hLegendStart+6 hLegendStart+6.5 hLegendStart+6], [47 47.5 48], 'k');
                        strng = sprintf('positive REI (%d) [%d unique confirmations]', count_posInf, count_posInf_conf);
                        text(hLegendStart+8, 47.5, strng, 'FontSize', displayFontSize, 'Color', 'black');

                        fill([hLegendStart+6 hLegendStart+7 hLegendStart+7 hLegendStart+6], [49 49 50 50], unknownColor);
                        fill([hLegendStart+7 hLegendStart+7 hLegendStart+6.5], [49 50 49.5], 'k');
                        strng = sprintf('negative REI (%d) [%d unique confirmations]', count_negInf, count_negInf_conf);
                        text(hLegendStart+8, 49.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
                        
                        
                        
            strng = sprintf('%d correlation-produced REI applications', numPosCorrProdReiCases+numNegCorrProdReiCases);
            text(hLegendStart, 52, strng, 'FontSize', displayFontSize, 'Color', 'black');
    
                fill([hLegendStart+2 hLegendStart+3 hLegendStart+3 hLegendStart+2], [53 53 54 54], unknownColor);
                fill([hLegendStart+2 hLegendStart+2.5 hLegendStart+2], [53 53.5 54], corrREIcolor);
                strng = sprintf('positive corr-prod REI (%d)', numPosCorrProdReiCases);
                text(hLegendStart+4, 53.5, strng, 'FontSize', displayFontSize, 'Color', 'black');

                fill([hLegendStart+2 hLegendStart+3 hLegendStart+3 hLegendStart+2], [55 55 56 56], unknownColor);
                fill([hLegendStart+3 hLegendStart+3 hLegendStart+2.5], [55 56 55.5], corrREIcolor);
                strng = sprintf('negative corr-prod REI (%d)', numNegCorrProdReiCases);
                text(hLegendStart+4, 55.5, strng, 'FontSize', displayFontSize, 'Color', 'black');
                        
        else
            strng = sprintf('[REI toggled off]');
            text(hLegendStart, 18, strng, 'FontSize', displayFontSize, 'Color', 'black');
        end
        
        
        
        % print inference stats by type
%         highPriorityInfOff = 0;
%         triggerWarning = 0;
%             
%         
%         % table row and column headings
%         text(hLegendStart, 56, 'Stats by inference type:', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');   
% 
%         text(hLegendStart+12, 60, 'Total', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%         text(hLegendStart+14.5, 60, 'New', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');    
%         text(hLegendStart+16.5, 60, 'Conflict DE', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%         text(hLegendStart+18.5, 60, 'Conflict Inf', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');             
%         text(hLegendStart+20.5, 60, 'Confirm DE', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%         text(hLegendStart+22.5, 60, 'Confirm Inf', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%         text(hLegendStart+24.5, 60, 'Conflict/Confirm', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%         text(hLegendStart+27, 60, 'On/Off', 'rotation', 90, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
% 
%         % Axons proj-neg
%         text(hLegendStart, 62, 'Axons proj-neg', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%             strng = sprintf('%d', numAxonsProjNegTotal);
%             text(hLegendStart+11.5, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numAxonsProjNegNew);
%             text(hLegendStart+14, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numAxonsProjNegConflict);
%             text(hLegendStart+16, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numAxonsProjNegConflictInf);
%             text(hLegendStart+18, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numAxonsProjNegConfirm);
%             text(hLegendStart+20, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numAxonsProjNegConfirmInf);
%             text(hLegendStart+22, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%0.2f', (numAxonsProjNegConflict+numAxonsProjNegConflictInf)/(numAxonsProjNegConfirm+numAxonsProjNegConfirmInf));
%             text(hLegendStart+24, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             
%             if isIncludeAxonInfers
%                 strng = sprintf('ON');
%             else
%                 strng = sprintf('OFF');
%                 highPriorityInfOff = 1;
%             end
%             text(hLegendStart+26.5, 62, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');        
%         
%         
%         % Layer-neg
%         text(hLegendStart, 64, 'Layer-neg', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%             strng = sprintf('%d', numLayerNegTotal);
%             text(hLegendStart+11.5, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numLayerNegNew);
%             text(hLegendStart+14, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numLayerNegConflict);
%             text(hLegendStart+16, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numLayerNegConflictInf);
%             text(hLegendStart+18, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numLayerNegConfirm);
%             text(hLegendStart+20, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numLayerNegConfirmInf);
%             text(hLegendStart+22, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%0.2f', (numLayerNegConflict+numLayerNegConflictInf)/(numLayerNegConfirm+numLayerNegConfirmInf));
%             text(hLegendStart+24, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             
%             if isIncludeLayerInfers
%                 if highPriorityInfOff
%                     triggerWarning = 1;
%                 end
%                 strng = sprintf('ON');
%             else
%                 strng = sprintf('OFF');
%                 highPriorityInfOff = 1;
%             end
%             text(hLegendStart+26.5, 64, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%         
%         % Pos-pos
%         text(hLegendStart, 66, 'Pos-pos', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%             strng = sprintf('%d', numPosPosTotal);
%             text(hLegendStart+11.5, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numPosPosNew);
%             text(hLegendStart+14, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numPosPosConflict);
%             text(hLegendStart+16, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numPosPosConflictInf);
%             text(hLegendStart+18, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numPosPosConfirm);
%             text(hLegendStart+20, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numPosPosConfirmInf);
%             text(hLegendStart+22, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%0.2f', (numPosPosConflict+numPosPosConflictInf)/(numPosPosConfirm+numPosPosConfirmInf));
%             text(hLegendStart+24, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             
%             if isIncludeProbInfers
%                 strng = sprintf('ON');
%                 if highPriorityInfOff
%                     triggerWarning = 1;
%                 end
%             else
%                 strng = sprintf('OFF');
%                 highPriorityInfOff = 1;
%             end
%             text(hLegendStart+26.5, 66, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
% 
%         % Contra:pos-pos
%         text(hLegendStart, 68, 'Contra:pos-pos', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%             strng = sprintf('%d', numContra_PosPosTotal);
%             text(hLegendStart+11.5, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosPosNew);
%             text(hLegendStart+14, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numContra_PosPosConflict);
%             text(hLegendStart+16, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosPosConflictInf);
%             text(hLegendStart+18, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosPosConfirm);
%             text(hLegendStart+20, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosPosConfirmInf);
%             text(hLegendStart+22, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%0.2f', (numContra_PosPosConflict+numContra_PosPosConflictInf)/(numContra_PosPosConfirm+numContra_PosPosConfirmInf));
%             text(hLegendStart+24, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             
%             if isIncludeProbInfers
%                 strng = sprintf('ON');
%                 if highPriorityInfOff
%                     triggerWarning = 1;
%                 end
%             else
%                 strng = sprintf('OFF');
%                 highPriorityInfOff = 1;
%             end
%             text(hLegendStart+26.5, 68, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%           
%         % Pos-neg
%         text(hLegendStart, 70, 'Pos-neg', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%             strng = sprintf('%d', numPosNegTotal);
%             text(hLegendStart+11.5, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numPosNegNew);
%             text(hLegendStart+14, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numPosNegConflict);
%             text(hLegendStart+16, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numPosNegConflictInf);
%             text(hLegendStart+18, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numPosNegConfirm);
%             text(hLegendStart+20, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numPosNegConfirmInf);
%             text(hLegendStart+22, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%0.2f', (numPosNegConflict+numPosNegConflictInf)/(numPosNegConfirm+numPosNegConfirmInf));
%             text(hLegendStart+24, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             
%             if isIncludeProbInfers
%                 strng = sprintf('ON');
%                 if highPriorityInfOff
%                     triggerWarning = 1;
%                 end
%             else
%                 strng = sprintf('OFF');
%                 highPriorityInfOff = 1;
%             end
%             text(hLegendStart+26.5, 70, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             
% 
%         % Contra:pos-neg
%         text(hLegendStart, 72, 'Contra:pos-neg', 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
% 
%             strng = sprintf('%d', numContra_PosNegTotal);
%             text(hLegendStart+11.5, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosNegNew);
%             text(hLegendStart+14, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');            
%             strng = sprintf('%d', numContra_PosNegConflict);
%             text(hLegendStart+16, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosNegConflictInf);
%             text(hLegendStart+18, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosNegConfirm);
%             text(hLegendStart+20, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%d', numContra_PosNegConfirmInf);
%             text(hLegendStart+22, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             strng = sprintf('%0.2f', (numContra_PosNegConflict+numContra_PosNegConflictInf)/(numContra_PosNegConfirm+numContra_PosNegConfirmInf));
%             text(hLegendStart+24, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%             
%             if isIncludeProbInfers
%                 strng = sprintf('ON');
%                 if highPriorityInfOff
%                     triggerWarning = 1;
%                 end
%             else
%                 strng = sprintf('OFF');
%                 highPriorityInfOff = 1;
%             end
%             text(hLegendStart+26.5, 72, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%         
%         line([hLegendStart+13.75 hLegendStart+13.75],[59 73]);
%         line([hLegendStart+15.75 hLegendStart+15.75],[59 73]);
%         line([hLegendStart+19.75 hLegendStart+19.75],[59 73]);
%         line([hLegendStart+23.75 hLegendStart+23.75],[59 73]);
%         line([hLegendStart+26.25 hLegendStart+26.25],[59 73]);
%             
%         if triggerWarning
%             strng = sprintf('WARNING: higher priority inferences\nturned off; stats may be incorrect');
%             text(hLegendStart, 76, strng, 'FontSize', displayFontSize, 'FontWeight', 'bold', 'Color', 'black');
%         end

        
% leave this block out
%         if isIncludeSpeciesMethods
%             text(60, hLegendStart, 'R = Rat / M = Mouse', 'rotation', 90, ......
%                 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', displayFontSize, ...
%                 'Color', 'k');
%             text(62, hLegendStart, 'i = immuno / g = gene', 'rotation', 90, ......
%                 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', displayFontSize, ...
%                 'Color', 'k');
%         end              
        
    end %if isPrintLegend
    
    
    if isPrintMarkerNameKey
        keyStrng1 = 'CB=calbindin; CR=calretinin; PV=parvalbumin; CB1=cannabinoid receptor type 1;';
        keyStrng2 = 'Mus2R=Muscarinic type 2 receptor; sub P rec=substance P rec; 5HT-3=5HT-3 receptor;';
        keyStrng3 = 'vGluT3=vesicular glutamate transporter 2; CCK=cholecystokinin; ENK=enkephalin;';
        keyStrng4 = 'NPY=neuropeptide Y; SOM=somatostatin; VIP=vasoactive intestinal polypeptide;';
        keyStrng5 = 'a-act2=alpha actinin 2; CoupTF II=chicken ovalbumin upstream promoter transcription factor II;';
        keyStrng6 = 'nNOS=neuronal nitric oxide synthase; RLN=reelin';
                    
        text(nAllCells+2, hEnd, keyStrng, ......
            'rotation', 90, 'HorizontalAlignment', 'left', 'FontSize', displayFontSize-1);
    end
    
    
    %% Add title and status bar to top %%
    isPrintStatusBar = 0;
    if isPrintStatusBar
        strng = sprintf('Hippocampome %s\n', hippocampomeVersion);
        text(hStart, vStart+1, strng, 'FontSize', displayFontSize+1);
        strng = sprintf('%d cell types', nAllCells);
        text(hStart, vStart+2, strng, 'FontSize', displayFontSize);
        strng = sprintf('%d markers', nMarkersToPrint);
        text(hStart, vStart+3, strng, 'FontSize', displayFontSize);

        strng = sprintf('%s', date);
        text(hEnd-1, vStart+1, strng, 'HorizontalAlignment', 'right', 'FontSize', displayFontSize);
    end %if isPrintLegend

    
    %% export figure
    if isExportFigure
        fprintf(1, '\nExporting figure...');
        
        if isIncludeUntrackedMarkers_All
            howManyMarkers = 'all';
        elseif isIncludeOnlyOfficialMarkersAndMarkersWithInfs
            howManyMarkers = '32';
        else
            howManyMarkers = '';
        end

    %     plotFileName = sprintf('./_mij_plot_output/Mij_matrix_%s_%s.eps', howManyMarkers, datestr(now, 'yyyymmdd_HHMMSS'));
    %     print(gcf, '-depsc', '-r800', plotFileName);    

        plotFileNameTIF = sprintf('./_mij_plot_output/Mij_matrix_%s_%s.tif', howManyMarkers, datestr(now, 'yyyymmdd_HHMMSS'));
        set(gcf, 'Renderer', 'ZBuffer')    
        print(gcf, '-dtiff', '-r800', plotFileNameTIF);
    end
    
    close(gcf);
    

    %% export DE/INF hybrid spreadsheet
    fprintf(1, '\nExporting DE/INF hybrid spreadsheet...');

    if isOutputHybridSheet
        
        typeMatrix = cell2mat(infApplicationMatrix(:,1));
        markerMatrix = cell2mat(infApplicationMatrix(:,2));
        activeTypeCounter = 0;

        for row = (rowSkip+1):size(cellsMarkers,1)
            if cellsMarkers{row,classStatusColNum} == 'N'
                activeTypeCounter = activeTypeCounter + 1;
            
                markerCounter = 0;
                for col = (colSkip+1):size(cellsMarkers,2)
                    markerCounter = markerCounter + 1;

                    applicationMatrixRowsToAdd = find(typeMatrix==activeTypeCounter & markerMatrix==markerCounter);

                    if ~isempty(applicationMatrixRowsToAdd)
                        infApplicationMiniMatrix = infApplicationMatrix(applicationMatrixRowsToAdd,:);
                        infApplicationMiniMatrix = sortrows(infApplicationMiniMatrix, 4);
                        
                        addedNegInf = 0;
                        addedPosInf = 0;
                        addedNegCorProdREI = 0;
                        addedPosCorProdREI = 0;

                        cellsMarkers{row,col} = cellsMarkers{row,col}(1:end-1); % trim off trailing quotation mark

                        for i = 1:size(applicationMatrixRowsToAdd,1)
                            curInf = infApplicationMiniMatrix{i,3};
                            curInfExprCode = num2str(infApplicationMiniMatrix{i,4});
                            
                            if strcmp(curInfExprCode,num2str(negInfCode))
                                addedNegInf = 1;
                            elseif strcmp(curInfExprCode,num2str(posInfCode))
                                addedPosInf = 1;
                            elseif strcmp(curInfExprCode,num2str(contraPosPos_negInf_Code))
                                curInfExprCode = num2str(negInfCode);
                                addedNegInf = 1;
                            elseif strcmp(curInfExprCode,num2str(contraPosNeg_negInf_Code))
                                curInfExprCode = num2str(negInfCode);
                                addedNegInf = 1;
                            elseif strcmp(curInfExprCode,num2str(negCorProdREI_negInf_Code))
                                curInfExprCode = num2str(negInfCode);
                                addedNegCorProdREI = 1;
                            elseif strcmp(curInfExprCode,num2str(posCorProdREI_posInf_Code))
                                curInfExprCode = num2str(posInfCode);
                                addedPosCorProdREI = 1;
                            end

                            infIdx = find(infers_inferNum==curInf);
                            infIdx = infIdx(1);

                            curInfProtocolCode = infers_protocol{infIdx};
                            curInfSpeciesCode = infers_species{infIdx};
                            curInfRefIDs = infers_refIDs{infIdx};
                            curInfRefIDs = strsplit(curInfRefIDs, ';');
                            
                            curReasonText = infApplicationMiniMatrix{i,5};
                                                        
                            curCPint = infers_ClopPearConfid{infIdx};                            
                            curN = infers_n{infIdx};
                            curPercentTrue = infers_percentTrue(infIdx);                                                        
                            
                            if ~isnumeric(curN) || ~isnumeric(curCPint)
                                curNote = curReasonText;
                            else
                                curNumerator = round(curPercentTrue*curN/100);
                                
                                %curNtext = ['inference true in ' num2str(round(curCPint,1)) '% of cases (n=' num2str(curN) ')'];
                                
                                if curCPint >= threshValuePct
                                    curNtext = ['Clopper-Pearson confidence interval lower bound = ' num2str(round(curCPint,1)) '% (n = ' num2str(curNumerator) '/' num2str(curN) ')'];
                                else
                                    curNtext = ['(n = ' num2str(curNumerator) '/' num2str(curN) ')'];
                                end
                                    
                                curNote = [curReasonText '; ' curNtext];
                            end

                            % if multiple refIDs for an inf, add each
                            for s=1:length(curInfRefIDs)
                                curInfToAdd = [curInfExprCode curInfProtocolCode curInfSpeciesCode '.' strtrim(curInfRefIDs{s}) '<"*' curNote '*">'];
                                                                
                                if ~isnan(cellsMarkers{row,col})
                                    if isempty(strfind(cellsMarkers{row,col}, curInfToAdd))
                                        if strcmp(cellsMarkers{row,col},'000.000000')
                                            cellsMarkers{row,col} = ['{}' curInfToAdd];
                                        else
                                            cellsMarkers{row,col} = [cellsMarkers{row,col} '; ' curInfToAdd];
                                        end
                                    end
                                else
                                    cellsMarkers{row,col} = ['{} "' curInfToAdd];
                                end
                                
                            end                        

                        end                                        

                        cellsMarkers{row,col} = [cellsMarkers{row,col} '"'];
                        cellsMarkers{row,col} = strrep(cellsMarkers{row,col},'"','""');

                        % recalculate curly brace codes
                        confirmedWithPosInf = MijInferApplicationsConfirmPos(activeTypeCounter,markerCounter);
                        confirmedWithNegInf = MijInferApplicationsConfirmNeg(activeTypeCounter,markerCounter);
                        [cellsMarkers{row,col}, infConflict] = recalculateCurlyBraceCodes(cellsMarkers{row,col}, addedPosInf, addedNegInf, addedPosCorProdREI, addedNegCorProdREI, confirmedWithPosInf, confirmedWithNegInf);                        
                        if infConflict
                            idFromSpreadsheet = cellsMarkers{row,uniqueIdColNum};
                            idFromSpreadsheet = strrep(idFromSpreadsheet, '-', '');
                            thisTypeNum = find(strcmp(idFromSpreadsheet, cellUniqueIDsMarkers));

                            thisMarkerNum = find(strcmp(cellsMarkers{markerNamesRowNum,col}, markerLabels));
                            cellsMarkers{row,col} = recalculateInfConflictCurlyBraceCodes(cellsMarkers{row,col}, thisTypeNum, thisMarkerNum);
                        end


                    elseif ischar(cellsMarkers{row,col})
                        cellsMarkers{row,col} = strrep(cellsMarkers{row,col},'"','""');

                    elseif isnumeric(cellsMarkers{row,col})

                    else %isnan

                    end               
                end % for col
            end % if cellsMarkers() == 'N'
        end % for row


        outputFileName = sprintf('./_mij_plot_output/Hippocampome-Markers_DE-INF_%s.csv', datestr(now, 'yyyymmdd_HHMMSS'));
        cell2csv_clr(outputFileName, cellsMarkers, ',', 2016, '.')
    end

    
    %% save BigResultsMatrix
    emptyIndex = cellfun(@isempty,MijBigResultsMatrix);
    MijBigResultsMatrix(emptyIndex) = {''};
    
    save MijBigResultsMatrix.mat MijBigResultsMatrix
    
    
end % plot_markers






function color = getColorFromLevel(level, posColor, wkPosColor, negColor, noInfoColor, unknownColor)

    switch (level)
        case -1
            color = noInfoColor;
        case 0
            color = unknownColor;
        case 1
            color = posColor;
        case 2
            color = negColor;
        case 3
            color = wkPosColor;
        otherwise
            color = [0 1 0];
    end
end
   

function idx = levelToBoxIdx(level)
    
    switch (level)
        case -1
            idx = 1;
        case 0
            idx = 2;
        case 1
            idx = 3;
        case 2
            idx = 4;
        case 3
            idx = 5;
        otherwise
            idx = -1;
    end
end



function infConflictCode = determineInfInfConflictSrc(thisTypeNum, thisMarkerNum)
    load mij.mat cellUniqueIDsMarkers markerLabels
    thisTypeID = strrep(cellUniqueIDsMarkers{thisTypeNum}, '-', '');
    thisMarkerName = markerLabels{thisMarkerNum};

    infConflictCode = readConflictLog(thisTypeID, thisMarkerName);
end



function [newCellText, infConflict] = recalculateCurlyBraceCodes(oldCellText, addedPosInf, addedNegInf, addedPosCorProdREI, addedNegCorProdREI, confirmedWithPosInf, confirmedWithNegInf)
    overwriteMixedDE_inf = 1;
    
    infConflict = 0;
    
    % recalculate curly braces
    curlyOpenIdx = strfind(oldCellText, '{');
    curlyCloseIdx = strfind(oldCellText, '}');

    if ~isempty(curlyOpenIdx) && ~isempty(curlyCloseIdx)
        braceTxt = oldCellText(curlyOpenIdx+1:curlyCloseIdx-1);
        newBraceTxt = braceTxt;

        if isempty(braceTxt)
            if addedPosInf && addedNegInf
                newBraceTxt = 'pi,ni';
            elseif addedPosInf
                if confirmedWithPosInf
                    newBraceTxt = 'cpi';
                else
                    newBraceTxt = 'pi';
                end
            elseif addedNegInf
                if confirmedWithNegInf
                    newBraceTxt = 'cni';
                else
                    newBraceTxt = 'ni';
                end
            elseif addedPosCorProdREI && addedNegCorProdREI
                newBraceTxt = 'pcor,ncor';
            elseif addedPosCorProdREI
                newBraceTxt = 'pcor';
            elseif addedNegCorProdREI
                newBraceTxt = 'ncor';
            end
        else
            switch(braceTxt)
                case 'p'
                    if addedNegInf
                        if overwriteMixedDE_inf
                            if confirmedWithPosInf
                                newBraceTxt = 'cp';
                            else
                                newBraceTxt = 'p';
                            end
                        else
                            newBraceTxt = 'p,ni';
                        end
                    end
                    if confirmedWithPosInf
                        newBraceTxt = 'cp';
                    end
                case 'n'
                    if addedPosInf
                        if overwriteMixedDE_inf
                            if confirmedWithNegInf
                                newBraceTxt = 'cn';
                            else
                                newBraceTxt = 'n';
                            end
                        else
                            newBraceTxt = 'pi,n';
                        end
                    end
                    if confirmedWithNegInf
                        newBraceTxt = 'cn';
                    end
                    
                case 'pi'
                    if addedNegInf
                        newBraceTxt = 'pi,ni';
                    elseif confirmedWithPosInf
                        newBraceTxt = 'cpi';
                    end
                case 'ni'
                    if addedPosInf
                        newBraceTxt = 'pi,ni';
                    elseif confirmedWithNegInf
                        newBraceTxt = 'cni';
                    end
                    
                case 'pi,ni'
                    % do nothing
                case 'a'
                    % do nothing
                case 'b'
                    % do nothing
                case 'p,ni'
                    % do nothing
                case 'pi,n'
                    % do nothing
                case 'pcor'
                    % do nothing
                case 'ncor'
                    % do nothing
                case 'pcor,ncor'
                    % do nothing
                case 'acor'
                    % do nothing
                case 'bcor'
                    % do nothing
                otherwise
                    % do nothing
            end
        end

        if strcmp(newBraceTxt, 'pi,ni')
            infConflict = 1;
        end
        
        newCellText = [oldCellText(1:curlyOpenIdx) newBraceTxt oldCellText(curlyCloseIdx:end)];
    else % if curly braces not found
        if addedPosInf && addedNegInf
            newCellText = ['{pi,ni}' oldCellText];
            infConflict = 1;
        elseif addedPosInf
            if confirmedWithPosInf
                newCellText = ['{cpi}' oldCellText];
            else
                newCellText = ['{pi}' oldCellText];
            end
        elseif addedNegInf
            if confirmedWithNegInf
                newCellText = ['{cni}' oldCellText];
            else
                newCellText = ['{ni}' oldCellText];
            end
        elseif addedPosCorProdREI && addedNegCorProdREI
            newCellText = ['{pcor,ncor}' oldCellText];
        elseif addedPosCorProdREI
            newCellText = ['{pcor}' oldCellText];
        elseif addedNegCorProdREI
            newCellText = ['{ncor}' oldCellText];
        else
            newCellText = oldCellText;
        end
    end
end


function newCellText = recalculateInfConflictCurlyBraceCodes(oldCellText, thisTypeNum, thisMarkerNum)
    infConflictCode = determineInfInfConflictSrc(thisTypeNum, thisMarkerNum);
    newCellText = strrep(oldCellText, '{pi,ni}', infConflictCode);
end