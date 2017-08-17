# -*- coding: utf-8 -*-
"""
Created on Thu Aug 03 16:55:10 2017

@author: simshang
"""

import cv2
import os


def extract_video(video_path, save_path, class_index, train_txt):
    try:
        os.makedirs(save_path)
    except:
        pass

    vc = cv2.VideoCapture(video_path)

    # Find OpenCV version and show FPS
    (major_ver, minor_ver, subminor_ver) = (cv2.__version__).split('.')

    if int(major_ver) < 3:
        fps = vc.get(cv2.cv.CV_CAP_PROP_FPS)
        print "Frames per second using video.get(cv2.cv.CV_CAP_PROP_FPS): {0}".format(fps)
    else:
        fps = vc.get(cv2.CAP_PROP_FPS)
        print "Frames per second using video.get(cv2.CAP_PROP_FPS) : {0}".format(fps)

    if vc.isOpened():  #
        rval, frame = vc.read()
        frame_count = 1
    else:
        rval = False

    while rval:
        cv2.imwrite(save_path + '/' + str(frame_count).zfill(6) + '.jpg', frame)
        savelist = save_path.split("/")
        train_line = savelist[1] + "/" + savelist[2] + "/" + " " + str(frame_count) + " " + str(class_index)
        train_txt.write(train_line + "\n")
        rval, frame = vc.read()
        frame_count = frame_count + 1

    vc.release()

    print frame_count


video_dir = "./videodata"

train_txt = open("./train_01.lst", "w")
for class_index in range(2):
    class_list = os.listdir(video_dir)
    save_path = "./all_frames_pervideo"
    video_dir_path = video_dir + "/" + class_list[class_index]
    save_path = save_path + "/" + class_list[class_index]
    video_list = os.listdir(video_dir_path)
    for video_index in range(len(video_list)):
        video_path = video_dir_path + "/" + video_list[video_index]
        save_path_temp = save_path + "/" + video_list[video_index].split(".")[0]
        print save_path_temp
        extract_video(video_path, save_path_temp, class_index, train_txt)


train_txt.close()
