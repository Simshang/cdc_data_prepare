import numpy as np
import cv2
import os
from time import localtime, strftime
import scipy.io

inputdir = './all_frames_pervideo/'  # a list of folders; each folder contains all frames for one video
outputdir = '../train/'
listfile = open(outputdir + "train.lst", 'w')

window = 32  # window length per each bin file
sr = 25  # sampling rate per frame



for v in os.listdir(inputdir):
    print v
    print strftime("%a, %d %b %Y %X +0000", localtime())
    os.mkdir(os.path.join(outputdir, 'window', v))
    imglist = os.listdir(os.path.join(inputdir, v))
    # prepare label
    vlabel = np.zeros(len(imglist))  # during training, assign frame-level label here instead of all zeros

    # iter over window
    for s in range(0, len(imglist) - window + 1, window):
        video = [cv2.imread(os.path.join(inputdir, v, img)) for img in imglist[s:s + window]]  # read image
        video = [cv2.resize(video[i], (171, 128)) for i in range(0, len(video))]  # resize
        seg = np.stack(video)  # stack a set of frames
        seg = np.moveaxis(seg, -1, 0)  # adjust axis location
        slabel = [vlabel[s + idx] for idx in range(0, window)]
        label = np.expand_dims(
            np.stack([int(slabel[idx]) * np.ones(seg.shape[2:], dtype=np.uint8) for idx in range(0, window)]),
            axis=0)  # add class label for softmax loss as additional channel
        binfile = np.concatenate((seg, label), axis=0)  # concat seg and label
        binfilename = int(s + 1)  # the index from 1 of the first frame
        filepath = os.path.join(outputdir, 'window', v, str(binfilename).zfill(6) + ".bin")
        filepath = filepath.replace("\\","/")
        with open(filepath, 'wb') as f:
            listfile.write(filepath)
            listfile.write('\n')
            np.asarray([1] + list(binfile.shape), dtype=np.int32).tofile(f)  # meta write in 32 bits
            binfile.tofile(f)  # write data

    # last window
    if (len(imglist) % window) != 0:
        video = [cv2.imread(os.path.join(inputdir, v, img)) for img in imglist[-window:]]  # read image
        video = [cv2.resize(video[i], (171, 128)) for i in range(0, len(video))]  # resize
        seg = np.stack(video)  # stack a set of frames
        seg = np.moveaxis(seg, -1, 0)  # adjust axis location
        slabel = [vlabel[len(imglist) - window + idx] for idx in range(0, window)]
        label = np.expand_dims(
            np.stack([int(slabel[idx]) * np.ones(seg.shape[2:], dtype=np.uint8) for idx in range(0, window)]),
            axis=0)  # add class label for softmax loss as additional channel
        binfile = np.concatenate((seg, label), axis=0)  # concat seg and label
        binfilename = int(len(imglist) - window + 1)  # the index from 1 of the first frame
        filepath = os.path.join(outputdir, 'window', v, str(binfilename).zfill(6) + ".bin")
        filepath = filepath.replace("\\","/")
        with open(filepath, 'wb') as f:
            listfile.write(filepath)
            listfile.write('\n')
            np.asarray([1] + list(binfile.shape), dtype=np.int32).tofile(f)  # meta write in 32 bits
            binfile.tofile(f)  # write data
