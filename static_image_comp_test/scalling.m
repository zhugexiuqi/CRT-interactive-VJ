%读取图片并存入table
filename = 'fhd.png';
img = imread(filename);
R_plane = img(:,:,1);
G_plane = img(:,:,2);
B_plane = img(:,:,3);
T_Red   = array2table(R_plane);
T_Green = array2table(G_plane);
T_Blue  = array2table(B_plane);
colNames = arrayfun(@(x) sprintf('Col_%d', x), 1:size(R_plane,2), 'UniformOutput', false);
T_Red.Properties.VariableNames   = colNames;
T_Green.Properties.VariableNames = colNames;
T_Blue.Properties.VariableNames  = colNames;

%该脚本用于模拟真实的视频信号流动输入时，FPGA插值运算处理的时序
R_new = zeros(480, 640);
G_new = zeros(480, 640);
B_new = zeros(480, 640);

R_h_buffer = zeros(2, 640); %模拟行缓存寄存器，总是存储最近传入的两行的像素点值
G_h_buffer = zeros(2, 640); 
B_h_buffer = zeros(2, 640); 

y_idx_counter = 0; %该计数器用于统计行索引，实际上也就是wr_line_counter
rd_line_counter = 0;
rd_col_counter = 0;%列计数器该计数当前行中输入到了第几个数
wr_col_counter = 0;%这个列计数器用于统计缩小后的图像写入到了哪一列
mod3_counter = 0;%由于FPGA中进行mod计算会消耗较多逻辑资源，使用这个计数器避免mod计算，检测当前列数是否是3的倍数。范围只需0-2。

% i用于计数扫描到了哪一行，j用于计数扫描到了哪一列
for i = 0 : 1079 % DVI信号是按行扫描输入的
    R_h_buffer(1,:) = R_h_buffer(2,:); %模拟行缓存移位寄存器的行为。2表示最新一行，1表示次新一行。
    G_h_buffer(1,:) = G_h_buffer(2,:); %新的一行开始传输，刚才的最新一行就成了次新一行
    B_h_buffer(1,:) = B_h_buffer(2,:);
    for j = 0 : 1919
        if j==0    %维护列数计数器，在新的一行开始传输时，列计数器归零
            rd_col_counter = 0;
            wr_col_counter = 0;
            mod3_counter = 0;
        elseif mod3_counter == 2 %列计数器reg=2说明此时列数是3的倍数。然后，模拟reg的回绕。
            
            %需要注意MATLAB的矩阵从1开始。我们的计数器模拟Verilog从O开始
            R_h_buffer(2,wr_col_counter + 1) =  R_plane(i+1,rd_col_counter + 1);
            G_h_buffer(2,wr_col_counter + 1) =  G_plane(i+1,rd_col_counter + 1);
            B_h_buffer(2,wr_col_counter + 1) =  B_plane(i+1,rd_col_counter + 1);
            
            wr_col_counter = wr_col_counter + 1; %在一行640个输入完成后，理论上wr_col_counter将来到639
            
            mod3_counter = 0;
        else
            mod3_counter = mod3_counter + 1;
        end
        rd_col_counter = rd_col_counter + 1;
    end
    
    if rd_line_counter + 1 == lut_y_idx(y_idx_counter + 1)

        y_idx_counter = y_idx_counter + 1; %前进到下一个索引值
       
        %开始进行插值计算
        w_pre = lut_w_pre(y_idx_counter);
        w_post = lut_w_post(y_idx_counter);

        R_new(y_idx_counter,:) = w_pre.*R_h_buffer(1,:) + w_post.*R_h_buffer(2,:);
        R_new(y_idx_counter,:) = R_new(y_idx_counter,:) ./ 256; %注意是点乘，点除

        G_new(y_idx_counter,:) = w_pre.*G_h_buffer(1,:) + w_post.*G_h_buffer(2,:);
        G_new(y_idx_counter,:) = G_new(y_idx_counter,:) ./ 256; %注意是点乘，点除

        B_new(y_idx_counter,:) = w_pre.*B_h_buffer(1,:) + w_post.*B_h_buffer(2,:);
        B_new(y_idx_counter,:) = B_new(y_idx_counter,:) ./ 256; %注意是点乘，点除
    end
   
    rd_line_counter = rd_line_counter + 1;
end

img_combined = uint8(cat(3, R_new, G_new, B_new));

% 在窗口显示图片
imshow(img_combined);

% 保存为 PNG 文件
imwrite(img_combined, 'output_fhd.png');