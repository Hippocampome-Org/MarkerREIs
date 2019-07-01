function [reply] = menu_markers(csvFileName, cellsMarkers, somataLoaded, infersLoaded)

    load mij.mat
    load markerToggles
    
    %if isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers
        load infers.mat
    %end
    
    isIncludeBrackets = 0;
    isIncludeSpeciesMethods = 1;
    isIncludeSubclassDivisionLines = 0;
    isExportFigure = 1;
    isPrintLegend = 1;
    isPrintMarkerNameKey = 0;
    isInferLog = 1;
    isOutputHybridSheet = 0;
    threshValuePct = '66.7';
    confidMetric = 'Clopper-Pearson';
    isUseOkayInfs = 1;
    isChainInfs = 1;
    isNoMixedAtK_1Pass = 1;
    isAllowInfOnSubtypes = 0;
    isOverrideMixedLaterPass = 1;
    isColorCorrProdREIDifferently = 1;
        
    save isIncludeMarkers.mat isIncludeBrackets isPrintMarkerNameKey isIncludeSpeciesMethods isIncludeSubclassDivisionLines isExportFigure isPrintLegend isInferLog isOutputHybridSheet threshValuePct confidMetric isUseOkayInfs isChainInfs isNoMixedAtK_1Pass isAllowInfOnSubtypes isOverrideMixedLaterPass isColorCorrProdREIDifferently
    reply = [];
    
    % main loop to display menu choices and accept input
    % terminates when user chooses to exit
    while (isempty(reply))
        %% display menu %%
        clc;
        save isIncludeMarkers.mat isIncludeBrackets isPrintMarkerNameKey isIncludeSpeciesMethods isIncludeSubclassDivisionLines isExportFigure isPrintLegend isInferLog isOutputHybridSheet threshValuePct confidMetric isUseOkayInfs isChainInfs isNoMixedAtK_1Pass isAllowInfOnSubtypes isOverrideMixedLaterPass isColorCorrProdREIDifferently
        
        strng = sprintf('Current csv file is: %s\n', csvFileName);
        disp(strng);
        strng = sprintf('Markers - MAIN MENU\n');
        disp(strng);
        strng = sprintf('Select from the options below:\n');
        disp(strng);    
    
        
        strng = sprintf('    P) Plot markers matrix\n');
        disp(strng);        
        
        
        strng = sprintf('    0) Export figure as .tif: %s', bin2str(isExportFigure));
        disp(strng);

        strng = sprintf('    1) Print legend: %s', bin2str(isPrintLegend));
        disp(strng);
        
        if isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers
            strng = sprintf('    2) Toggle creation of marker inference log: %s', bin2str(isInferLog));
            disp(strng);                
        end

        strng = sprintf('    3) Toggle output of DE/INF hybrid spreadsheet: %s', bin2str(isOutputHybridSheet));
        disp(strng);
        
        
        
        strng = sprintf('\n    c1) Switch confidence metric (currently: %s)', confidMetric);
        disp(strng);
        
        strng = sprintf('    c2) Update confidence threshold (currently: %s%%)', threshValuePct);
        disp(strng);
        
        strng = sprintf('    c3) Use inferences with "okay" n: %s', bin2str(isUseOkayInfs));
        disp(strng);
        
        strng = sprintf('    c4) Chain inferences together (allow multiple passes): %s', bin2str(isChainInfs));
        disp(strng);
        
        strng = sprintf('    c5) Block chaining if mixed at (k-1) pass: %s', bin2str(isNoMixedAtK_1Pass));
        disp(strng);
        
        strng = sprintf('    c6) Allow inferences to act on subtypes: %s', bin2str(isAllowInfOnSubtypes));
        disp(strng); 
        
        strng = sprintf('    c7) Override mixed flags from later passes: %s', bin2str(isOverrideMixedLaterPass));
        disp(strng); 
        
        strng = sprintf('    c8) Color correlation-produced REIs differently: %s', bin2str(isColorCorrProdREIDifferently));
        disp(strng); 
        
       
        strng = sprintf('\n    B) Back to top menu');
        disp(strng);
        disp('    !) Exit');
        
        
        %% process input %%
        
        reply = lower(input('\nYour selection: ', 's'));

        switch reply
                             
            case 'p'
                plot_markers(cellsMarkers, somataLoaded, infersLoaded);                
                reply = [];    
                
            
                
            case '0'               
                isExportFigure = ~isExportFigure;
                reply = [];   
            
            case '1'               
                isPrintLegend = ~isPrintLegend;
                reply = [];   

            case '2'
                if isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers
                    isInferLog = ~isInferLog;
                end
                reply = [];

            case '3'        
                isOutputHybridSheet = ~isOutputHybridSheet;
                reply = [];
                
                
            case 'c1'
                if (strcmp(confidMetric, 'Binomial dist'))
                    confidMetric = 'Clopper-Pearson';
                elseif (strcmp(confidMetric, 'Clopper-Pearson'))
                    confidMetric = 'Binomial dist';
                end
                reply = [];
                
            case 'c2'
                threshValuePct = input('\nNew threshold value: ', 's');
                reply = [];
                
            case 'c3'
                isUseOkayInfs = ~isUseOkayInfs;
                reply = [];
                
            case 'c4'
                isChainInfs = ~isChainInfs;
                reply = [];
                
            case 'c5'
                isNoMixedAtK_1Pass = ~isNoMixedAtK_1Pass;
                reply = [];                
                
            case 'c6'
                isAllowInfOnSubtypes = ~isAllowInfOnSubtypes;
                reply = [];
                
            case 'c7'
                isOverrideMixedLaterPass = ~isOverrideMixedLaterPass;
                reply = []; 
                
            case 'c8'
                isColorCorrProdREIDifferently = ~isColorCorrProdREIDifferently;
                reply = [];
                
                                                
                

