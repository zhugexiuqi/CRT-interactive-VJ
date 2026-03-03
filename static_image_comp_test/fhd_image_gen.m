%% FPGA 图像缩放测试图生成器 (1920x1080)
clear; clc;

width = 1920;
height = 1080;

% 1. 创建背景（深灰色）
img = uint8(ones(height, width, 3) * 40);

% 2. 绘制背景棋盘格 (64x64 像素块)
% 棋盘格有助于检查缩放后的几何畸变
grid_size = 64;
for y = 1:height
    for x = 1:width
        if mod(floor((y-1)/grid_size) + floor((x-1)/grid_size), 2) == 0
            img(y, x, :) = img(y, x, :) + 20; % 浅灰色块
        end
    end
end

% 3. 绘制中心同心圆 (用于检查缩放后的锯齿和圆度)
[X, Y] = meshgrid(1:width, 1:height);
centerX = width/2;
centerY = height/2;
dist = sqrt((X - centerX).^2 + (Y - centerY).^2);
% 每 40 像素一个圆环
circle_mask = mod(floor(dist/40), 2) == 0;
for c = 1:3
    channel = img(:,:,c);
    channel(circle_mask & (dist < 400)) = 200; % 白色圆环
    img(:,:,c) = channel;
end

% 4. 绘制 RGB 三原色渐变条 (检查位深和色彩还原)
% 红色条 (顶部)
img(100:200, 200:1720, 1) = repmat(uint8(linspace(0, 255, 1521)), 101, 1);
% 绿色条 (中间)
img(height-200:height-100, 200:1720, 2) = repmat(uint8(linspace(0, 255, 1521)), 101, 1);

% 5. 绘制 1 像素宽的十字中心线 (最严苛的抽取测试)
% 如果你的抽取算法错位，这些线会断裂或消失
img(centerY, :, :) = 255; % 水平白线
img(:, centerX, :) = 255; % 垂直白线

% 6. 在四个角放置色块 (检查边界裁剪)
img(1:100, 1:100, 1) = 255;       % 左上红
img(1:100, end-99:end, 2) = 255;   % 右上绿
img(end-99:end, 1:100, 3) = 255;   % 左下蓝
img(end-99:end, end-99:end, :) = 255; % 右下白

% 7. 保存并检查
imwrite(img, 'fpga_test_pattern_1080p.png');
imshow(img);
title('1920x1080 RGB 8-bit Engineering Test Pattern');

% 输出格式确认
info = imfinfo('fpga_test_pattern_1080p.png');
fprintf('生成成功！\n分辨率: %d x %d\n位深: %d-bit\n', info.Width, info.Height, info.BitDepth);