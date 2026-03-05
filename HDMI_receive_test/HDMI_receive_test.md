#HDMI_receive_test.md

HDMI的信号时序实际上和DVI类似（所不同的只是在静默期插入了音频等其它信号）。

HDMI另一个不同是，其RGB通道的数据均采用了TMDS编码。这种编码是为了提高信号的物理传输质量。

HDMI解码芯片的功能就是将**串行的、TMDS编码的**RGB通道数据解码为并行的RGB通道数据。HDMI的同步时钟信号被编码在BLUE通道中。

下面是资料链接：

模块板：https://bigpig.ongridea.com/wai-she-tu-xiang-3-hdmi-shu-ru-jie-ma-mo-kuai-adv7611

ADV7611 Data Sheet:chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.analog.com/media/en/technical-documentation/data-sheets/adv7611.pdf

ADV7611 User Guide:chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.analog.com/media/en/technical-documentation/user-guides/UG-180.pdf
