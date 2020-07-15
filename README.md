# NTL8TemperatureGrowth
Code files for "Temperature-dependent growth contributes to long-term cold sensing", Zhao et al 2020, Nature. https://www.nature.com/articles/s41586-020-2485-4

## Files for computational model

`rootSim.m, brightfieldGFP.m, cell_division.m, add_rootgrids.m`

Matlab files, MATLAB Version: 9.5.0.944444 (R2018b), The MathWorks, Inc., Natick, Massachusetts, United States.

author: Rea L Antoniou-Kourounioti

Usage: run rootSim.m file in Matlab. No input arguments are required. Parameters are defined in rootSim.m.

## Files for image analysis to quantify fluorescence signal in ".czi" files

`image_process_fluorescence.py, czifile.py, tiffile.py`

Python files, Python 3.5.4 |Anaconda 2.4.1 (64-bit)| (default, Aug 14 2017, 13:41:13) [MSC v.1900 64 bit (AMD64)] on win32

author of image_process_fluorescence.py: Rea L Antoniou-Kourounioti

For czifile.py and tiffile.py, by Christoph Gohlke see information in files

test data (Imaging by Yusheng Zhao): g8w-s4-4w.czi, g8w-s4-4w+ga.czi

output files from test data: g8w-s4-4w.png, g8w-s4-4w+ga.png

Full dataset of input files can be found on figshare (doi: 10.6084/m9.figshare.12283970)

Usage: `python image_process_fluorescence.py`

No input arguments are required. Files to process must be in current directory or subdirectories. All .czi files in current directory or subdirectories will be processed. Output will give a .png file for each .czi image and a .csv summary with all the quantifications. Parameters are defined in `image_process_fluorescence.py`
