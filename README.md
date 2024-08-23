# RAT for XLZD

This is a duplicate of the rat repository (https://github.com/rat-pac/ratpac-two) to consider looking at the feasibility of using rat in xlzd. Currently, it's a duplicate and not a fork because it's very much in the early stages and not clear how far we'll go with this.

This project includes all of the json files for XLZD-40, 60, and 80t geometries from baccarat in order to build their geometries in RAT. It also includes a short macro for visualizing and performing a simple experiment on the detector, along with the code used to generate the PMT positions.

Currently, Tray has some minimal integration, allowing you to get a basic idea of quanta generation. 

## Instructions to use

The setup script is a stripped down version of what RAT provides themselves at: [https://github.com/rat-pac/ratpac-setup](https://github.com/rat-pac/ratpac-setup) to only include the components necessary for XLZD.

In order to use the Tray Process you will need to have tray installed and sourced (./env-shell.sh in Tray)

Currently being maintained by Kian Trengove (UCLA/UAlbany)
