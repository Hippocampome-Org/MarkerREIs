% This function defines the entry point for the program.
% As such, it displays a text-based menu, accepts input
% from the user, and calls the appropriate function.

function run()
    clear all;
    profile on

    path(path,'./menus/');
    path(path,'./plot_functions/');
        
    csvHippFileNames = dir('*.csv');
    nCsvHippFileNames = length(csvHippFileNames);
    for i=1:nCsvHippFileNames
        allHippFileNames{i,1} = csvHippFileNames(i).name;
    end
        
    xlsHippFileNames = dir('*.xls*');
    nXlsHippFileNames = length(xlsHippFileNames);
    for i=1:nXlsHippFileNames
        allHippFileNames{i+nCsvHippFileNames,1} = xlsHippFileNames(i).name;
    end
    
    nAllHippFileNames = length(allHippFileNames);
 
    if (nAllHippFileNames == 1)
        fileName = allHippFileNames{1};
    elseif (nAllHippFileNames > 1)
        [fileName, reply] = menu_file_name(allHippFileNames);
        if strcmp(reply, '!')
            return
        end
    end

    
    isIncludeBrackets = 0;
    isInterpretMarkerCallsManually = 0;   
    isIncludePrintedMarkers_Summary = 0;
    isIncludeUnprintedMarkers_Summary = 1;
    isIncludeOnlyOfficialMarkersAndMarkersWithInfs = 0;
    isIncludeUntrackedMarkers_All = 1;
    isIncludeAllColTotals = 0;    
    isIncludeSomata = 1;
    isIncludeProbInfers = 1;
    isIncludeLayerInfers = 1;
    isIncludeAxonInfers = 1;
    isCalcConfidStats = 0;
    isPrintAllActiveRows = 1;
    isPrintOnlyRowsWithInfs = 0;
    isPrintDataSubset1 = 0;
    isPrintDataSubset2 = 0;
    isPrintDataSubset3 = 0;
    isPrintDataSubset4 = 0;
    

    reply = [];
    
    % main loop to display menu choices and accept input
    % terminates when user chooses to exit
    while (isempty(reply))
        %% display menu %%
        
        clc;
        
        strng = sprintf('Current file is: %s\n', fileName);
        disp(strng);
        
        strng = sprintf('TOP MENU\n');
        disp(strng);
        
        strng = sprintf('Please enter a selection from the menu below ');
        strng = sprintf('%s(current values in parentheses): \n', strng);
        disp(strng);
        
        disp('    M) Load markers data (unloaded)');
        
   
        strng = sprintf('\n    L) Load a different csv file (');
        strng = sprintf('%s%s', strng, deblank(fileName));
        strng = sprintf('%s)', strng);
        disp(strng);
        
        disp('    !) Exit');
        
                
        %% process input %%
        
        reply = lower(input('\nYour selection: ', 's'));

        switch reply

            case 'm'
                [cellsMarkers, isFileLoaded] = load_csvFile(fileName);
                if isFileLoaded
                    save 'markerToggles' isIncludeBrackets isInterpretMarkerCallsManually isIncludePrintedMarkers_Summary ...
                        isIncludeUnprintedMarkers_Summary isIncludeUntrackedMarkers_All isIncludeOnlyOfficialMarkersAndMarkersWithInfs isIncludeAllColTotals ...
                        isIncludeSomata isIncludeProbInfers isIncludeLayerInfers isIncludeAxonInfers isCalcConfidStats ...
                        isPrintAllActiveRows isPrintOnlyRowsWithInfs isPrintDataSubset1 isPrintDataSubset2 isPrintDataSubset3 isPrintDataSubset4
                    
                    somataLoaded = 0;
                    
                    [somataFileName, infersFileName] = current_marker_data(cellsMarkers);
                    
                    fprintf(1, '\nLoading marker data ...')
                    cells2mij(cellsMarkers, somataLoaded);
                                                            
                    
                    if isIncludeSomata
                        fprintf(1, '\nLoading soma information ...')
                        [somataFile, isSomataFileLoaded] = load_csvFile(somataFileName);
                        
                        if isSomataFileLoaded
                            current_soma_data();
                            somataLoaded = cells2sij(somataFile);
                        else
                            somataLoaded = 0;
                            disp('\n***Warning: somata file not loaded!');
                            pause
                        end
                    else
                        somataLoaded = 0;
                    end                    
                    
                    if ~somataLoaded
                        disp('\n***Warning: somata file not loaded.  Unable to use inferences!');
                        infersLoaded = 0;
                    else
                        fprintf(1, '\nLoading inference information ...')
                        [infersFile, isInfersFileLoaded] = load_csvFile(infersFileName);
                        if isInfersFileLoaded
                            current_infers_data();
                            [nRows, nCols] = size(infersFile);
                            infersLoaded = cells2infers(nRows, infersFileName);
                        else
                            infersLoaded = 0;
                            disp('\n***Warning: inferences file not loaded!');
                            pause
                        end      
                    end
                    
                    
                    reply = menu_markers(fileName, cellsMarkers, somataLoaded, infersLoaded);
                    
                    if ~strcmp(reply, '!')
                        reply = [];
                    end
                else
                    disp('Error: file not loaded!');      
                    reply = [];
                end
                                                             
                


                
            case 'l'
                csvHippFileNames = dir('*.csv');
                nCsvHippFileNames = length(csvHippFileNames);
                for i=1:nCsvHippFileNames
                    allHippFileNames{i,1} = csvHippFileNames(i).name;
                end

                xlsHippFileNames = dir('*.xls*');
                nXlsHippFileNames = length(xlsHippFileNames);
                for i=1:nXlsHippFileNames
                    allHippFileNames{i+nCsvHippFileNames,1} = xlsHippFileNames(i).name;
                end
                
                [fileName, reply] = menu_file_name(allHippFileNames);
                if ~strcmp(reply, '!')
                    reply = [];
                end
                
            case 'b'
                reply = [];
                
            % exit; save profile
            case '$'
                p = profile('info');
                profsave(p,'profile_results');
                
            % exit; don't save profile
            case '!'
                %exit
                
            otherwise
                reply = [];
        
        end % switch
        
    end % while loop
    
    clean_exit()% exit
    
end % run


function clean_exit()
    %% For record keeping, display in the command window the version of
    %   MATLAB being run.
    
    strng = sprintf('\nMATLAB Version %s.\nFinis.\n', version);
    disp(strng);
    clear
end