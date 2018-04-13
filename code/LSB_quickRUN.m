imageList = dir('grayscale photo\*.jpg');
imageNum = length(imageList);

PSNR_pair_new_List = zeros(imageNum, 1);
PSNR_pair_List = zeros(imageNum, 1);
% PSNR_pair1_List = zeros(imageNum, 1);

Image_List = cell(imageNum, 1);

for i = 1: imageNum
    hostImage = imageList(i).name;
    index = strfind(hostImage, '.');                        %index is the digit+1 of image name. e.g 100=>4; 10=>3. First (index-1) stand for image name, the last stand for dot ".".
    imageName = hostImage(1:index - 1);                     %image name is an char list, 1 to index-1 is the image name, exit in ASCII stand. e.g 8=>56; 2=>50
    Image_List{i} = imageName;
    hostImage = strcat('grayscale photo\', hostImage);      %hostImage = path
    [hieght, width] = LSB_pair_new(hostImage, 'watermark.txt', strcat('LSB photo\', strcat(imageName, '.png')));
    LSB_extract(hieght, width, strcat('LSB photo\', strcat(imageName, '.png')), strcat('extract\',strcat(imageName, '.txt')));
    
    [hieght, width] = LSB_pair(hostImage, 'watermark_DES.txt', strcat('LSB-DES photo\', strcat(imageName, '.png')));
    LSB_extract(hieght, width, strcat('LSB-DES photo\', strcat(imageName, '.png')), strcat('extract_DES\',strcat(imageName, '.txt')));
    
%     [hieght, width] = LSB_pair_1(hostImage, 'watermark_DES.txt', strcat('LSB-pair1 photo\', strcat(imageName, '.png')));
%     LSB_extract(hieght, width, strcat('LSB-pair1 photo\', strcat(imageName, '.png')), strcat('extract_pair1\',strcat(imageName, '.txt')));
    
    
    hostImg = imread(hostImage);
    watermarkedImg_pair_new = imread(strcat('LSB photo\', strcat(imageName, '.png')));
    watermarkedImg_pair = imread(strcat('LSB-DES photo\', strcat(imageName, '.png')));
%     watermarkedImg_pair1 = imread(strcat('LSB-pair1 photo\', strcat(imageName, '.png')));
    % PSNR
    PSNR_pair_new = PSNR(hostImg, watermarkedImg_pair_new);
    PSNR_pair = PSNR(hostImg, watermarkedImg_pair);    
%     PSNR_pair1 = PSNR(hostImg, watermarkedImg_pair1);
    PSNR_pair_new_List(i) = PSNR_pair_new;
    PSNR_pair_List(i) = PSNR_pair;
%     PSNR_pair1_List(i) = PSNR_pair1;
    
    fprintf('Processing... (%d of %d) has been done...\n', i,imageNum);
end



PSNR_header = {'Image Name', 'LSB_pair_new', 'LSB-pair'};
PSNR_List = [PSNR_pair_new_List, PSNR_pair_List];
xlswrite('PSNR.xlsx', PSNR_header);
xlswrite('PSNR.xlsx', Image_List, 'Sheet1', 'A2');
xlswrite('PSNR.xlsx', PSNR_List, 'Sheet1', 'B2');
