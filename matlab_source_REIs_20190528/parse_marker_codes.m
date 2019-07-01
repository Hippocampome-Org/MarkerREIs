function [info, tilde, curly, numLevels, markerLevel, markerMethod, markerSpecies, mixedFlagCode] = parse_marker_codes(strng)

    if isnan(strng)
        info = 0;
        tilde = 0;
        curly = 'o';
        numLevels = 0;
        markerLevel = 'z';
        markerMethod = 'z';
        markerSpecies = 'z';
        mixedFlagCode = 0;
        
    else
        load markerToggles

        info = 0;

        if find(strng == '~')
            tilde = 1;
        else
            tilde = 0;
        end

        if (~isempty(strfind(strng, '{p}')) || ~isempty(strfind(strng, '{p<')))
            hasCurlyBraceInterp = 1;
            info = 1;
            numLevels = 1;
            markerLevel = 1;
            mixedFlagCode = 0;
            curly = 'p';
        elseif (~isempty(strfind(strng, '{n}')) || ~isempty(strfind(strng, '{n<')))
            hasCurlyBraceInterp = 1;
            info = 1;
            numLevels = 1;
            markerLevel = 2;
            mixedFlagCode = 0;
            curly = 'n';
        elseif (~isempty(strfind(strng, '{1}')) || ~isempty(strfind(strng, '{1<')))
            hasCurlyBraceInterp = 1;
            info = 1;
            numLevels = 2;
            markerLevel = {[1 2]};        
            mixedFlagCode = 1;
            curly = 's';
        elseif (~isempty(strfind(strng, '{2}')) || ~isempty(strfind(strng, '{2<')))
            hasCurlyBraceInterp = 1;
            info = 1;
            numLevels = 2;
            markerLevel = {[1 2]};
            mixedFlagCode = 2;
            curly = 'u';
        elseif (~isempty(strfind(strng, '{3}')) || ~isempty(strfind(strng, '{3<')))
            hasCurlyBraceInterp = 1;
            info = 1;
            numLevels = 2;
            markerLevel = {[1 2]};
            mixedFlagCode = 3;
            curly = 'd';
        elseif (~isempty(strfind(strng, '{4}')) || ~isempty(strfind(strng, '{4<')))
            hasCurlyBraceInterp = 1;
            info = 1;
            numLevels = 2;
            markerLevel = {[1 2]};
            mixedFlagCode = 4;
            curly = 'e';
        elseif strfind(strng, '{?}')
            hasCurlyBraceInterp = 1;
            info = 1;
            numLevels = 1;
            markerLevel = -2;
            mixedFlagCode = 0;
            curly = 'o';
        elseif strfind(strng, '{}')
            hasCurlyBraceInterp = 0;
            mixedFlagCode = 0;
            curly = 'o';
        else
            hasCurlyBraceInterp = 0;
            mixedFlagCode = 0;
            curly = 'o';
        end


        if  ~hasCurlyBraceInterp || isInterpretMarkerCallsManually

            idx = find(strng == '.');

            nPeriods = length(idx);
            levels = zeros(1,nPeriods);
            methods = zeros(1,nPeriods);
            species = zeros(1,nPeriods);
            allRefIDandNotes = cell(1,nPeriods);

            for i = 1:nPeriods
                % check for missing level, method, or species info
                if idx(i) < 4
                    levels(i) = 9;
                    methods(i) = 9;
                    species(i) = 9;
                else
                    LMSinfo = strng(idx(i)-3:idx(i)-1);
                    if (numel(str2double(LMSinfo)) > 1) || ~isempty(find(LMSinfo == ';', 1))
                        levels(i) = 9;
                        methods(i) = 9;
                        species(i) = 9;
                    end
                end

                % check for wildcard/placeholder level, method, or series info
                if strcmp(LMSinfo(1),'?')
                    LMSinfo(1) = '0';
                end
                if strcmp(LMSinfo(2),'?')
                    LMSinfo(2) = '3';
                end
                if strcmp(LMSinfo(3),'?')
                    LMSinfo(3) = '3';
                end

                % pull out the ref ID and any notes from this reference
                if i < nPeriods
                    RefIDandNotes = strng(idx(i)+1:idx(i+1)-6);
                else
                    RefIDandNotes = strng(idx(i)+1:length(strng));
                end


                if isempty(find(RefIDandNotes == '[', 1)) || isIncludeBrackets
                    levels(i) = str2double(LMSinfo(1));

                    if ((levels(i)==4) || (levels(i)==5)) %if conflicting reports or +/- mix, add both 1 and 2 to levels variable
                        levels(i) = 1;
                        levels(nPeriods+1) = 2;
                    end

                    method = str2double(LMSinfo(2));
                    if isempty(method)
                        methods(i) = -1;
                    else
                        methods(i) = method;
                    end

                    specie = str2double(LMSinfo(3));
                    if isempty(specie)
                        species(i) = -1;
                    else
                        species(i) = specie;
                    end

                    allRefIDandNotes{i} = RefIDandNotes;

                else
                    levels(i) = 9;
                    methods(i) = 9;
                    species(i) = 9;
                end

                idx = find(strng == '.');
                nPeriods = length(idx);
            end % for i 



            levels(levels==9) = [];
            methods(methods==9) = [];
            species(species==9) = [];

            numLevels = length(unique(levels));

            if (numLevels == 0)
                markerLevel = 'z';
                markerMethod = 'z';
                markerSpecies = 'z';
                info = 0;

            else        
                % level %

                % 0 = unknown
                % 1 = positive
                % 2 = negative
                % 3 = weak positive
                % 4 = positive/negative mix
                % 5 = conflicting data


                if (numLevels == 1) % all levels in current spreadsheet cell are identical
                    markerLevel = levels(1);
                    if markerLevel == 0
                        info = 0;
                    else
                        info = 1;
                    end
                else
                    markerLevel = {unique(levels)};
                    info = 1;
                    %if (markerLevel{1}(1)==0)
                    %    markerLevel{1}(1) = -1;
                    %end
                end


                % method %

                % 0 = immunocytochemistry
                % 1 = mRNA
                % 2 = both
                % 3 = unknown
                % 4 = promoter expression construct
                % 5 = single cell PCR???

                if (length(unique(methods)) == 1) % all methods in current spreadsheet cell are identical
                    markerMethod = methods(1);
                else            
                    methods(methods==3) = [];

                    if (length(unique(methods)) == 1)
                        markerMethod = methods(1);
                    else
                        markerMethod = 2;
                    end
                end


                % species %

                % 0 = mouse
                % 1 = rat
                % 2 = both
                % 3 = unknown

                if (length(unique(species)) == 1) % all species in current spreadsheet cell are identical
                    markerSpecies = species(1);        
                else
                    species(species==3) = [];

                    if (length(unique(species)) == 1)
                        markerSpecies = species(1);
                    else
                        markerSpecies = 2;
                    end
                end



                %if code is 000.00000...
                if ((markerMethod == 0) && (markerSpecies == 0))
                    if ((length(unique(levels)) == 1) && levels(1)==0)
                        numLevels = 1;
                        markerLevel = -1; % thorough literature search has uncovered no information            
                        markerMethod = 3;
                        markerSpecies = 3;
                    end
                end
            end

        else
            markerMethod = 3;
            markerSpecies = 3;
        end
        
    end % isnan
end % parse_marker_presence_levels
