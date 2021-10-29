import os
import cv2
import numpy as np
from skimage import filters
# 1.Harris corner detector
# 2.normalized cross correlation (NCC)
# 3.set a threshold to keep only matches that have a large NCC score
# 4.RANSAC to robustly estimate the homography from the noisy correspondences
# nd corresponding features, estimate a homography
# 1.Harris corner detector
# 1.Harris corner detector
# 1.Harris corner detector

def Harris(img):
    # img = cv2.resize(img, dsize=(600, 400))
    # 灰度化
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray = np.float32(gray)
    # 高斯滤波
    gray = cv2.GaussianBlur(gray, (3, 3), 1.5)
    # 角点检测 第三个参数为角点检测的敏感度，其值必须介于3~31之间的奇数
    # 　　• img - 数据类型为 float32 的输入图像。
    # 　　• blockSize - 角点检测中要考虑的领域大小。
    # 　　• ksize - Sobel 求导中使用的窗口大小
    # 　　• k - Harris 角点检测方程中的自由参数,取值参数为 [0,04,0.06].
    dst = cv2.cornerHarris(gray, 3, 5, 0.06)
    dst[dst < 0.01 * dst.max()]=0
    index=np.where(dst!=0)
    #NMS
    size=2
    len=index[0].shape[0]
    for i in range(len) :
        r=index[0][i]
        c=index[1][i]
        r0 = np.maximum(r - size, 0)
        r1 = np.minimum(r + size, dst.shape[0])
        c0 = np.maximum(c - size, 0)
        c1 = np.minimum(c + size, dst.shape[1])
        if np.any(dst[r,c]<dst[r0:r1,c0:c1]):
            dst[r, c]=0#出现非最大值，即抑制
    img[dst!=0] = [0, 0, 255]
    index = np.where(dst != 0)
    return img,dst

# 获取文件夹信息
path = 'DanaHallWay1/'
path_list = os.listdir(path)
path_list.sort(key=lambda x:int(x.split('.')[0].split('_')[1]))

Num_dir=len(path_list)
# for i in range(Num_dir):
i=0
img1 = cv2.imread(os.path.join(path,path_list[i]),cv2.IMREAD_COLOR)
img2 = cv2.imread(os.path.join(path,path_list[i+1]),cv2.IMREAD_COLOR)
img3 = cv2.imread(os.path.join(path,path_list[i+2]),cv2.IMREAD_COLOR)
img3,dst=Harris(img1)
# img3,cor=harris_detect(img3)

# cv2.imshow('img_fg1', img1)
# cv2.imshow('img_fg2', img2)
cv2.imshow('img_fg3', img3)
cv2.waitKey()





