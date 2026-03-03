%% FPGA 垂直缩放 LUT 生成器 (行索引 + 8位权重)
clear; clc;

src_h = 1080;
dst_h = 480;

% 计算步长 (Corner Alignment)
step_y = (src_h - 1) / (dst_h - 1); 

% 初始化
lut_y_idx   = zeros(dst_h, 1); 
lut_w_pre   = zeros(dst_h, 1); 
lut_w_post  = zeros(dst_h, 1); 

for j = 0:dst_h-1
    src_f = j * step_y;
    
    % 确定原图行索引 (后点)
    p1 = ceil(src_f);
    if p1 == 0, p1 = 1; end % 边界处理
    
    % 计算 8 位权重 (0~255)
    weight_f = src_f - (p1 - 1); 
    w_post = min(round(weight_f * 256), 255);
    w_pre  = 256 - w_post; % 注意：w_pre 可能为 256，硬件需处理或在此限幅
    
    lut_y_idx(j+1)  = p1;    % 原图行索引 (后点坐标)
    lut_w_post(j+1) = w_post;
    lut_w_pre(j+1)  = min(w_pre, 255); % 限幅到 8 位
end

% --- 导出 TXT (供人工直接查看) ---
% 格式：[行号] [索引] [前权] [后权]
fid_txt = fopen('lut_row_debug.txt', 'w');
fprintf(fid_txt, 'Dst_Row | Src_Idx | W_Pre | W_Post\n');
fprintf(fid_txt, '---------------------------------\n');
for i = 1:dst_h
    fprintf(fid_txt, '%7d | %7d | %5d | %6d\n', i-1, lut_y_idx(i), lut_w_pre(i), lut_w_post(i));
end
fclose(fid_txt);

% --- 导出 MIF (供 FPGA 调用) ---
write_mif('lut_y_idx.mif',   lut_y_idx,  11);
write_mif('lut_y_w_pre.mif',  lut_w_pre,  8);
write_mif('lut_y_w_post.mif', lut_w_post, 8);

disp('文件生成完毕：lut_row_debug.txt, lut_y_idx.mif, lut_y_w_pre.mif, lut_y_w_post.mif');

function write_mif(filename, data, width)
    depth = length(data);
    fid = fopen(filename, 'w');
    fprintf(fid, 'WIDTH=%d;\nDEPTH=%d;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\n\nCONTENT BEGIN\n', width, depth);
    for k = 0:depth-1
        fprintf(fid, '    %d : %d;\n', k, data(k+1));
    end
    fprintf(fid, 'END;\n');
    fclose(fid);
end