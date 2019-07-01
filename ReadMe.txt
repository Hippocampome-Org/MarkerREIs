*****************************************************************************************
matlab_source_REIs:
This program supplements molecular expression data for Hippocampome.org neuron types by applying a set of relational expression inferences (REIs)

******************************************************************************************
To run the program, execute the run.m function by typing "run" on the MATLAB command line.  The text-based menu will then guide the user through the options.

Quick start:
Press 'M' to load the direct evidence markers data.  Subsequently, press 'P' to apply the inferences and plot the resulting matrix.

******************************************************************************************
Required input files:
- direct evidence data for a set of neuron types and gene/protein expression (Hippocampome-Markers_v0.8beta_reordered_w_tildes_plus_new_classes_20160415-working-categorized_reordered_NewNames-20171221-working.xlsx)
- support_datafiles
1) soma location information for neuron types (_Hippocampome_somata_active_20170124.xlsx)
2) list of REIs (_Hippocampome_inferences_20190528.xlsx)
3) conflict evaluation log (_Conflict_Evaluation_Log_20160401-20170123.xlsx)

******************************************************************************************
Refer to the following article for more information:
Molecular Expression Profiles of Morphologically Defined Hippocampal Neuron Types: Empirical Evidence and Relational Inferences
Charise M. White, Christopher L. Rees, Diek W. Wheeler, David J. Hamilton, and Giorgio A. Ascoli 
