function [ H_binWatermark, W_binWatermark ] = LSB_pair_ultra(hostFileName, watermarkFileName, watermarkedImgFileName )
%LSB_PIAR Summary of this function goes here

% read host image
hostImg = imread(hostFileName);

% get the height and width of host image
H = size(hostImg, 1);
W = size(hostImg, 2);

% read watermark file
watermarkFile = fopen(watermarkFileName, 'r');
watermark = fgets(watermarkFile);
fclose(watermarkFile);

% transform watermark to binary
binWatermark = dec2bin(watermark);

% get the height and width of binary watermark
H_binWatermark = size(binWatermark, 1);%6219
W_binWatermark = size(binWatermark, 2);%14

% compare the size between host image and watermark
imageSize = H *W;
messageSize = H_binWatermark*W_binWatermark;
if imageSize < messageSize
    error('Watermark is too large to embed!');
end

% embedding process
r = 1; % row
c = 1; % column
watermarkedImg = hostImg;

k = 0;
flag = false;

hMessage = 1;
wMessage = 1;
sameNum = 0;
maxSameNum = 0;
currentWPos1 = 1;
currentHPos1 = 1;
bestWPos = 1;
bestHPos = 1;
breakFlag = 0;
breakFlag2 = 0;
matchCount = 0;
for currentHPos1 = 1:H
    for currentWPos1 = 1:W
        sameNum = 0;
        wMessage = 1;
        hMessage = 1;
        breakFlag = 0;
        
        for cImage = currentHPos1:H
            for rImage = currentWPos1:W
                %fprintf('hMessage: %d      ', wMessage);
                if str2double(binWatermark(hMessage, wMessage)) == mod(double(watermarkedImg(r, c)),2)
                    sameNum = sameNum + 1;
                end
                
                wMessage = wMessage + 1;
                
                if wMessage == W_binWatermark && hMessage == H_binWatermark
                    breakFlag = 1;
                end
                if wMessage > W_binWatermark
                    wMessage = 1;
                    hMessage = hMessage + 1;
                end
                
                if breakFlag == 1
                    break;
                end
            end%end first r
            
            if breakFlag == 1
                break;
            end
        end%end frst c
        
        fprintf('MaxSameNumber: %d\n      ', maxSameNum);
        fprintf('SameNumber: %d\n      ', matchCount);
        if sameNum > maxSameNum
            maxSameNum = sameNum;
            bestHPos = currentHPos1;
            bestWPos = currentWPos1;
        end
        
        matchCount = matchCount + 1;
        if imageSize - matchCount < messageSize
            breakFlag2 = 1;
        end
        if breakFlag2 == 1
            break;
        end
        
        %         fprintf('Processing: %d      ', double((currentHPos1*currentWPos1)/(H*W)));
    end
    
    if breakFlag2 == 1
        break;
    end
end
fprintf('MaxSameNumber: %d      ', maxSameNum);
fprintf('Hpos: %d; WPOS: %d      ', bestHPos,bestWPos);







for i = 1:H_binWatermark
    for j = 1:W_binWatermark
        n = str2double(binWatermark(i, j)); % get the bit from watermark
        
        if flag == true
            flag = false;
            watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);
            c = c + 1; % move to next pixel
            
            if c > W % if this is the last pixel of this column
                r = r + 1; % move to next row
                c = 1; % column reset
            end
            continue;
        end
        
        if i == H_binWatermark && j == W_binWatermark
            watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);
            continue;%end iteration
        end
        pair = false;%reset LSBpair
        pixel = double(watermarkedImg(r, c)); % the gray level of current pixel
        
        %if current column is the last one
        if c == W
            next_pixel = double(watermarkedImg(r + 1, 1));
            %             if j  == W_binWatermark
            %                 next_n = str2double(binWatermark(i + 1, 1));
            %             else
            %                 next_n = str2double(binWatermark(i, j + 1));
            %             end
            if (mod(pixel, 2) == 1 && next_pixel == pixel - 1 && n == 0)||(mod(pixel, 2) == 0 && next_pixel == pixel + 1 && n == 1)
                watermarkedImg(r, c) = next_pixel;
                watermarkedImg(r + 1, 1) = pixel;
                pair = true;
            end
            
            %if normal case
        else
            next_pixel = double(watermarkedImg(r, c + 1));
            %             if j  == W_binWatermark
            %                 next_n = str2double(binWatermark(i + 1, 1));
            %             else
            %                 next_n = str2double(binWatermark(i, j + 1));
            %             end
            if (mod(pixel, 2) == 1 && next_pixel == pixel - 1 && n == 0)||(mod(pixel, 2) == 0 && next_pixel == pixel + 1 && n == 1)
                watermarkedImg(r, c) = next_pixel;
                watermarkedImg(r, c + 1) = pixel;
                pair = true;
            end
        end
        watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);
        
        if pair == true
            k = k + 1;
            flag = true;
        end
        
        c = c + 1; % move to next pixel
        % if this is the last pixel of this row
        if c > W
            r = r + 1; % move to next row
            c = 1; % column reseted
        end
    end
end

% fprintf("i0: %d, j0: %d     ",i,j);
% add stop byte
for i = 1:15
    watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, 0);
    c = c + 1; % move to next pixel
    if c > W
        r = r + 1; % move to next row
        c = 1; % column reseted
    end
end

% output the watermarked image
imwrite(watermarkedImg, watermarkedImgFileName, 'png');


end

