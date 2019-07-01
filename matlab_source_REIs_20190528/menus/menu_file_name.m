function [fileName, reply] = menu_file_name(HippFileNames)
% modified 20100917 by Diek W. Wheeler, Ph.D

    deleteIndices = zeros(length(HippFileNames),1);
    for i=1:length(HippFileNames)
        if strfind(HippFileNames{i}, '~')
            deleteIndices(i) = 1;
        end
    end
    
    deleteIndices = ismember(deleteIndices, 1)==1;
    HippFileNames(deleteIndices) = [];
    
    nCsvFileNames = length(HippFileNames);


    reply = [];
    
    % main loop to display menu choices and accept input
    % terminates when user chooses to exit
    while (isempty(reply))
        %% display menu %%
        
        clc;
        
        strng = sprintf('Please select a csv file from the selections below.');
        disp(strng);

        for i = 1:nCsvFileNames
            strng = sprintf('    %d) %s', i, HippFileNames{i});
            disp(strng);
        end % for i
        
        disp('    @) Use UI to select file');
        disp('    !) Exit');
        
        reply = input('\nYour selection: ', 's');

        
        %% process input %%
        
        num = str2double(reply);

        if num <= nCsvFileNames
            fileName = HippFileNames{num};             
        
        else
            switch reply               
                case '@'
                    [fileName filePath] = uigetfile( '*.csv', 'Select CSV file' );
                    
                    if isequal(fileName, 0)
                        disp(' !! NO VALID CSV FILE SELECTED !! ');
                        pause
                        reply = [];

                    else
                        dotLocats = strfind(fileName, '.');
                        extension = fileName(dotLocats(end):length(fileName));
                        
                        if ~(isequal(extension, '.csv') || isequal(extension, '.xls') || isequal(extension, '.xlsx'))
                            disp(' !! PLEASE SELECT A FILE WITH .csv, .xls, or .xlsx EXTENSION !! ');
                            pause
                            reply = [];
                        end
                        
                    end
                    
                case '!'
                    fileName = '';
                    
                otherwise
                    reply = [];
                
            end % switch
        end % if num

    end % while loop
    
end % menu_file_name