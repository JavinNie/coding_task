import numpy as np
from skimage import filters
import os
import cv2
from skimage import io
import matplotlib.pyplot as plt
from PIL import Image
from skimage.feature import corner_peaks
from panorama import harris_corners,NMS,plot_matches,\
    keypoint_description,description_matches,ransac,\
    get_output_space,warp_image,linear_blend,corner_detect
    # simple_descriptor, keypoint_description ,description_matches,

# 获取文件夹信息
# path = 'DanaHallWay1/'
path = 'DanaOffice/'
path_list = os.listdir(path)
path_list.sort(key=lambda x:int(x.split('.')[0].split('_')[1]))
Num_dir=len(path_list)
i=0
img1 = cv2.imread(os.path.join(path,path_list[i+1]),cv2.IMREAD_COLOR)
img2 = cv2.imread(os.path.join(path,path_list[i]),cv2.IMREAD_COLOR)
# img3 = cv2.imread(os.path.join(path,path_list[i+2]),cv2.IMREAD_COLOR)
# 缩小尺寸
img1=cv2.resize(img1,(img1.shape[1]//2,img1.shape[0]//2))
img2=cv2.resize(img2,(img2.shape[1]//2,img2.shape[0]//2))
'''
1、角点检测+非极大抑制
'''
# # 灰度化
image1= cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
reponse1 = harris_corners(image1,window_size=5,k=0.04,window_type=1)
image2= cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)
reponse2 = harris_corners(image2,window_size=5,k=0.04,window_type=1)
# # 角点检测
corners1 = corner_peaks(reponse1,threshold_rel=0.01)
corners2 = corner_peaks(reponse2,threshold_rel=0.01)
# corners1 = corner_detect(reponse1,1)
# corners2 = corner_detect(reponse2,1)

# 非极大抑制
keypoint1 = NMS(reponse1,corners1,1)
keypoint2 = NMS(reponse2,corners2,1)

# # #绘图
# plt.figure()
# img1 = Image.fromarray(cv2.cvtColor(img1,cv2.COLOR_BGR2RGB))
# plt.imshow(img1)
# plt.scatter(corners1[:,1],corners1[:,0],marker='x')
# plt.axis('off')
# plt.title('Detected Corner')
# plt.show()

'''
2、NCC匹配
'''
# desc1 = keypoint_description(image1,keypoint1,patch_size=5)
# desc2 = keypoint_description(image2,keypoint2,patch_size=5)
# matches = description_matches(desc1,desc2,threshold=2)
#
# fig,ax = plt.subplots(1,1,figsize=(15,12))
# ax.axis('off')
# plot_matches(ax,img1,img2,keypoint1,keypoint2,matches)
# plt.title('NCC matches')
# plt.show()

'''
3、RANSAC筛选
'''
# 1、初步匹配
desc1 = keypoint_description(image1,keypoint1,patch_size=6)
desc2 = keypoint_description(image2,keypoint2,patch_size=6)
matches = description_matches(desc1,desc2,threshold=0.8)#最小两个距离之比，越小，越严格

# 2、RANSAC算法筛选
H, robust_matches = ransac(keypoint1, keypoint2, matches, threshold=20)#越小越严格

# 绘图1
fig,ax = plt.subplots(1,1,figsize=(15,12))
ax.axis('off')
plot_matches(ax,image1,image2,keypoint1,keypoint2,matches)
plt.title('NCC matches')

# # 绘图2
fig, ax = plt.subplots(1, 1, figsize=(15, 12))
plot_matches(ax, image1, image2, keypoint1, keypoint2, robust_matches)
plt.axis('off')
plt.title('RANSAC matches')
plt.show()

'''
4、Image wrap
'''
# 合适的输出空间
output_shape, offset = get_output_space(image1, [image2], [H])
# 仿射变换图片1
image1_warped = warp_image(image1,np.eye(3),output_shape,offset)
image1_mask = (image1_warped != 0)
# 仿射变换图片2
image2_warped = warp_image(image2,H,output_shape,offset)
image2_mask = (image2_warped != 0)
# 绘图
plt.figure(figsize=(15,12))
plt.subplot(121)
plt.imshow(image1_warped, interpolation='nearest', cmap='gray')
plt.title('warped1')
plt.subplot(122)
plt.imshow(image2_warped, interpolation='nearest', cmap='gray')
plt.title('warped2')


# # 合并图片
# merged = np.float(image1_warped) + np.float(image2_warped)
overlap = np.maximum(image1_mask*1+image2_mask,1)
merged = image1_warped/ overlap+ image2_warped/ overlap
# 绘图
plt.figure(figsize=(15,12))
plt.imshow(merged, interpolation='nearest', cmap='gray')
plt.title('directly merge')
# plt.show()

'''
linear blend 
'''
merged = linear_blend(image1_warped,image2_warped)
plt.figure(figsize=(15,12))
plt.imshow(merged, interpolation='nearest', cmap='gray')
plt.title('linear blend')
plt.show()
