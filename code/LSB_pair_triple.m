%===============================================================
%==========This is the LSB_pair_dual function===================
%=========The same as LSB-corssLine-pair in the thesis==========
%===============================================================

function [ H_binWatermark, W_binWatermark ] = LSB_pair_triple(hostFileName, watermarkFileName, watermarkedImgFileName)
%   Summary of this function
%   Detailed explanation goes here
%   This methods is trying to find pixel pairs between adjacent pixels and
%   the fist pixel with its the one after next pixel


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
if H * W < H_binWatermark * W_binWatermark
    error('Watermark is too large to embed!');
end

% embedding process
r = 1; % row
c = 1; % column
watermarkedImg = hostImg;

k = 0;
pair = false;
triplePair = false;
triplePair2 = false;
noTriplePairDetect = false;
distortion = zeros(1, 256);
count3 = 0;
for i = 1:H_binWatermark
    for j = 1:W_binWatermark
        n = str2double(binWatermark(i, j)); % get the bit from watermark
        
        if pair == true
            pair = false;
            triplePair = false;
            watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);
            c = c + 1; % move to next pixel
            if c > W % if this is the last pixel of this column
                r = r + 1; % move to next row
                c = 1; % column reset
            end
            continue;
        end
        
        %jump twice while detect triple pair
        if triplePair == true && triplePair2 == true
            triplePair = false;
            watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);
            c = c + 1;
            if c > W
                r = r + 1;
                c = 1;
            end
            continue;
        end
        if triplePair == false && triplePair2 == true
            triplePair2 = false;
            watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);
            c = c + 1;
            if c > W
                r = r + 1;
                c = 1;
            end
            continue;
        end
        
        if i == H_binWatermark && j == W_binWatermark
            watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);
            continue;%end iteration
        end
   
        
        pair = false;%reset LSBpair
        triplePair = false;
        triplePair2 = false;
        pixel = double(watermarkedImg(r, c)); % the gray level of current pixel
        
        
        if n ~= bitget(watermarkedImg(r, c), 1)
            %if current column is the last one
            if c == W
                next_pixel = double(watermarkedImg(r + 1, 1));
                if j  == W_binWatermark
                    next_n = str2double(binWatermark(i + 1, 1));
                else
                    next_n = str2double(binWatermark(i, j + 1));
                end
                
                if mod(pixel, 2) == 1 && next_pixel == pixel + 1
                    if next_n ~= mod(next_pixel, 2)
                        temp_dist = distortion;
                        temp_dist(pixel) = temp_dist(pixel) + 1;
                        temp_dist(pixel + 1) = temp_dist(pixel + 1) - 1;
                        temp_dist(pixel + 2) = temp_dist(pixel) - 1;
                        temp_dist(pixel + 3) = temp_dist(pixel) + 1;
                        if sum(abs(temp_dist)) >= sum(abs(distortion))
                            watermarkedImg(r, c) = next_pixel;
                            watermarkedImg(r + 1, 1) = pixel;
                            pair = true;
                            noTriplePairDetect = true;
                        end
                    end
                elseif mod(pixel, 2) == 0 && next_pixel == pixel - 1
                    if next_n ~= mod(next_pixel, 2)
                        temp_dist = distortion;
                        temp_dist(pixel + 1) = temp_dist(pixel + 1) - 1;
                        temp_dist(pixel + 2) = temp_dist(pixel + 2) + 1;
                        if sum(abs(temp_dist)) >= sum(abs(distortion))
                            watermarkedImg(r, c) = next_pixel;
                            watermarkedImg(r + 1, 1) = pixel;
                            pair = true;
                            noTriplePairDetect = true;
                        end
                    end
                end
                
            else %if normal case
                next_pixel = double(watermarkedImg(r, c + 1));
                if j  == W_binWatermark
                    next_n = str2double(binWatermark(i + 1, 1));
                else
                    next_n = str2double(binWatermark(i, j + 1));
                end                
                
                if mod(pixel, 2) == 1 && next_pixel == pixel + 1
                    if next_n ~= mod(next_pixel, 2)
                        temp_dist = distortion;
                        temp_dist(pixel) = temp_dist(pixel) + 1;
                        temp_dist(pixel + 1) = temp_dist(pixel + 1) - 1;
                        temp_dist(pixel + 2) = temp_dist(pixel) - 1;
                        temp_dist(pixel + 3) = temp_dist(pixel) + 1;
                        if sum(abs(temp_dist)) >= sum(abs(distortion))
                            watermarkedImg(r, c) = next_pixel;
                            watermarkedImg(r, c + 1) = pixel;
                            pair = true;
                            noTriplePairDetect = true;
                        end
                    end
                    
                elseif mod(pixel, 2) == 0 && next_pixel == pixel - 1
                    if next_n ~= mod(next_pixel, 2)
                        temp_dist = distortion;
                        temp_dist(pixel + 1) = temp_dist(pixel + 1) - 1;
                        temp_dist(pixel + 2) = temp_dist(pixel + 2) + 1;
                        if sum(abs(temp_dist)) >= sum(abs(distortion))
                            watermarkedImg(r, c) = next_pixel;
                            watermarkedImg(r, c + 1) = pixel;
                            pair = true;
                            noTriplePairDetect = true;
                        end
                    end
                end
                
            end % end if c == W
            
            %start triple pair detect
            if i == H_binWatermark && j == W_binWatermark - 1
                noTriplePairDetect = true;
            end
            if r == H - 1
                if (c == W - 1) || (c == W) 
                    noTriplePairDetect = true;
                end
            end
            if i  == H_binWatermark
                if (j  == W_binWatermark) || (j  == W_binWatermark - 1)
                    noTriplePairDetect = true;
                end
            end
            if (j == W_binWatermark) || (j == W_binWatermark - 1)
                noTriplePairDetect = true;
            end
            
            if noTriplePairDetect == true
                noTriplePairDetect = false;
            else
                if c == W
                    next_2pixel = double(watermarkedImg(r + 1, 2));
                elseif c == W -1
                    next_2pixel = double(watermarkedImg(r + 1, 1));
                else
                    next_2pixel = double(watermarkedImg(r, c + 2));
                end
                
                if j  == W_binWatermark
                    next_2n = str2double(binWatermark(i + 1, 2));
                else
                    if j == W_binWatermark - 1
                        next_2n = str2double(binWatermark(i + 1, 1));
                    else
                        next_2n = str2double(binWatermark(i, j + 2));
                    end
                end
                
                if (mod(pixel, 2) == 1 && next_2pixel == pixel + 1 && n == 0 && next_2n == 1)||(mod(pixel, 2) == 0 && next_2pixel == pixel - 1 && n == 1 && next_2n == 0)
                    if (mod(pixel, 2) == 1)
                        temp_dist = distortion;
                        temp_dist(pixel) = temp_dist(pixel) + 1;
                        temp_dist(pixel + 1) = temp_dist(pixel + 1) - 1;
                        temp_dist(pixel + 2) = temp_dist(pixel) - 1;
                        temp_dist(pixel + 3) = temp_dist(pixel) + 1;
                        if sum(abs(temp_dist)) >= sum(abs(distortion))
                            watermarkedImg(r, c) = next_2pixel;
                            if c == W - 1
                                watermarkedImg(r + 1, 1) = pixel;
                            elseif c == W
                                watermarkedImg(r + 1, 2) = pixel;
                            else
                                watermarkedImg(r, c + 2) = pixel;
                            end
                            triplePair = true;
                            triplePair2 = true;
                            count3 = count3 + 1;
                        end
                    end
                    if (mod(pixel, 2) == 0)
                        temp_dist = distortion;
                        temp_dist(pixel + 1) = temp_dist(pixel + 1) - 1;
                        temp_dist(pixel + 2) = temp_dist(pixel + 2) + 1;
                        if sum(abs(temp_dist)) >= sum(abs(distortion))
                            watermarkedImg(r, c) = next_2pixel;
                            if c == W - 1
                                watermarkedImg(r + 1, 1) = pixel;
                            elseif c == W
                                watermarkedImg(r + 1, 2) = pixel;
                            else
                                watermarkedImg(r, c + 2) = pixel;
                            end
                            triplePair = true;
                            triplePair2 = true;
                            count3 = count3 + 1;
                        end
                    end
                end
            end % end triple pair detection
            
            if (pair == true) || (triplePair == true && triplePair2 == true)
                k = k + 1;
            else
                if mod(pixel, 2) == 1
                    distortion(pixel + 1) = distortion(pixel + 1) - 1;
                    distortion(pixel) = distortion(pixel) + 1;
                else
                    distortion(pixel + 1) = distortion(pixel + 1) - 1;
                    distortion(pixel + 2) = distortion(pixel + 2) + 1;
                end
                watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, n);% change last bit if pair is true
            end
        end %end if message bit != pixel LSB
        
        c = c + 1; % move to next pixel
        % if this is the last pixel of this row
        if c > W
            r = r + 1; % move to next row
            c = 1; % column reseted
        end
        
        
    end
end
% fprintf("k: %d      ",k);
% fprintf("count3: %d      ",count3);

% fprintf("i0: %d, j0: %d     ",i,j);
% % add stop byte
% for i = 1:15
%     watermarkedImg(r, c) = bitset(watermarkedImg(r, c),1, 0);
%     c = c + 1; % move to next pixel
%     if c > W
%         r = r + 1; % move to next row
%         c = 1; % column reseted
%     end
% end

% output the watermarked image
imwrite(watermarkedImg, watermarkedImgFileName, 'png');

end

