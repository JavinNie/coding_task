from scipy.spatial import distance
import numpy as np
from skimage import filters
from skimage.feature import corner_peaks
import cv2
# from shapely.affinity import affine_transform
from scipy.ndimage.interpolation import affine_transform

def gaussian_kernel(size, sigma):
    gaussian_kernel = np.zeros((size, size))
    for i in range(size):
        for j in range(size):
            x = i - (size - 1) / 2
            y = j - (size - 1) / 2
            gaussian_kernel[i, j] = (1 / (2 * np.pi * sigma ** 2)) * np.exp(-(x ** 2 + y ** 2) / (2 * sigma ** 2))
    return gaussian_kernel


def conv(image, kernel):
    m, n = image.shape
    kernel_m, kernel_n = kernel.shape
    image_pad = np.pad(image, ((kernel_m // 2, kernel_m // 2), (kernel_n // 2, kernel_n // 2)), 'constant')
    result = np.zeros((m, n))
    for i in range(m):
        for j in range(n):
            value = np.sum(image_pad[i:i + kernel_m, j:j + kernel_n] * kernel)
            result[i, j] = value
    return result


def harris_corners(image, window_size=3, k=0.04, window_type=0):
    if window_type == 0:
        window = np.ones((window_size, window_size))
    if window_type == 1:
        window = gaussian_kernel(window_size, 1)
    m, n = image.shape
    dx = filters.sobel_v(image)
    dy = filters.sobel_h(image)
    dx_dx = dx * dx
    dy_dy = dy * dy
    dx_dy = dx * dy
    w_dx_dx = conv(dx_dx, window)
    w_dy_dy = conv(dy_dy, window)
    w_dx_dy = conv(dx_dy, window)
    reponse = np.zeros((m, n))
    for i in range(m):
        for j in range(n):
            M = np.array([[w_dx_dx[i, j], w_dx_dy[i, j]], [w_dx_dy[i, j], w_dy_dy[i, j]]])
            R = np.linalg.det(M) - k * (np.trace(M)) ** 2
            reponse[i, j] = R
    return reponse

def corner_detect(reponse,thr):
    corners = []
    ave=np.mean(reponse)
    std=np.std(reponse)
    reponse[reponse > ave+3*std*(1-thr)]=255
    corners=np.where(reponse==255)

    # len = corners.shape[0]
    # for i in range(len):
    #     r = corners[i][0]
    #     c = corners[i][1]
    #     r0 = np.maximum(r - size, 0)
    #     r1 = np.minimum(r + size, reponse.shape[0])
    #     c0 = np.maximum(c - size, 0)
    #     c1 = np.minimum(c + size, reponse.shape[1])
    #     if np.any(reponse[r, c] < reponse[r0:r1, c0:c1]):
    #         reponse[r, c] = 0  # 出现非最大值，即抑制
    #     else:
    #         corners_new.append([r, c])
    return np.array(corners).T



def NMS(reponse, corners, size):
    # 阈值筛选
    # reponse[reponse < 0.01 * reponse.max()] = 0
    # index = np.where(reponse != 0)
    # NMS非极大抑制
    corners_new = []
    len = corners.shape[0]
    for i in range(len):
        r = corners[i][0]
        c = corners[i][1]
        r0 = np.maximum(r - size, 0)
        r1 = np.minimum(r + size, reponse.shape[0])
        c0 = np.maximum(c - size, 0)
        c1 = np.minimum(c + size, reponse.shape[1])
        if np.any(reponse[r, c] < reponse[r0:r1, c0:c1]):
            reponse[r, c] = 0  # 出现非最大值，即抑制
        else:
            corners_new.append([r, c])
    return np.array(corners_new)


def plot_matches(ax, image1, image2, keypoint1, keypoint2, matches):
    H1, W1 = image1.shape[0:2]
    H2, W2 = image2.shape[0:2]
    if H1 > H2:
        new_image2 = np.zeros((H1, W2))
        new_image2[:H2, :] = image2
        image2 = new_image2
    if H1 < H2:
        new_image1 = np.zeros((H2, W1))
        new_image2[:H1, :] = image1
        image1 = new_image1
    image = np.concatenate((image1, image2), axis=1)
    ax.scatter(keypoint1[:, 1], keypoint1[:, 0], facecolors='none', edgecolors='k')
    ax.scatter(keypoint2[:, 1] + image1.shape[1], keypoint2[:, 0], facecolors='none', edgecolors='k')
    ax.imshow(image, interpolation='nearest', cmap='gray')
    for one_match in matches:
        index1 = one_match[0]
        index2 = one_match[1]
        color = np.random.rand(3)
        ax.plot((keypoint1[index1, 1], keypoint2[index2, 1] + image1.shape[1]),
                (keypoint1[index1, 0], keypoint2[index2, 0]), '-', color=color)


def keypoint_description(image, keypoint, patch_size=16):
    keypoint_desc = []
    for i, point in enumerate(keypoint):
        x, y = point

        x_len = patch_size // 2 + int(np.ceil(patch_size / 2))
        y_len = patch_size // 2 + int(np.ceil(patch_size / 2))

        x0 = np.maximum(x - patch_size // 2, 0)
        x1 = np.minimum(x + int(np.ceil(patch_size / 2)), image.shape[0])
        y0 = np.maximum(y - patch_size // 2, 0)
        y1 = np.minimum(y + int(np.ceil(patch_size / 2)), image.shape[1])

        patch = np.zeros((x_len, y_len))

        patch[patch_size // 2 - (x - x0):patch_size // 2 + (x1 - x),
        patch_size // 2 - (y - y0):patch_size // 2 + (y1 - y)] = image[x0:x1, y0:y1]
        description = simple_descriptor(patch)  ####
        keypoint_desc.append(description)
    return np.array(keypoint_desc)


def description_matches(desc1, desc2, threshold=0.5):
    distance_array = distance.cdist(desc1, desc2)
    matches = []
    i = 0
    for each_distance_list in distance_array:
        arg_list = np.argsort(each_distance_list)  # 从小到大排序，得到索引
        index1 = arg_list[0]
        index2 = arg_list[1]
        if each_distance_list[index1] / each_distance_list[index2] <= threshold:#0.65
            matches.append([i, index1])
        i += 1
        # if each_distance_list[index1] <= threshold:#2
        #     matches.append([i, index1])
        # i += 1
    return np.array(matches)

def simple_descriptor(patch):
    ave = np.mean(patch)
    std = np.std(patch)
    if std == 0:
        std = 1
    result_patch = (patch - ave) / std
    return result_patch.flatten()


'''


def hog_description(patch,cell_size=(8,8)):
    if patch.shape[0] % cell_size[0]!=0 or patch.shape[1] % cell_size[1]!=0:
        return 'The size of patch and cell don\'t match'
    n_bins=9
    degree_per_bins=20
    Gx = filters.sobel_v(patch)
    Gy = filters.sobel_h(patch)
    G = np.sqrt(Gx**2 + Gy**2)
    theta = (np.arctan2(Gy,Gx) * 180 / np.pi) % 180
    G_as_cells = view_as_blocks(G,block_shape=cell_size)
    theta_as_cells = view_as_blocks(theta,block_shape=cell_size)
    H = G_as_cells.shape[0]
    W = G_as_cells.shape[1]
    bins_accumulator = np.zeros((H,W,n_bins))
    for i in range(H):
        for j in range(W):
            theta_cell = theta_as_cells[i,j,:,:]
            G_cell = G_as_cells[i,j,:,:]
            for p in range(theta_cell.shape[0]):
                for q in range(theta_cell.shape[1]):
                    theta_value = theta_cell[p,q]
                    G_value = G_cell[p,q]
                    num_bins = int(theta_value // degree_per_bins)
                    k= int(theta_value % degree_per_bins)
                    bins_accumulator[i,j,num_bins % n_bins] += (degree_per_bins - k) / degree_per_bins\
                    * G_value
                    bins_accumulator[i,j,(num_bins+1) % n_bins] += k / degree_per_bins * G_value
    Hog_list = []
    for x in range(H-1):
        for y in range(W-1):
            block_description = bins_accumulator[x:x+2,y:y+2]
            block_description = block_description / np.sqrt(np.sum(block_description**2))
            Hog_list.append(block_description)
    return np.array(Hog_list).flatten()
'''


def fit_affine_matrix(p1, p2):
    assert (p1.shape[0] == p2.shape[0]), 'The number of p1 and p2 are different'
    # p1 = np.hstack((p1, np.ones((p1.shape[0], 1))))
    # p2 = np.hstack((p2, np.ones((p2.shape[0], 1))))
    H = np.linalg.pinv(p2) @ p1
    H[:, 2] = np.array([0, 0, 1])
    return H

def ransac(keypoint1, keypoint2, matches, n_iters=1000, threshold=20):
    N = matches.shape[0]
    match_keypoints1 = np.hstack((keypoint1[matches[:, 0]], np.ones((N, 1))))
    match_keypoints2 = np.hstack((keypoint2[matches[:, 1]], np.ones((N, 1))))
    n_samples = int(N * 0.2)# 取百分之二十的点做测试
    n_max = 0
    for i in range(n_iters):
        random_index = np.random.choice(N, n_samples, replace=False)
        p1_choice = match_keypoints1[random_index]
        p2_choice = match_keypoints2[random_index]
        H_choice=fit_affine_matrix(p1_choice, p2_choice)
        p1_test = match_keypoints2 @ H_choice

        diff = np.sum((match_keypoints1[:, :2] - p1_test[:, :2]) ** 2, axis=1)
        index = np.where(diff <= threshold)[0]#找出偏差小的点数
        n_index = index.shape[0]
        if n_index > n_max:#找到偏差点最少的转换矩阵，并将最多的无偏差点保留
            H = H_choice
            robust_matches = matches[index]
            n_max = n_index
            index_robust = index
    p1_choice = match_keypoints1[index_robust]
    p2_choice = match_keypoints2[index_robust]
    H = fit_affine_matrix(p1_choice, p2_choice)

    return H, robust_matches

def get_output_space(image_ref, images, transforms):
    H_ref, W_ref = image_ref.shape
    corner_ref = np.array([[0, 0, 1], [H_ref, 0, 1], [0, W_ref, 1], [H_ref, W_ref, 1]])
    all_corners = [corner_ref]
    if len(images) != len(transforms):
        print('The size of images and transforms does\'t match')
    for i in range(len(images)):
        H, W = images[i].shape
        corner = np.array([[0, 0, 1], [H, 0, 1], [0, W, 1], [H, W, 1]]) @ transforms[i]
        all_corners.append(corner)
    all_corners = np.vstack(all_corners)
    max_corner = np.max(all_corners, axis=0)
    min_corner = np.min(all_corners, axis=0)
    out_space = np.ceil((max_corner - min_corner)[:2]).astype(int)
    offset = min_corner[:2]
    return out_space, offset


def warp_image(image, H, output_shape, offset):
    H_invT = np.linalg.inv(H.T)
    matrix = H_invT[:2, :2]
    o = offset + H_invT[:2, 2]
    image_warped = affine_transform(image, matrix, o, output_shape, cval=-1)
    return image_warped

def linear_blend(image1_warped,image2_warped):
    merged = np.int16(image1_warped) + np.int16(image2_warped)
    H , W = image1_warped.shape
    image1_mask = (image1_warped!=0)
    image2_mask = (image2_warped!=0)
    left_margin = np.argmax(image2_mask,axis=1)
    right_margin = W - np.argmax(np.fliplr(image1_mask),axis=1)
    for i in range(H):
        k = right_margin[i] - left_margin[i]
        for j in range(k):
            alpha = j / (k - 1)
            merged[i,left_margin[i]+j] = (1-alpha) * image1_warped[i,left_margin[i]+j]+\
            alpha * image2_warped[i,left_margin[i]+j]
    return merged

def stitch_multiple_images(images,desc_func=simple_descriptor,patch_size=5):
    keypoints_list = []
    for image in images:
        keypoints= corner_peaks(harris_corners(image))
        keypoints_list.append(keypoints)
    descriptions = []
    for i,keypoints in enumerate(keypoints_list):
        desc = keypoint_description(images[i],keypoints,desc_func,patch_size=patch_size)
        descriptions.append(desc)
    matches_list=[]
    for i in range(len(images)-1):
        matches = description_matches(descriptions[i],descriptions[i+1],threshold=0.7)
        matches_list.append(matches)
    H_list=[]
    for i in range(len(images)-1):
        H,robust_matches = ransac(keypoints_list[i],keypoints_list[i+1],matches_list[i],n_iters=200,threshold=1)
        H_list.append(H)
        matches_list.append(robust_matches)
    n_images = len(images)
    n_ref = n_images//2
    image_ref = images[n_ref]
    a = images.copy()
    images.pop(n_ref)
    images_rest = images.copy()
    images = a.copy()
    H2ref_list=[]
    H_prior = np.eye(3)
    for i in range(n_ref):
        H_next = np.linalg.inv(H_list[n_ref-1-i]) @ H_prior
        H2ref_list.insert(0,H_next)
        H_prior = H_next.copy()
    H_prior = np.eye(3)
    for i in range(n_ref,n_images-1):
         H_next = H_list[i] @ H_prior
         H2ref_list.append(H_next)
         H_prior=H_next.copy()
    output_space,offset = get_output_space(image_ref,images_rest,H2ref_list)
    H2ref_list.insert(n_ref,np.eye(3))
    warps = []
    for i in range(len(images)):
        warp = warp_image(images[i],H2ref_list[i],output_space,offset)
        warp_mask = (warp != -1)
        warp[~warp_mask]=0
        warps.append(warp)
    prior_image = warps[0]
    for i in range(1,len(images)):
        blend_image = linear_blend(prior_image,warps[i])
        prior_image = blend_image
    return blend_image

