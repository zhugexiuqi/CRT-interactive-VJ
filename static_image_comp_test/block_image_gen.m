%% FPGA 视频缩放测试图生成器 (1920x1080)
clear; clc;

width = 1920;
height = 1080;

% 定义格子大小：水平 120 (1920/120=16格), 垂直 120 (1080/120=9格)
% 这个尺寸能确保格子在水平 3:1 抽取后依然保持整格，不出现 1/3 格的情况。
block_size = 120; 

% 建立坐标网格索引
[X, Y] = meshgrid(1:width, 1:height);
row_idx = floor((Y-1)/block_size);
col_idx = floor((X-1)/block_size);

%% --- 第一幅图：黑白棋盘格 (checkerboard_bw_1080p.png) ---
% 目的：检查边缘锐度、几何畸变和列使能相位。
fprintf('正在生成黑白棋盘图...\n');
img_bw = uint8(zeros(height, width, 3));

% 逻辑：行列索引之和为偶数则为白，奇数为黑
bw_mask = mod(row_idx + col_idx, 2) == 0;
bw_plane = uint8(bw_mask * 255); % 0或255

% 复制到 RGB 三个通道
img_bw = cat(3, bw_plane, bw_plane, bw_plane);

% 保存并显示
imwrite(img_bw, 'checkerboard_bw_1080p.png');
% figure; imshow(img_bw); title('Black & White Checkerboard (1920x1080)');

%% --- 第二幅图：彩虹渐变棋盘格 (checkerboard_rainbow_1080p.png) ---
% 目的：检查色彩位深、LUT 的行映射均匀性以及垂直权重计算是否正确。
fprintf('正在生成彩虹棋盘图...\n');

% 在 HSV 空间建立地图
% 计算 Hue 值：随列数变化而变色，并随行数变化增加偏移，确保平滑过渡
hue_map = mod((col_idx / (width/block_size)) + (row_idx * 0.13), 1);
sat_map = 0.8 * ones(size(hue_map)); % 饱和度
val_map = 0.9 * ones(size(hue_map)); % 亮度

% 整体转换 HSV -> RGB
hsv_combined = cat(3, hue_map, sat_map, val_map);
rgb_rainbow = hsv2rgb(hsv_combined) * 255; % 转换并缩放到 0-255

img_rainbow = uint8(rgb_rainbow);

% 保存并在新窗口显示
imwrite(img_rainbow, 'checkerboard_rainbow_1080p.png');
% figure; imshow(img_rainbow); title('Rainbow Gradient Checkerboard (1920x1080)');

%% --- 第三幅图：复合拼接棋盘格 (checkerboard_combined_1080p.png) ---
% 目的：上半部分检查几何，下半部分检查色彩。
fprintf('正在生成复合拼接图...\n');
img_combined = uint8(zeros(height, width, 3));

% 拼接位置：中线 (540行)
img_combined(1:height/2, :, :) = img_bw(1:height/2, :, :);
img_combined((height/2 + 1):end, :, :) = img_rainbow((height/2 + 1):end, :, :);

% 叠加 1 像素灰色十字中心线 (用于对齐参考)
img_combined(height/2, :, :) = 128; 
img_combined(:, width/2, :) = 128;

% 保存并在新窗口显示
imwrite(img_combined, 'checkerboard_combined_1080p.png');
figure; imshow(img_combined); 
title('Top: B&W | Bottom: Rainbow Gradient | Center: 1px Grid (1080p)');

fprintf('>>> 成功！三幅 $1920 \times 1080$ 测试图已全部生成并保存。\n');