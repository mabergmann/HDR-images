images = load_images();
imshow(images{1})
size(images)

function [images] = load_images()
images{1} = imread('images/office_1.jpg')
images{2} = imread('images/office_2.jpg')
images{3} = imread('images/office_3.jpg')
images{4} = imread('images/office_4.jpg')
images{5} = imread('images/office_5.jpg')
images{6} = imread('images/office_6.jpg')
end

function [expanded] = gamma_expansion(img)
%gamma_expansion raises img to 2.2
expanded = img^2.2;
end

function [compressed] = gamma_compression(img)
%gamma_expansion raises img to 1/2.2
compressed = img^(1/2.2);
end

function [HDR_image] = generate_hdr_image(ldr_images, camera_curve)
% Generate a HDR image from a set of ldr_images. Requires you to know the
% camera curve
[number_of_images, height, width, channels] = seize(ldr_images);
end