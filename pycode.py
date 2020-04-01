import cv2
import copy
from matplotlib import pyplot as plt
import numpy as np
from scipy.ndimage import gaussian_laplace as log

class Pycode():

    def __init__(self, fn):
        self.img = cv2.imread(fn)

    def centroids(self): #X
        # Find the centroid of the 224x224x3 normalized image
        # Return a tuple of 2 values, in the form of(x-centroid, y-centroid)
        grayimg = cv2.cvtColor(self.img, cv2.COLOR_BGR2GRAY)
        ret, thresh = cv2.threshold(grayimg, 127, 255, 0)
        M = cv2.moments(thresh)
        if M['m00'] != 0:
            cX = int(M['m10'] / M['m00'])
            cY = int(M['m01'] / M['m00'])
        else:
            return (0,0)
        return (cX, cY)

    def lapofgau(self):
        # Convolute a gaussian kernel and a laplace kernel
        return log(self.img, sigma=1)

    def canny(self):
        return cv2.Canny(self.img, 100, 200)

    def sobel(self):
        return cv2.Sobel(self.img, cv2.CV_64F, 1,1, ksize=5)

    def calc_histogram(self): #X
        hist = cv2.calcHist([self.img], [0], None, [256], [0, 256])
        return hist

    def hough_line(self):
        gray = cv2.cvt(self.img, cv2.COLOR_BGR2GRAY)
        edges = canny(self.img)
        lines = cv2.HoughLines(edges, 1, np.pi/180, 200)
        imgcpy = copy.deepcopy(self.img)
        for rho, theta in lines[0]:
            a = np.cos(theta)
            b = np.sin(theta)
            x0 = a*rho
            y0 = b*rho
            x1 = int(x0 + 1000*(-b))
            y1 = int(y0 + 1000*(a))
            x2 = int(x0 - 1000*(-b))
            y2 = int(y0 - 1000(a))
            cv2.line(imgcpy, (x1,y1), (x2,y2), (0,0,255), 2)
        return imgcpy

    def fground_extract(self):
        # Extract the image foreground
        mask = np.zeros(self.img.shape[:2], np.uint8)
        bgdMode1 = np.zeros((1,65), np.float64)
        fgdMode1 = np.zeros((1,65), np.float64)
        cv2.grabCut(self.img, mask, (0,0,244,244), bgdMode1, fgdMode1, 5, cv2.GC_INIT_WITH_RECT)
        mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')
        imgcpy = copy.deepcopy(self.img)
        return imgcpy*mask2[:,:,np.newaxis]

    def corner_detect(self):
        # Harris Corner detect with OpenCV
        gray = cv2.cvtColor(self.img, cv2.COLOR_BGR2GRAY)
        gray = np.float32(gray)
        dst = cv2.cornerHarris(gray, 2, 3, 0.04)
        dst = cv2.dilate(dst, None)
        # Apply thresholding
        imgcpy = copy.deepcopy(self.img)
        imgcpy[dst>0.015*dst.max()]=[0,255,0]
        return imgcpy

x = Pycode('data_original\\Necrosis\\Necrosis_1.png')
print(x.centroids())
x.lapofgau()
x.canny()
x.sobel()
x.fground_extract()
x.corner_detect()
