% 参数设置
src_h = 1080;
dst_h = 480;
scale = src_h / dst_h; % 2.25

% 数据存储初始化
lut_y_idx = zeros(dst_h, 1);    % 触发行索引 (int)
lut_w_pre = zeros(dst_h, 1);    % 前权重 (int, 0-256)
lut_w_post = zeros(dst_h, 1);   % 后权重 (int, 0-256)
txt_data = zeros(dst_h, 5);     % 用于txt展示: [y_src, y_pre, w_pre, y_post, w_post]

for y_out = 1 : dst_h
    % 1. 逆映射计算 (中心对齐)
    y_src = (y_out - 0.5) * scale + 0.5;
    
    % 2. 找到相邻行
    y_pre = floor(y_src);
    y_post = y_pre + 1;
    
    % 3. 边界处理
    if y_pre < 1, y_pre = 1; y_post = 2; end
    if y_post > src_h, y_post = src_h; y_pre = src_h - 1; end
    
    % 4. 计算权重 (Q8定点化)
    dy = y_src - y_pre;
    w_post_val = round(dy * 256);
    w_pre_val  = 256 - w_post_val;
    
    % 存储数据
    lut_y_idx(y_out) = y_post; 
    lut_w_pre(y_out) = w_pre_val;
    lut_w_post(y_out) = w_post_val;
    
    % 存储展示用的 txt 数据
    txt_data(y_out, :) = [y_src, y_pre, w_pre_val, y_post, w_post_val];
end

%% 2. 输出 MIF 文件函数
writeMif('lut_y_idx.mif', lut_y_idx, 11);   % 1080需要11位宽
writeMif('lut_w_pre.mif', lut_w_pre, 9);    % 256需要9位宽
writeMif('lut_w_post.mif', lut_w_post, 9);

%% 3. 输出展示 TXT 文件
fid = fopen('mapping_detail.txt', 'w');
fprintf(fid, 'Target_Y | Src_Y_Float | Pre_Idx | Pre_Weight | Post_Idx | Post_Weight\n');
fprintf(fid, '----------------------------------------------------------------------\n');
for i = 1:dst_h
    fprintf(fid, '%8d | %11.4f | %7d | %10d | %8d | %11d\n', ...
            i, txt_data(i,1), txt_data(i,2), txt_data(i,3), txt_data(i,4), txt_data(i,5));
end
fclose(fid);

disp('所有文件（3个mif，1个txt）已生成完成。');

%% 辅助函数：生成 MIF 格式
function writeMif(filename, data, width)
    depth = length(data);
    fid = fopen(filename, 'w');
    fprintf(fid, 'WIDTH=%d;\n', width);
    fprintf(fid, 'DEPTH=%d;\n\n', depth);
    fprintf(fid, 'ADDRESS_RADIX=UNS;\n');
    fprintf(fid, 'DATA_RADIX=UNS;\n\n');
    fprintf(fid, 'CONTENT BEGIN\n');
    for i = 0:depth-1
        fprintf(fid, '    %d : %d;\n', i, data(i+1));
    end
    fprintf(fid, 'END;\n');
    fclose(fid);
end