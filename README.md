# RAT for XLZD

This project includes all of the json files for XLZD-40, 60, and 80 in order to build their geometries in RAT. It also includes a short macro for visualizing and performing a simple experiment on the detector, along with the code used to generate the PMT positions.

## Instructions to use

If RAT is already installed the macro and geometry files can be placed in their respective folders in RAT (macro and ratdb respectively). 

If RAT is not already installed you can install following the instructions here: [https://github.com/rat-pac/ratpac-two](https://github.com/rat-pac/ratpac-two). 

Alternatively a basic setup script has been provided which will install RAT along with dependencies needed. The setupscript will additionally move the json files and macro file to their intended locations.

The setupscript is a stripped down version of what RAT provides themselves at: [https://github.com/rat-pac/ratpac-setup](https://github.com/rat-pac/ratpac-setup) to only include the components necessary for XLZD.
