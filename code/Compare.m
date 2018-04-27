function [BestMatchStartBit] = Compare(hostFileName, watermarkFileName)

BestMatchStartBit = 0;

hostImg = imread(hostFileName);
H = size(hostImg, 1);
W = size(hostImg, 2);

watermarkFile = fopen(watermarkFileName, 'r');
watermark = fgets(watermarkFile);
fclose(watermarkFile);
binWatermark = dec2bin(watermark);

H_binWatermark = size(binWatermark, 1);%6219
W_binWatermark = size(binWatermark, 2);%14

if H * W < H_binWatermark * W_binWatermark
    error('Watermark is too large to embed!');
end

r = 1; % row
c = 1; % column
% watermarkedImg = hostImg;

k = 0;
flag = false;
for i = 1:H_binWatermark
    for j = 1:W_binWatermark
        n = str2double(binWatermark(i, j)); % get the bit from watermark
        
        if i == H_binWatermark && j == W_binWatermark
            continue;%end iteration
        end

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

        
        c = c + 1; % move to next pixel
        % if this is the last pixel of this row
        if c > W
            r = r + 1; % move to next row
            c = 1; % column reseted
        end
    end
end
