import czifile
import numpy as np
import scipy.ndimage as ndi
import csv
import sys
import random
from skimage import io
from skimage import filters
from skimage.morphology import reconstruction
import os 
import matplotlib.pyplot as plt
import copy

def main(argv):
	threshold=2600# set threshold of intensity
	thisdir=os.getcwd()
	savedir=thisdir
	
	# Create a csv file for all the intensities:
	with open(savedir+'\\Fluorescence_quantification.csv','w',newline='') as csvfile:
		f=csv.writer(csvfile,delimiter=',')
		f.writerow(['Directory','Filename','Treatment','Area','SumIntensity','MeanIntensity'])
	
	# search all subfolders of current directory for ".czi" files:
	directories = [x[0] for x in os.walk(thisdir)]
	print(directories)
	for directory in directories:
		files = [x for x in os.listdir(directory) if x.endswith('.czi')]
		print(files)
		for filename in files:# for each ".czi" file
			root = czifile.imread(directory+'\\'+filename)# read in file
			root=root[0,1,:,:,0]# select fluorescence channel
			rootF=copy.copy(root)
			# subtract threshold, all below threshold to 0
			rootF[rootF<threshold]=threshold
			rootF=rootF-threshold
			# create a mask of values above threshold
			mask=rootF>0

			labels,n=ndi.label(mask)# label all the connected pieces of the mask
			labelValues=np.unique(labels.ravel())# get label values
			labelSizes=np.bincount(labels.ravel())# get sizes of labelled pieces
			indexSizes=np.argsort(labelSizes)# get indices for sorting labelled pieces by size
			labelSizes=labelSizes[indexSizes[::-1]]# sort from largest to smallest
			labelValues=labelValues[indexSizes[::-1]]
			large=labelSizes>20# discard labelled pieces that are too small
			# keep only the second largest piece (largest is the dark background, second largest is largest fluorescence piece)
			large[0]=0
			large[2:]=0
			indexSizesRevert=np.argsort(labelValues)# revert the order
			large=large[indexSizesRevert]
			mask=large[labels]# create a mask of only the second largest piece (largest fluorescent piece)
			rootLabelled=mask*labels# apply mask
			rootF=mask*rootF
			
			# write area, sum intensity and mean intensity to ".csv" file
			with open(savedir+'\\Fluorescence_quantification.csv','a',buffering=1,newline='') as csvfile:
				f=csv.writer(csvfile,delimiter=',')
				f.writerow(np.hstack([directory,filename,directory[len(thisdir)+1:-11],sum(sum(mask)),sum(sum(rootF)),sum(sum(rootF))/sum(sum(mask))]))
			
			# draw root
			rootColour=root-root.min()# normalise image
			rootColour=rootColour.astype(float)/rootColour.max()
			rootColour=np.dstack((mask,rootColour,rootColour))# show masked fluorescence as red
			print(sum(sum(rootF)))
			plt.imshow(rootColour)
			plt.text(60,60,sum(sum(rootF)),color='red')
			plt.text(60,120,sum(sum(mask)),color='red')
			plt.savefig(savedir+'\\'+filename[:-4]+'.png')
			plt.gcf().clear()
			
main(sys.argv[0])
