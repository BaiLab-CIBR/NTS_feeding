Codes for the study of Wang et al., 2024, Parallel Gut-to-Brain Pathways Orchestrate Feeding Behaviors.

Codes

1. Visualization

main.cluster.ipynb: Process RNAscope data using Seurat to obtain cell categories.

exNeuron.cluster.ipynb: Conduct cluster analysis of excitatory neurons and identify marker genes.

plots.ipynb: Analyze the correlation between FISH clusters (C1-18) and snRNA-seq clusters (Glu1-15) in the published dataset.

Step1_CellPositionMarker.m: Generate a point map of the same size as the RNAscope or histology raw data, along with coordinate data corresponding to each point.

Step2_IntensityLocator.m: Generate the coordinate table from step 1 based on the registration results.

Step3_ClusterMarker.m: Generate a point map of the same size as the original map based on the table generated in step 2.

2. Fiber photometry and behavior analysis

fiber_photometry_analysis.m: Analyze fiber photometry data to obtain DF/F and PSTH values, and plot the results.

optogenetics_analysis.m: Analyze the licking patterns in the optogenetic experiments.

