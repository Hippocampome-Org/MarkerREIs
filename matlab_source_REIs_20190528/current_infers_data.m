function current_infers_data()

    % infers file info
    infers_rowSkip = 1; % rows to skip    
    infers_ColSkip = 0; % cols to skip (comments, etc.)
    
    % column numbers
    infers_DontUseColNum = infers_ColSkip + 1;
    infers_InferNumColNum = infers_ColSkip + 3;
    infers_SubregionColNum = infers_ColSkip + 5;
    infers_LayersColNum = infers_ColSkip + 6;
    infers_priNeurotransmitterColNum = infers_ColSkip + 7;
    infers_inferTypeColNum = infers_ColSkip + 8;
    infers_marker1ColNum = infers_ColSkip + 9;
    infers_marker2ColNum = infers_ColSkip + 10;
    infers_nColNum = infers_ColSkip + 11;
    infers_percentageTrueColNum = infers_ColSkip + 12;
        
    infers_binomial_confidColNum = infers_ColSkip + 13;
    infers_ClopPear_confidColNum = infers_ColSkip + 14;
    
    infers_exceptionColNum = infers_ColSkip + 22;
    
    infers_refIDColNum = infers_ColSkip + 26;
    infers_protocolColNum = infers_ColSkip + 30;
    infers_speciesColNum = infers_ColSkip + 31;
    infers_pmidColNum = infers_ColSkip + 44;
    
    isIncludeContrapositives = 1;
    
    posInfCode = 8;
    negInfCode = 9;
    contraPosPos_negInf_Code = 10;    
    contraPosNeg_negInf_Code = 11;
    posCorProdREI_posInf_Code = 12;
    negCorProdREI_negInf_Code = 13;
    
    firstCorrProdREInum = 887;
    
    
    %% convert column numbers to letters
    
    infers_DontUseColLetter = char(64+infers_DontUseColNum);
    infers_InferNumColLetter = char(64+infers_InferNumColNum);
    infers_SubregionColLetter = char(64+infers_SubregionColNum);
    infers_LayersColLetter = char(64+infers_LayersColNum);
    infers_priNeurotransmitterColLetter = char(64+infers_priNeurotransmitterColNum);
    infers_inferTypeColLetter = char(64+infers_inferTypeColNum);
    infers_marker1ColLetter = char(64+infers_marker1ColNum);
    infers_marker2ColLetter = char(64+infers_marker2ColNum);
    infers_nColLetter = char(64+infers_nColNum);
    infers_percentageTrueColLetter = char(64+infers_percentageTrueColNum);
    infers_binomial_confidColLetter = char(64+infers_binomial_confidColNum);
    infers_ClopPear_confidColLetter = char(64+infers_ClopPear_confidColNum);
    if (infers_exceptionColNum <= 26)
        infers_exceptionColLetter = char(64+infers_exceptionColNum);
    elseif (infers_exceptionColNum <= 52)
        infers_exceptionColLetter = ['A' char(64+infers_exceptionColNum - 26)];
    end
    if (infers_refIDColNum <= 26)
        infers_refIDColLetter = char(64+infers_refIDColNum);
    elseif (infers_refIDColNum <= 52)
        infers_refIDColLetter = ['A' char(64+infers_refIDColNum - 26)];
    end
    if (infers_protocolColNum <= 26)
        infers_protocolColLetter = char(64+infers_protocolColNum);
    elseif (infers_protocolColNum <= 52)
        infers_protocolColLetter = ['A' char(64+infers_protocolColNum - 26)];
    end
    if (infers_speciesColNum <= 26)
        infers_speciesColLetter = char(64+infers_speciesColNum);
    elseif (infers_speciesColNum <= 52)
        infers_speciesColLetter = ['A' char(64+infers_speciesColNum - 26)];
    end
    if (infers_pmidColNum <= 26)
        infers_pmidColNum = char(64+infers_pmidColNum);
    elseif (infers_pmidColNum <= 52)
        infers_pmidColNum = ['A' char(64+infers_pmidColNum - 26)];
    end
    
    
    
    %% save

    save infers_file_data.mat *
