clear all; close all; clc;


cam = webcam(2);
cam.Resolution='752x416';

img = snapshot(cam);

cropRect = [0, 145, 715, 195]; % x=0, y=, width=, height=
croppedImg = imcrop(img, cropRect);
imwrite(croppedImg, "cam_reference.jpg");
imshow(croppedImg)


% requires comp vision toolbox

clear cam;

disp("done")