%             case 'u'
%                 if isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers
%                     disp('')
%                     replyUpdateN = [];
%                     replyUpdatePercentage = [];
%                     while isempty(replyUpdateN)
%                         replyUpdateN = inputdlg('n values: enter a list of numbers separated by spaces or commas');
%                         numbersN = str2num(replyUpdateN{1});
%                         numbersN = numbersN';
%                         replyUpdatePercentage = inputdlg('Corresponding percentages: enter a list of numbers separated by spaces or commas');
%                         numbersPercentages = str2num(replyUpdatePercentage{1});
%                         numbersPercentages = numbersPercentages';
%                         
%                         if length(numbersN) == length(numbersPercentages)
%                             nThresholdVector = numbersN;
%                             percentageThresholdVector = numbersPercentages;
%                             save new_infers_thresholds.mat nThresholdVector percentageThresholdVector
%                         else
%                             fprintf(1, 'Vector lengths did not match.  Please try again.\n');
%                             pause
%                             replyUpdateN = [];
%                             replyUpdatePercentage = [];
%                         end
%                     end
%                 end
%                 reply = [];    
% 
%             case 'u1'
%                 if isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers
%                     disp('')
%                     replyUpdate = [];
%                     while isempty(replyUpdate)
%                         replyUpdate = lower(input('\nEnter a value between 0 and 100: ', 's'));
%                         replyUpdate = str2double(replyUpdate);
%                         if (replyUpdate >= 0) && (replyUpdate <= 100)
%                             probNegThresh = replyUpdate;
%                             save new_infers_thresholds.mat probNegThresh probPosThresh
%                         else
%                             replyUpdate = [];
%                         end
%                     end
%                 end
%                 reply = [];    
%                 
%             case 'u2'
%                 if isIncludeProbInfers || isIncludeLayerInfers || isIncludeAxonInfers
%                     disp('')
%                     replyUpdate = [];
%                     while isempty(replyUpdate)
%                         replyUpdate = lower(input('\nEnter a value between 0 and 100: ', 's'));
%                         replyUpdate = str2double(replyUpdate);
%                         if (replyUpdate >= 0) && (replyUpdate <= 100)
%                             probPosThresh = replyUpdate;
%                             save new_infers_thresholds.mat probNegThresh probPosThresh
%                         else
%                             replyUpdate = [];
%                         end
%                     end
%                 end
%                 reply = []; 
                
                
            case 'b'
                % exit

            case '!'
                % exit
                
            otherwise
                reply = [];
                
        end % switch
        
    end % while loop
    
end % menu_plot

