images = load_images();
exposure_times = [1/30, 1/10, 1/3, 0.62, 1.3, 4];
curve
image = generate_hdr_image(images, C, exposure_times);
imshow(tonemap(image));

function [images] = load_images()
images{1} = imread('images/office_1.jpg');
images{2} = imread('images/office_2.jpg');
images{3} = imread('images/office_3.jpg');
images{4} = imread('images/office_4.jpg');
images{5} = imread('images/office_5.jpg');
images{6} = imread('images/office_6.jpg');
end

function [expanded] = gamma_expansion(img)
%gamma_expansion raises img to 2.2
expanded = img.^2.2;
end

function [compressed] = gamma_compression(img)
%gamma_expansion raises img to 1/2.2
compressed = img.^(1/2.2);
end

%TODO: Performace can probably be improved by avoiding for loops
function [actual_irradiance_value] = calculate_actual_irradiance_value(img, camera_curve, exposure_time)
% Uses the camera curve and exposure time to calculate the actual irradiance value in each pixel. This has to
% be done because sometimes the sensor aplies some effects to get better
% results.
[height, width, channels] = size(img);
actual_irradiance_value = img; % Initializing
for x=1:width
    for y=1:height
        for c=1:channels
            color = int64(img(y, x, c) * 255);
            actual_irradiance_value(y, x, c) = exp(camera_curve(color+1, c)) / exposure_time;
        end
    end
end
end

function [HDR_image] = generate_hdr_image(ldr_images, camera_curve, exposure_times)
% Generate a HDR image from a set of ldr_images. Requires you to know the
% camera curve

%% Initializes useful values
number_of_images = length(ldr_images);
[height, width, channels] = size(ldr_images{1});

%% Uses the images to calculate irradiance
for i=1:number_of_images
    % Apply gamma expansion since gamma compression is done during conversion from raw to jpg.
    float_img = im2double(ldr_images{i});
    expanded_image = gamma_expansion(float_img);
    
    % Get the actual irradiance image. This is supposed to revert filters applied by the camera to get better results and consider exposure time.
    actual_irradiance_images{i} = calculate_actual_irradiance_value(expanded_image, camera_curve, exposure_times(i));
end

%% Processes the HDR image
HDR_image = actual_irradiance_images{1}; %initialize
for x=1:width
    for y=1:height
        for c=1:channels
            used_images = 0; %% Count the images that didn't saturated
            sum_of_values = 0.0; %% Acumulate all the irradiance. Used later to calculate the average
            for i=1:number_of_images
                irradiance = actual_irradiance_images{i}(y, x, c);
                if  irradiance >= 0.01 || irradiance <= 0.09
                    used_images = used_images + 1;
                    sum_of_values = sum_of_values + irradiance;
                end
            end
            
            if used_images > 0
                HDR_image(y, x, c) = sum_of_values / used_images;
            else
                HDR_image(y, x, c) = irradiance;
            end     
        end
    end
end
end