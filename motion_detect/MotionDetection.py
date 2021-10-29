import os
import cv2
import numpy as np

# 时间差分
def absdiff_demo(image_1, image_2, sThre):
    gray_image_1 = cv2.cvtColor(image_1, cv2.COLOR_BGR2GRAY)  #灰度化
    gray_image_1 = cv2.GaussianBlur(gray_image_1, (3, 3), 0)  #高斯滤波
    gray_image_2 = cv2.cvtColor(image_2, cv2.COLOR_BGR2GRAY)
    gray_image_2 = cv2.GaussianBlur(gray_image_2, (3, 3), 0)
    d_frame = cv2.absdiff(gray_image_1, gray_image_2)
    ret, d_frame = cv2.threshold(d_frame, sThre, 255, cv2.THRESH_BINARY) #大于阈值为255，小于阈值为0
    return d_frame

# 获取文件夹信息
path = 'answerA/Office/'
path_list = os.listdir(path)
# path_list.remove('.DS_Store')# macos中的文件管理文件，默认隐藏，这里可以忽略
path_list.sort(key=lambda x:int(x.split('.')[0].split('_')[1]))
# print(path_list)

fps = 24 #视频每秒24帧
size = (320, 240) #需要转为视频的图片的尺寸

#视频保存在当前目录下
video = cv2.VideoWriter("VideoTest1.avi", cv2.VideoWriter_fourcc('I', '4', '2', '0'), fps, size)



sThre = 7 #sThre表示像素阈值
Num_dir=len(path_list)
for i in range(Num_dir):
    img1 = cv2.imread(os.path.join(path,path_list[i]),cv2.IMREAD_COLOR)
    img2 = cv2.imread(os.path.join(path,path_list[i+1]),cv2.IMREAD_COLOR)
    img3 = cv2.imread(os.path.join(path,path_list[i+2]),cv2.IMREAD_COLOR)
    # 帧间差分，生成掩模
    d_frame = absdiff_demo(img1, img2, img3, sThre)

    # 生成三通道掩模
    mask = cv2.cvtColor(d_frame, cv2.COLOR_GRAY2BGR)

    # 掩模
    # alpha 为第一张图片的透明度
    alpha = 1
    # beta 为第二张图片的透明度
    beta = 0.5
    gamma = 0
    # 掩模染色
    mask[mask[:, :, 2] > 1, 2] = 180
    # 在原图上叠加掩模
    mask_img = cv2.addWeighted(img1, alpha, mask, beta, gamma)
    # 写入视频
    video.write(mask_img)
    # 实时显示
    cv2.imshow('img_fg', mask_img)
    cv2.waitKey(20)

# 释放视频对象
video.release()


