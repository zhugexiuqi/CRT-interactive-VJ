#static image scalling test
在处理动态输入的视频流数据前，我们先用一张静态的1920*1080图像进行scalling算法测试。

我让GEMINI给出脚本用于生成4张用于测试的1920*1080，RGB三通道，每通道8位的测试图。

包括一张FHD测试图、一张黑白棋盘格、一张彩色渐变棋盘格、一张黑白彩色拼棋盘格。

然后，scalling.m 脚本将**根据之前生成的行索引和权重表格**，去进行插值计算，并输出缩小后的图。

这里我用该脚本测试了将fhd和黑白、彩虹、混合的checkboard从1920* 1080缩小到640*480。对比如下，上面为原图，下面为缩放后的图：

<img width="192" height="108" alt="checkerboard_bw_1080p" src="https://github.com/user-attachments/assets/1abc9f1d-7232-41b3-915d-a51faad2a2ce" />


<img width="64" height="48" alt="output_cb_bw" src="https://github.com/user-attachments/assets/ba716149-d348-40b6-922c-85dd972ece0b" />


<img width="192" height="108" alt="checkerboard_rainbow_1080p" src="https://github.com/user-attachments/assets/c73c2257-069f-409e-9e1d-aee6cfd4a6fd" />

<img width="64" height="48" alt="output_cb_rainbow" src="https://github.com/user-attachments/assets/92be71a7-c8e7-4fbe-84bf-2a1fcf439ae6" />


<img width="192" height="108" alt="checkerboard_combined_1080p" src="https://github.com/user-attachments/assets/3bd80313-8557-4d20-a246-671930ea20cb" />


<img width="64" height="48" alt="output_cb_combined" src="https://github.com/user-attachments/assets/4347c812-5804-484b-a060-d42ccda4c498" />

<img width="192" height="108" alt="fhd" src="https://github.com/user-attachments/assets/aa2bf21a-6fb3-4b99-831e-6152841a6d7c" />

<img width="64" height="48" alt="output_fhd" src="https://github.com/user-attachments/assets/42ffa617-8ddc-400a-a7a7-d0498e819d9a" />

通过查看属性可以得知，图像确实被准确地由1920*1080像素被缩放到了640 *480像素。

<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/2d43d415-a08d-414f-8bd9-07ac93af7cc2" />

<img width="200" height="400" alt="image" src="https://github.com/user-attachments/assets/f57f6e10-f6b2-4a74-b046-53f3df013538" />

**但是，** 这里出现了一个显而易见的问题：**图像的长宽比例发生了改变！**，由于CRT显示器更“胖”导致画面被拉伸了。

如果我们希望保持画面比例的正确，**屏幕的上下方就要留有黑边**。而且这会引入另一个问题，如果我们为画面植入黑边，就需要等待原图像传输完一帧后开始
向CRT传输植入了黑边的画面。这就意味着显示器至少要有一帧的延迟。而目前可以做到仅有传递两行像素所需时间的延迟，也就是**2/1080 *T**的延迟。
