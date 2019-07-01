function [infersLoaded] = cells2infers(nRows, infersFile)
    load markers.mat nAllParcels
    load infers_file_data.mat
    load markerToggles.mat isCalcConfidStats
        
    fprintf(1, '\nLoading inferences ...');
    
    rangeStr = strcat(infers_DontUseColLetter, num2str(infers_rowSkip+1), ':', infers_DontUseColLetter, num2str(nRows));
    [~, ~, dontuseRaw] = xlsread(infersFile, rangeStr);
    infers_dontuse = dontuseRaw;
    
    rangeStr = strcat(infers_InferNumColLetter, num2str(infers_rowSkip+1), ':', infers_InferNumColLetter, num2str(nRows));
    [InferNumNum, ~, ~] = xlsread(infersFile, rangeStr);
    infers_inferNum = InferNumNum;    
    
    rangeStr = strcat(infers_SubregionColLetter, num2str(infers_rowSkip+1), ':', infers_SubregionColLetter, num2str(nRows));
    [~, subregionText] = xlsread(infersFile, rangeStr);
    infers_subreg = subregionText;
    
    rangeStr = strcat(infers_LayersColLetter, num2str(infers_rowSkip+1), ':', infers_LayersColLetter, num2str(nRows));
    [~, layersText] = xlsread(infersFile, rangeStr);
    infers_layers = layersText;
    
    rangeStr = strcat(infers_priNeurotransmitterColLetter, num2str(infers_rowSkip+1), ':', infers_priNeurotransmitterColLetter, num2str(nRows));
    [~, ~, priNeurotransRaw] = xlsread(infersFile, rangeStr);
    infers_priNeurotrans = priNeurotransRaw;

    rangeStr = strcat(infers_inferTypeColLetter, num2str(infers_rowSkip+1), ':', infers_inferTypeColLetter, num2str(nRows));
    [~, inferTypeText] = xlsread(infersFile, rangeStr);
    infers_inferType = inferTypeText;
    
    rangeStr = strcat(infers_marker1ColLetter, num2str(infers_rowSkip+1), ':', infers_marker1ColLetter, num2str(nRows));
    [~, marker1Text] = xlsread(infersFile, rangeStr);
    infers_marker1 = marker1Text;

    rangeStr = strcat(infers_marker2ColLetter, num2str(infers_rowSkip+1), ':', infers_marker2ColLetter, num2str(nRows));
    [~, marker2Text] = xlsread(infersFile, rangeStr);
    infers_marker2 = marker2Text;
    
    rangeStr = strcat(infers_nColLetter, num2str(infers_rowSkip+1), ':', infers_nColLetter, num2str(nRows));
    [~, ~, nRaw] = xlsread(infersFile, rangeStr);
    infers_n = nRaw;
    
    rangeStr = strcat(infers_percentageTrueColLetter, num2str(infers_rowSkip+1), ':', infers_percentageTrueColLetter, num2str(nRows));
    percentageTrueNum = xlsread(infersFile, rangeStr);
    infers_percentTrue = percentageTrueNum * 100;
 
    rangeStr = strcat(infers_binomial_confidColLetter, num2str(infers_rowSkip+1), ':', infers_binomial_confidColLetter, num2str(nRows));
    [~, ~, binomialConfidRaw] = xlsread(infersFile, rangeStr);
    infers_binConfid = binomialConfidRaw;
    
    rangeStr = strcat(infers_ClopPear_confidColLetter, num2str(infers_rowSkip+1), ':', infers_ClopPear_confidColLetter, num2str(nRows));
    [~, ~, clopPearConfRaw] = xlsread(infersFile, rangeStr);
    infers_ClopPearConfid = clopPearConfRaw;
 
    rangeStr = strcat(infers_exceptionColLetter, num2str(infers_rowSkip+1), ':', infers_exceptionColLetter, num2str(nRows));
    [~, ~, exceptionRaw] = xlsread(infersFile, rangeStr);
    infers_exceptions = exceptionRaw;

    rangeStr = strcat(infers_refIDColLetter, num2str(infers_rowSkip+1), ':', infers_refIDColLetter, num2str(nRows));
    [~, ~, refIDRaw] = xlsread(infersFile, rangeStr);
    infers_refIDs = refIDRaw;
    for i=1:length(infers_refIDs)
        if isnumeric(infers_refIDs{i})
            infers_refIDs{i} = num2str(infers_refIDs{i});
        end
    end
    
    rangeStr = strcat(infers_protocolColLetter, num2str(infers_rowSkip+1), ':', infers_protocolColLetter, num2str(nRows));
    [~, protocolText] = xlsread(infersFile, rangeStr);
    infers_protocol = protocolText;
    
    rangeStr = strcat(infers_speciesColLetter, num2str(infers_rowSkip+1), ':', infers_speciesColLetter, num2str(nRows));
    [~, speciesText] = xlsread(infersFile, rangeStr);
    infers_species = speciesText;
        
    rangeStr = strcat(infers_pmidColNum, num2str(infers_rowSkip+1), ':', infers_pmidColNum, num2str(nRows));
    [~, ~, pmidRaw] = xlsread(infersFile, rangeStr);
    infers_PMIDs = pmidRaw;
    for i=1:length(infers_PMIDs)
        if isnumeric(infers_PMIDs{i})
            infers_PMIDs{i} = num2str(infers_PMIDs{i});
        end
    end
    
    
    
    numInfers = length(infers_layers);
    
    done = 0;
    for z=numInfers:-1:1
        if ~isnan(infers_dontuse{z})
            if ~done
                
                if length(infers_inferNum)==numInfers
                    infers_inferNum(z) = [];
                end
                if length(infers_subreg)==numInfers
                    infers_subreg{z} = [];
                end
                if length(infers_layers)==numInfers
                    infers_layers{z} = [];
                end
                if length(infers_priNeurotrans)==numInfers
                    infers_priNeurotrans{z} = [];
                end
                if length(infers_inferType)==numInfers
                    infers_inferType{z} = [];
                end
                if length(infers_marker1)==numInfers
                    infers_marker1{z} = [];
                end
                if length(infers_marker2)==numInfers
                    infers_marker2{z} = [];
                end
                if length(infers_n)==numInfers
                    infers_n{z} = [];
                end
                if length(infers_percentTrue)==numInfers
                    infers_percentTrue(z) = [];
                end
                if length(infers_binConfid)==numInfers
                    infers_binConfid{z} = [];
                end
                if length(infers_ClopPearConfid)==numInfers
                    infers_ClopPearConfid{z} = [];
                end
                if length(infers_exceptions)==numInfers
                    infers_exceptions{z} = [];
                end
                if length(infers_refIDs)==numInfers
                    infers_refIDs{z} = [];
                end
                if length(infers_protocol)==numInfers
                    infers_protocol{z} = [];
                end
                if length(infers_species)==numInfers
                    infers_species{z} = [];
                end
                if length(infers_PMIDs)==numInfers
                    infers_PMIDs{z} = [];
                end
                
                numInfers = numInfers - 1;
            end
        else
            done = 1;
        end
    end
    
    infers_priorities = zeros(numInfers,1);
    inferApplicationLayers = zeros(numInfers, nAllParcels);    
    
    for i=1:numInfers
        inferLayerTerms = strsplit(char(infers_layers(i)),'_');

        for j=1:length(inferLayerTerms)
            if ~isempty(strfind(infers_subreg{i}, 'DG')) || ~isempty(strfind(infers_subreg{i}, 'Dg'))
                if strcmpi(inferLayerTerms(j), 'smo')
                    inferApplicationLayers(i,1) = 1;
                elseif strcmpi(inferLayerTerms(j), 'smi')
                    inferApplicationLayers(i,2) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sg')
                    inferApplicationLayers(i,3) = 1;
                elseif strcmpi(inferLayerTerms(j), 'h')
                    inferApplicationLayers(i,4) = 1;
                end
            end

            if ~isempty(strfind(infers_subreg{i}, 'CA3')) || ~isempty(strfind(infers_subreg{i}, 'Ca3'))
                if strcmpi(inferLayerTerms(j), 'slm')
                    inferApplicationLayers(i,5) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sr')
                    inferApplicationLayers(i,6) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sl')
                    inferApplicationLayers(i,7) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sp')
                    inferApplicationLayers(i,8) = 1;
                elseif strcmpi(inferLayerTerms(j), 'so')
                    inferApplicationLayers(i,9) = 1;
                end
            end

            if ~isempty(strfind(infers_subreg{i}, 'CA2')) || ~isempty(strfind(infers_subreg{i}, 'Ca2'))
                if strcmpi(inferLayerTerms(j), 'slm')
                    inferApplicationLayers(i,10) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sr')
                    inferApplicationLayers(i,11) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sp')
                    inferApplicationLayers(i,12) = 1;
                elseif strcmpi(inferLayerTerms(j), 'so')
                    inferApplicationLayers(i,13) = 1;
                end
            end

            if ~isempty(strfind(infers_subreg{i}, 'CA1')) || ~isempty(strfind(infers_subreg{i}, 'Ca1'))
                if strcmpi(inferLayerTerms(j), 'slm')
                    inferApplicationLayers(i,14) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sr')
                    inferApplicationLayers(i,15) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sp')
                    inferApplicationLayers(i,16) = 1;
                elseif strcmpi(inferLayerTerms(j), 'so')
                    inferApplicationLayers(i,17) = 1;
                end
            end

            if ~isempty(strfind(infers_subreg{i}, 'SUB')) || ~isempty(strfind(infers_subreg{i}, 'Sub'))
                if strcmpi(inferLayerTerms(j), 'sm')
                    inferApplicationLayers(i,18) = 1;
                elseif strcmpi(inferLayerTerms(j), 'sp')
                    inferApplicationLayers(i,19) = 1;
                elseif strcmpi(inferLayerTerms(j), 'pl')
                    inferApplicationLayers(i,20) = 1;
                end
            end

            if ~isempty(strfind(infers_subreg{i}, 'EC')) || ~isempty(strfind(infers_subreg{i}, 'Ec'))
                if strcmpi(inferLayerTerms(j), 'i')
                    inferApplicationLayers(i,21) = 1;
                elseif strcmpi(inferLayerTerms(j), 'ii')
                    inferApplicationLayers(i,22) = 1;
                elseif strcmpi(inferLayerTerms(j), 'iii')
                    inferApplicationLayers(i,23) = 1;
                elseif strcmpi(inferLayerTerms(j), 'iv')
                    inferApplicationLayers(i,24) = 1;
                elseif strcmpi(inferLayerTerms(j), 'v')
                    inferApplicationLayers(i,25) = 1;
                elseif strcmpi(inferLayerTerms(j), 'vi')
                    inferApplicationLayers(i,26) = 1;
                end
            end
            
        end
        
        inferApplicationScope = inferApplicationLayers;
        
        
        % store protocol and species info to match single-digit codes in spreadsheet
        
        switch(infers_protocol{i})
            case 'i' % immuno
                infers_protocol{i} = '0';            
            case 'm' % mRNA (in situ)
                infers_protocol{i} = '1';
            case 'b' % both
                infers_protocol{i} = '2';
            otherwise % unknown
                infers_protocol{i} = '3';
        end
                
        switch(infers_species{i})
            case 'm' % mice
                infers_species{i} = '0';            
            case 'r' % rats
                infers_species{i} = '1';
            case 'b' % both
                infers_species{i} = '2';
            otherwise % unknown
                infers_species{i} = '3';
        end
    end
    
    
    %% fill in missing entries    
    
    for i=1:numInfers
        if i>=length(infers_priNeurotrans) || (sum(isnan(infers_priNeurotrans{i})) == 1) || isempty(infers_priNeurotrans{i})
            infers_priNeurotrans{i} = 'All';
        end
        
        if i>length(infers_n) || sum(isnan(infers_n{i}))>0
            infers_n{i} = 'okay';
        end
        
        if i>length(infers_percentTrue)
            infers_percentTrue(i) = NaN;
        end
        
        if i>length(infers_binConfid)
            infers_binConfid{i} = NaN;
        elseif ~isnumeric(infers_binConfid{i})
            if strcmpi(strtrim(infers_binConfid{i}), 'NaN')
                infers_binConfid{i} = NaN;
            end
        else
            infers_binConfid{i} = infers_binConfid{i} * 100;
        end

        if i>length(infers_ClopPearConfid)
            infers_ClopPearConfid{i} = NaN;
        elseif ~isnumeric(infers_ClopPearConfid{i})
            if strcmpi(strtrim(infers_ClopPearConfid{i}), 'NaN')
                infers_ClopPearConfid{i} = NaN;
            end
        else
            infers_ClopPearConfid{i} = infers_ClopPearConfid{i} * 100;
        end
        
        % TEMPORARILY SET TO IGNORE EXCEPTIONS COLUMN!!!!!!!!!!!!!!!!!
        if ~isnan(infers_exceptions{i})
            infers_exceptions{i} = NaN;
        end
        
          
        if i>length(infers_refIDs)
            infers_refIDs(i) = '?';
        end
        if i>length(infers_protocol)
            infers_protocol(i) = '';
        end
        if i>length(infers_species)
            infers_species(i) = '';
        end
        if i>length(infers_PMIDs)
            infers_PMIDs(i) = '?';
        end
    end

    maxInferNum = max(infers_inferNum);
    
    
    %% option to calculate threshold confidence statistics
    
    if isCalcConfidStats
        fprintf(1, '\nCalculating threshold confidence statistics ...');
        
        infers_percentChance95pos = zeros(numInfers,1);
        infers_lowerConfInt = zeros(numInfers,1);
        infers_upperConfInt = zeros(numInfers,1);
    
        for i=1:numInfers
            if isnumeric(infers_n{i}) && isnumeric(infers_percentTrue(i))
                n = infers_n{i};
                k = round(n*infers_percentTrue(i)/100);
                
                % calculate max fraction of neurons for which we can claim inf applies
                % (w/ 95% confidence or better)
                p = 1;
                while binocdf(k-1,n,p) < .95
                    p = p - .001;
                end

                infers_percentChance95pos(i) = p;
                
                % calculate upper and lower 95% confidence intervals
                [~,pci] = binofit(k,n);
                
                infers_lowerConfInt(i) = pci(1);
                infers_upperConfInt(i) = pci(2);
            else
                infers_percentChance95pos(i) = NaN;
                infers_lowerConfInt(i) = NaN;
                infers_upperConfInt(i) = NaN;
            end
        end
        
        infers_percentChance95pos_preDeletion_toCopyToExcel = infers_percentChance95pos;
        infers_lowerConfInt_preDeletion_toCopyToExcel = infers_lowerConfInt;
        infers_upperConfInt_preDeletion_toCopyToExcel = infers_upperConfInt;
        
    else
        infers_percentChance95pos = NaN;
        infers_lowerConfInt = NaN;
        infers_upperConfInt = NaN;
        infers_percentChance95pos_preDeletion_toCopyToExcel = NaN;
        infers_lowerConfInt_preDeletion_toCopyToExcel = NaN;
        infers_upperConfInt_preDeletion_toCopyToExcel = NaN;
    end
    
    
    %% delete unused inferences from all tables
    
    for i=numInfers:-1:1
        if ~isnan(infers_dontuse{i})
            infers_dontuse(i) = [];
            infers_inferNum(i) = [];
            infers_subreg(i) = [];
            infers_layers(i) = [];
            infers_priNeurotrans(i) = [];
            infers_inferType(i) = [];
            infers_marker1(i) = [];
            infers_marker2(i) = [];
            infers_n(i) = [];
            infers_percentTrue(i) = [];
            infers_binConfid(i) = [];
            infers_ClopPearConfid(i) = [];
            infers_exceptions(i) = [];
            infers_refIDs(i) = [];
            infers_protocol(i) = [];
            infers_species(i) = [];
            infers_PMIDs(i) = [];

            inferApplicationLayers(i,:) = [];
            inferApplicationScope(i,:) = [];

            if isCalcConfidStats
                infers_percentChance95pos(i) = [];
                infers_lowerConfInt(i) = [];
                infers_upperConfInt(i) = [];
            end

            numInfers = numInfers - 1;
        end
    end
    
    
    %% add contrapostive inferences to tables
    
    if isIncludeContrapositives
        currentIndex = numInfers + 1;
        
        for a=1:numInfers
            
            if strcmpi(infers_inferType(a), 'Pos-neg') || strcmpi(infers_inferType(a), 'Pos-pos')
                infers_dontuse(currentIndex) = infers_dontuse(a);
                infers_inferNum(currentIndex) = infers_inferNum(a);
                infers_subreg(currentIndex) = infers_subreg(a);
                infers_layers(currentIndex) =  infers_layers(a);
                infers_priNeurotrans{currentIndex} = infers_priNeurotrans{a};                
                infers_marker1(currentIndex) = infers_marker2(a);
                infers_marker2(currentIndex) = infers_marker1(a);
                infers_n(currentIndex) = infers_n(a);
                infers_percentTrue(currentIndex) = infers_percentTrue(a);
                infers_binConfid(currentIndex) = infers_binConfid(a);
                infers_ClopPearConfid(currentIndex) = infers_ClopPearConfid(a);
                infers_exceptions(currentIndex) = infers_exceptions(a);
                infers_refIDs(currentIndex) = infers_refIDs(a);
                infers_protocol(currentIndex) = infers_protocol(a);
                infers_species(currentIndex) = infers_species(a);
                infers_PMIDs(currentIndex) = infers_PMIDs(a);
                
                inferApplicationLayers(currentIndex,:) = inferApplicationLayers(a,:);
                inferApplicationScope(currentIndex,:) = inferApplicationScope(a,:);
                
                if isCalcConfidStats
                    infers_percentChance95pos(currentIndex) = infers_percentChance95pos(a);
                    infers_lowerConfInt(currentIndex) = infers_lowerConfInt(a);
                    infers_upperConfInt(currentIndex) = infers_upperConfInt(a);
                end
                
                if strcmpi(infers_inferType(a), 'Pos-neg')
                    infers_inferType{currentIndex} = sprintf('Contra:pos-neg (infer %d)', infers_inferNum(a));
                elseif strcmpi(infers_inferType(a), 'Pos-pos')                
                    infers_inferType{currentIndex} = sprintf('Contra:pos-pos (infer %d)', infers_inferNum(a));
                end
                
                currentIndex = currentIndex + 1;
            end
        end
        
        numInfers = length(infers_subreg);
    end

    
    %% assign inference priorities
    for i=1:numInfers
        thisInferType = infers_inferType{i};
        
        if ~isempty(strfind(thisInferType,'Contra:pos-neg'))
            thisInferType = 'Contra:pos-neg';
        elseif ~isempty(strfind(thisInferType,'Contra:pos-pos'))
            thisInferType = 'Contra:pos-pos';
        end
                
        switch thisInferType
            case 'Axons-proj-neg'
                infers_priorities(i) = 1;
            case 'Layer-neg'
                infers_priorities(i) = 2;
            case 'Pos-pos'
                infers_priorities(i) = 3;
            case 'Contra:pos-pos'
                infers_priorities(i) = 4;
            case 'Pos-neg'
                infers_priorities(i) = 5;
            case 'Contra:pos-neg'
                infers_priorities(i) = 6;
        end
        
        % de-prioritize correlation-produced REIs
        if (infers_inferNum(i) >= firstCorrProdREInum)
            infers_priorities(i) = infers_priorities(i) + 6;
        end
    end

    
    %% sort all inference fields by priority
    
    [~, indx] = sort(infers_priorities);
    infers_dontuse = infers_dontuse(indx);
    infers_inferNum = infers_inferNum(indx);
    infers_subreg = infers_subreg(indx);
    infers_layers = infers_layers(indx);
    infers_priNeurotrans = infers_priNeurotrans(indx);
    infers_inferType = infers_inferType(indx);
    infers_marker1 = infers_marker1(indx);
    infers_marker2 = infers_marker2(indx);
    infers_n = infers_n(indx);
    infers_percentTrue = infers_percentTrue(indx);
    infers_binConfid = infers_binConfid(indx);
    infers_ClopPearConfid = infers_ClopPearConfid(indx);
    infers_exceptions = infers_exceptions(indx);
    infers_refIDs = infers_refIDs(indx);
    infers_protocol = infers_protocol(indx);
    infers_species = infers_species(indx);
    infers_PMIDs = infers_PMIDs(indx);
    
    inferApplicationLayers = inferApplicationLayers(indx,:);
    inferApplicationScope = inferApplicationScope(indx,:);
    
    if isCalcConfidStats
        infers_percentChance95pos = infers_percentChance95pos(indx);
        infers_lowerConfInt = infers_lowerConfInt(indx);
        infers_upperConfInt = infers_upperConfInt(indx);
    end
    
    infersLoaded = 1;

    
    
    %% save
    
    save 'infers.mat' infers_dontuse infers_inferNum infers_subreg infers_layers inferApplicationLayers inferApplicationScope ...
        infers_priNeurotrans infers_inferType infers_marker1 infers_marker2 ...
        infers_n infers_percentTrue infers_binConfid infers_ClopPearConfid infers_exceptions infers_refIDs infers_protocol infers_species infers_PMIDs...
        infers_percentChance95pos_preDeletion_toCopyToExcel infers_lowerConfInt_preDeletion_toCopyToExcel infers_upperConfInt_preDeletion_toCopyToExcel ...
        infers_percentChance95pos infers_lowerConfInt infers_upperConfInt ...
        posInfCode negInfCode contraPosPos_negInf_Code contraPosNeg_negInf_Code posCorProdREI_posInf_Code negCorProdREI_negInf_Code ...
        numInfers maxInferNum firstCorrProdREInum
    
end % cells2infers
