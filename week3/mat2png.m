clc;
clear;
img_path = '/Users/janechen/Desktop/generated_kernel/';
imgs = dir(img_path);
m = length(imgs)-3;

for i=1:m
    imgname = imgs(i+3).name;
    sub_path = [img_path , imgname];
    load(sub_path)
    kernel = double(kernel);
    k = kernel - min(kernel(:));
    k = k./max(k(:));
    t_path = [img_path num2str(i) '.png']
    k = imresize(k, [90 90], 'nearest');
    imwrite(k, t_path);
end