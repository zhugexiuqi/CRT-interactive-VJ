#HDMI_receive_test.md

HDMI的信号时序实际上和DVI类似（所不同的只是在静默期插入了音频等其它信号）。

HDMI另一个不同是，其RGB通道的数据均采用了TMDS编码。这种编码是为了提高信号的物理传输质量。

HDMI解码芯片的功能就是将**串行的、TMDS编码的**RGB通道数据解码为并行的RGB通道数据。HDMI的同步时钟信号被编码在BLUE通道中。

下面是资料链接：

模块板：https://bigpig.ongridea.com/wai-she-tu-xiang-3-hdmi-shu-ru-jie-ma-mo-kuai-adv7611

ADV7611 Data Sheet:chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.analog.com/media/en/technical-documentation/data-sheets/adv7611.pdf

ADV7611 User Guide:chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.analog.com/media/en/technical-documentation/user-guides/UG-180.pdf

HDMI接收模块引脚定义：

<img width="368" height="378" alt="image" src="https://github.com/user-attachments/assets/8c366754-5df8-45e1-b3b0-30ea921df1f4" />

首先分析模块所引出的引脚，可以分为以下几类：

1.PIN1、PIN2，5V和GND

2.PIN3-PIN26，共24个引脚。这是解码后并行的视频数据。如果我们采用RGB表示，则一个颜色通道使用8位无符号数表示，3个通道共24位。不同的色彩表示法下，这24个引脚的输出定义是不同的。
**因此需要先配置寄存器将ADV7611输出规定为RGB4:4:4格式。** 查阅ADV7611 User Guide可知，需要将OP_FORMAT_SEL寄存器的值配置为0x40(64)。

此时，RED通道：P16 - P23

GREEN通道：P8 - P15

BLUE通道：P0 - P7

<img width="1304" height="966" alt="image" src="https://github.com/user-attachments/assets/e752abd3-42b9-4329-82ac-f3b3cdbf9a8a" />


ADV7611引脚定义：
<img width="991" height="628" alt="image" src="https://github.com/user-attachments/assets/8814f437-a989-4ac4-b0de-7b11da0ea39c" />
