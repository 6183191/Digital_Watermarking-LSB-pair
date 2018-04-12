imageList = dir('grayscale photo\*.jpg');
imageNum = length(imageList);

PSNR_List_LSB = zeros(imageNum, 1);
PSNR_List_LSB_DES = zeros(imageNum, 1);
PSNR_List_LSB_pair = zeros(imageNum, 1);
PSNR_List_LSB_pair1 = zeros(imageNum, 1);

KL_List_LSB = zeros(imageNum, 1);
KL_List_LSB_DES = zeros(imageNum, 1);
KL_List_LSB_pair = zeros(imageNum, 1);
KL_List_LSB_pair1 = zeros(imageNum, 1);

Hae_List_LSB = zeros(imageNum, 1);
Hae_List_LSB_DES = zeros(imageNum, 1);
Hae_List_LSB_pair = zeros(imageNum, 1);
Hae_List_LSB_pair1 = zeros(imageNum, 1);

Image_List = cell(imageNum, 1);

for i = 1: imageNum
    hostImage = imageList(i).name;
    index = strfind(hostImage, '.');                        %index is the same is image name
    imageName = hostImage(1:index - 1);
    fprintf('===========================================\n');
    fprintf('imageNum: %d\n',imageNum);
    fprintf('i: %d\n',i);
    fprintf('hostImage: %d\n',hostImage);
    fprintf('index: %d\n',index);
    fprintf('imageName: %d\n',imageName);
    fprintf('===========================================\n');
    Image_List{i} = imageName;
    hostImage = strcat('grayscale photo\', hostImage);      %hostImage = path
    [hieght, width] = LSB_embed(hostImage, 'watermark.txt', strcat('LSB photo\', strcat(imageName, '.png')));
    LSB_extract(hieght, width, strcat('LSB photo\', strcat(imageName, '.png')), strcat('extract\',strcat(imageName, '.txt')));

    [hieght, width] = LSB_embed(hostImage, 'watermark_DES.txt', strcat('LSB-DES photo\', strcat(imageName, '.png')));
    LSB_extract(hieght, width, strcat('LSB-DES photo\', strcat(imageName, '.png')), strcat('extract_DES\',strcat(imageName, '.txt')));

    [hieght, width] = LSB_pair(hostImage, 'watermark_DES.txt', strcat('LSB-pair photo\', strcat(imageName, '.png')));
    LSB_extract(hieght, width, strcat('LSB-pair photo\', strcat(imageName, '.png')), strcat('extract_pair\',strcat(imageName, '.txt')));

    [hieght, width] = LSB_pair_1(hostImage, 'watermark_DES.txt', strcat('LSB-pair1 photo\', strcat(imageName, '.png')));
    LSB_extract(hieght, width, strcat('LSB-pair1 photo\', strcat(imageName, '.png')), strcat('extract_pair1\',strcat(imageName, '.txt')));

    % read host image
    hostImg = imread(hostImage);
    watermarkedImg = imread(strcat('LSB photo\', strcat(imageName, '.png')));
    watermarkedImg_DES = imread(strcat('LSB-DES photo\', strcat(imageName, '.png')));
    watermarkedImg_pair = imread(strcat('LSB-pair photo\', strcat(imageName, '.png')));
    watermarkedImg_pair_1 = imread(strcat('LSB-pair1 photo\', strcat(imageName, '.png')));

    % PSNR
    PSNR1 = PSNR(hostImg, watermarkedImg);
    PSNR1_DES = PSNR(hostImg, watermarkedImg_DES);
    PSNR1_pair = PSNR(hostImg, watermarkedImg_pair);
    PSNR1_pair_1 = PSNR(hostImg, watermarkedImg_pair_1);
    
    fprintf('PSNR without DES: %d\n', PSNR1);
    PSNR_List_LSB(i) = PSNR1;
    fprintf('PSNR with DES: %d\n', PSNR1_DES);
    PSNR_List_LSB_DES(i) = PSNR1_DES;
    fprintf('PSNR_pair: %d\n', PSNR1_pair);
    PSNR_List_LSB_pair(i) = PSNR1_pair;
    fprintf('PSNR_pair_1: %d\n', PSNR1_pair_1);
    PSNR_List_LSB_pair1(i) = PSNR1_pair_1;

    % K-L divergence
    KL1 = KL(hostImg, watermarkedImg);
    KL1_DES = KL(hostImg, watermarkedImg_DES);
    KL1_pair = KL(hostImg, watermarkedImg_pair);
    KL1_pair_1 = KL(hostImg, watermarkedImg_pair_1);
    
    fprintf('K-L divergence without DES: %d\n', KL1);
    KL_List_LSB(i) = KL1;
    fprintf('K-L divergence with DES: %d\n', KL1_DES);
    KL_List_LSB_DES(i) = KL1_DES;
    fprintf('K-L divergence pair: %d\n', KL1_pair);
    KL_List_LSB_pair(i) = KL1_pair;
    fprintf('K-L divergence pair_1: %d\n', KL1_pair_1);
    KL_List_LSB_pair1(i) = KL1_pair_1;
    

    % Hm[n]
    Hmx = 0:255;
    Hm = Hae(hostImg, watermarkedImg);
    Hm_DES = Hae(hostImg, watermarkedImg_DES);
    Hm_pair = Hae(hostImg, watermarkedImg_pair);
    Hm_pair_1 = Hae(hostImg, watermarkedImg_pair_1);

    % Hae
    Hm1 = abs(Hm);
    Hm_DES1 = abs(Hm_DES);
    Hm_pair1 = abs(Hm_pair);
    Hm_pair1_1 = abs(Hm_pair_1);
    
    fprintf('Hae without DES: %d\n', sum(Hm1));
    Hae_List_LSB(i) = sum(Hm1);
    fprintf('Hae with DES: %d\n', sum(Hm_DES1));
    Hae_List_LSB_DES(i) = sum(Hm_DES1);
    fprintf('Hae pair: %d\n', sum(Hm_pair1));
    Hae_List_LSB_pair(i) = sum(Hm_pair1);
    fprintf('Hae pair_1: %d\n', sum(Hm_pair1_1));
    Hae_List_LSB_pair1(i) = sum(Hm_pair1_1);
end

PSNR_header = {'Image Name', 'LSB', 'LSB-DES', 'LSB-pair', 'LSB-pair1'};
PSNR_List = [PSNR_List_LSB, PSNR_List_LSB_DES, PSNR_List_LSB_pair, PSNR_List_LSB_pair1];
xlswrite('PSNR.xlsx', PSNR_header);
xlswrite('PSNR.xlsx', Image_List, 'Sheet1', 'A2');
xlswrite('PSNR.xlsx', PSNR_List, 'Sheet1', 'B2');

KL_header = {'Image Name', 'LSB', 'LSB-DES', 'LSB-pair', 'LSB-pair1'};
KL_List = [KL_List_LSB, KL_List_LSB_DES, KL_List_LSB_pair, KL_List_LSB_pair1];
xlswrite('KL.xlsx', KL_header);
xlswrite('KL.xlsx', Image_List, 'Sheet1', 'A2');
xlswrite('KL.xlsx', KL_List, 'Sheet1', 'B2');

Hae_header = {'Image Name', 'LSB', 'LSB-DES', 'LSB-pair', 'LSB-pair1'};
Hae_List = [Hae_List_LSB, Hae_List_LSB_DES, Hae_List_LSB_pair, Hae_List_LSB_pair1];
xlswrite('Hae.xlsx', Hae_header);
xlswrite('Hae.xlsx', Image_List, 'Sheet1', 'A2');
xlswrite('Hae.xlsx', Hae_List, 'Sheet1', 'B2');

error_List = cell(imageNum, 1);
x = 1;
for j = 1:imageNum
    if KL_List_LSB_DES(j) < KL_List_LSB_pair1(j)
        error_List{x} = Image_List{j};
        x = x + 1;
    end
end

% hostImage = 'dog.png';
% [hieght, width] = LSB_embed(hostImage, 'watermark.txt', 'watermarked.png');
% LSB_extract(hieght, width, 'watermarked.png', 'extract.txt');
% 
% [hieght, width] = LSB_embed(hostImage, 'watermark_DES.txt', 'watermarked_DES.png');
% LSB_extract(hieght, width, 'watermarked_DES.png', 'extract_DES.txt');
% 
% [hieght, width] = LSB_pair(hostImage, 'watermark_DES.txt', 'watermarked_pair.png');
% LSB_extract(hieght, width, 'watermarked_pair.png', 'extract_pair.txt');
% 
% [hieght, width] = LSB_pair_1(hostImage, 'watermark_DES.txt', 'watermarked_pair_1.png');
% LSB_extract(hieght, width, 'watermarked_pair_1.png', 'extract_pair_1.txt');
% 
% % read host image
% hostImg = imread(hostImage);
% watermarkedImg = imread('watermarked.png');
% watermarkedImg_DES = imread('watermarked_DES.png');
% watermarkedImg_pair = imread('watermarked_pair.png');
% watermarkedImg_pair_1 = imread('watermarked_pair_1.png');
% 
% % PSNR
% PSNR1 = PSNR(hostImg, watermarkedImg);
% PSNR1_DES = PSNR(hostImg, watermarkedImg_DES);
% PSNR1_pair = PSNR(hostImg, watermarkedImg_pair);
% PSNR1_pair_1 = PSNR(hostImg, watermarkedImg_pair_1);
% fprintf('PSNR without DES: %d\n', PSNR1);
% fprintf('PSNR with DES: %d\n', PSNR1_DES);
% fprintf('PSNR_pair: %d\n', PSNR1_pair);
% fprintf('PSNR_pair_1: %d\n', PSNR1_pair_1);
% 
% % K-L divergence
% KL1 = KL(hostImg, watermarkedImg);
% KL1_DES = KL(hostImg, watermarkedImg_DES);
% KL1_pair = KL(hostImg, watermarkedImg_pair);
% KL1_pair_1 = KL(hostImg, watermarkedImg_pair_1);
% fprintf('K-L divergence without DES: %d\n', KL1);
% fprintf('K-L divergence with DES: %d\n', KL1_DES);
% fprintf('K-L divergence pair: %d\n', KL1_pair);
% fprintf('K-L divergence pair_1: %d\n', KL1_pair_1);
% 
% % Hm[n]
% Hmx = 0:255;
% Hm = Hae(hostImg, watermarkedImg);
% Hm_DES = Hae(hostImg, watermarkedImg_DES);
% Hm_pair = Hae(hostImg, watermarkedImg_pair);
% Hm_pair_1 = Hae(hostImg, watermarkedImg_pair_1);
% 
% % Hae
% Hm1 = abs(Hm);
% Hm_DES1 = abs(Hm_DES);
% Hm_pair1 = abs(Hm_pair);
% Hm_pair1_1 = abs(Hm_pair_1);
% fprintf('Hae without DES: %d\n', sum(Hm1));
% fprintf('Hae with DES: %d\n', sum(Hm_DES1));
% fprintf('Hae pair: %d\n', sum(Hm_pair1));
% fprintf('Hae pair: %d\n', sum(Hm_pair1_1));
% 
% figure(1);
% subplot(2, 3, 1);
% imshow(hostImg, []);
% title('Host image');
% subplot(2, 3, 2);
% imshow(watermarkedImg, []);
% title('LSB');
% subplot(2, 3, 3);
% imshow(watermarkedImg_DES, []);
% title('LSB-DES');
% subplot(2, 3, 4);
% imshow(watermarkedImg_pair, []);
% title('LSB-pair');
% subplot(2, 3, 5);
% imshow(watermarkedImg_pair_1, []);
% title('LSB-pair_1');
% 
% figure(2);
% subplot(2, 2, 1);
% plot(Hmx, Hm, '-');
% axis([0 300 -1000 1000])
% title('LSB');
% xlabel('Gray level');
% ylabel('Difference');
% 
% subplot(2, 2, 2);
% plot(Hmx, Hm_DES, '-');
% axis([0 300 -1000 1000])
% title('LSB-DES');
% xlabel('Gray level');
% ylabel('Difference');
% 
% subplot(2, 2, 3);
% plot(Hmx, Hm_pair, '-');
% axis([0 300 -1000 1000])
% title('LSB-pair');
% xlabel('Gray level');
% ylabel('Difference');
% 
% subplot(2, 2, 4);
% plot(Hmx, Hm_pair_1, '-');
% axis([0 300 -1000 1000])
% title('LSB-pair_1');
% xlabel('Gray level');
% ylabel('Difference');