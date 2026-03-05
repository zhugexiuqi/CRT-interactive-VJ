#I2C_DRI_REFAC

本文件夹中包含的两个.v文件是重构后的I2C Driver和I2C Configurationer.

我使用了正点原子例程给出的Driver和Configurationer.其中，Driver负责建立I2C通信时序列，也就是说，Driver模块将被编程为一个I2C主机。Configurationer则负责告诉Driver，对I2C从机设备写入什么数据。Driver和Configurationer需要配合使用——这类似于近代，一个人口述内容而电报员敲击发送莫斯电码：前者Configurate负责决定传输什么数据，传输到哪里（哪个从机设备、从机设备哪个寄存器地址），后者Driver负责建立符合规范的通信接口。

但是正点原子的代码有两个不符合当前项目需求的地方：

1.Driver模块的从机设备地址是一个Parameter。也就是说，这个模块一旦被声明，其从机地址就是不能改变的。而ADV7611芯片，其I2C总线上有多个从机地址：ADV7611芯片内部不同的模块被视为I2C总线上的不同设备。各个模块的地址是可编程的。模块的设备地址存储在0x98寄存器中，具体见下表（模块地址的推荐值）：

<img width="806" height="353" alt="image" src="https://github.com/user-attachments/assets/ffbc994a-f078-45ee-96d5-d8f37384ea93" />

因此，Driver模块相当于需要和多个不同的设备（ADV7611中的不同模块）通信。故其SLAVE_ADDR不能是parameter，而需要是input。

2.Config模块中，具体写入的寄存器地址、写入数值是直接写在状态机的Verilog代码里的。这显然不适应项目的变化，以及有很多寄存器需要配置的情况。我们需要这样修改，让Config模块读取编辑好的、存储了I2C配置数据的ROM文件。

我们定义MIF文件格式如下：WIDTH = 24，DEPTH为所需配置的寄存器变量个数。

第一个字节：从机设备地址

第二个字节：寄存器地址

第三个字节：写入数据

width=24;
depth=30;
address_radix=DEC;
data_radix=HEX;
Content Begin

...

end;

**还有一个未来需要修改的点是，移植到XLINX平台后，ROM IP需要更改。**
