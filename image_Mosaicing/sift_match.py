import cv2
import numpy as np
import os
import matplotlib.pyplot as plt

# 获取文件夹信息
path = 'DanaHallWay1/'
path_list = os.listdir(path)
path_list.sort(key=lambda x:int(x.split('.')[0].split('_')[1]))
Num_dir=len(path_list)
# for i in range(Num_dir):
i=0
train = cv2.imread(os.path.join(path,path_list[i+1]),cv2.IMREAD_COLOR)
query = cv2.imread(os.path.join(path,path_list[i+2]),cv2.IMREAD_COLOR)
# sift=cv2.xfeatures2d.SIFT_create()
sift=cv2.SIFT_create()
kp1,des1=sift.detectAndCompute(train,None)
kp2,des2=sift.detectAndCompute(query,None)
# FLANN parameters
FLANN_INDEX_KDTREE = 1
index_params = dict(algorithm = FLANN_INDEX_KDTREE, trees = 5)
search_params = dict(checks=50)   # or pass empty dictionary
flann = cv2.FlannBasedMatcher(index_params,search_params)
matches = flann.knnMatch(des1,des2,k=2)
# Need to draw only good matches, so create a mask
matchesMask = [[0,0] for i in range(len(matches))]
# ratio test as per Lowe's paper
for i,(m,n) in enumerate(matches):
#如果第一个邻近距离比第二个邻近距离的0.7倍小，则保留
    if m.distance < 0.7*n.distance:
        matchesMask[i]=[1,0]

draw_params = dict(matchColor = (0,255,0),
                   singlePointColor = (255,0,0),
                   matchesMask = matchesMask,
                   flags = 0)
img3 = cv2.drawMatchesKnn(train,kp1,query,kp2,matches,None,**draw_params)
plt.imshow(img3,),plt.show()