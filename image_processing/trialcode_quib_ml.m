clear all; close all; clc;


cam = webcam(2);
cam.Resolution='752x416';

img = snapshot(cam);

cropRect = [0, 145, 715, 195]; % x=50, y=50, width=200, height=150
croppedImg = imcrop(img, cropRect);
imwrite(croppedImg, "cam_test.jpg");
imshow(croppedImg)


% requires comp vision toolbox

clear cam;

disp("done")