`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz ʱ������
    input wire clk_11M0592,       //11.0592MHz ʱ�����루���ã��ɲ��ã�

    input wire clock_btn,         //BTN5�ֶ�ʱ�Ӱ�ť���أ���������·������ʱΪ1
    input wire reset_btn,         //BTN6�ֶ���λ��ť���أ���������·������ʱΪ1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4����ť���أ�����ʱΪ1
    input  wire[31:0] dip_sw,     //32λ���뿪�أ�������ON��ʱΪ1
    output wire[15:0] leds,       //16λLED�����ʱ1����
    output wire[7:0]  dpy0,       //����ܵ�λ�źţ�����С���㣬���1����
    output wire[7:0]  dpy1,       //����ܸ�λ�źţ�����С���㣬���1����

    //BaseRAM�ź�
    inout wire[31:0] base_ram_data,  //BaseRAM���ݣ���8λ��CPLD���ڿ���������
    output wire [19:0] base_ram_addr, //BaseRAM��ַ
    output wire [3:0] base_ram_be_n,  //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire base_ram_ce_n,       //BaseRAMƬѡ������Ч
    output wire base_ram_oe_n,       //BaseRAM��ʹ�ܣ�����Ч
    output wire base_ram_we_n,       //BaseRAMдʹ�ܣ�����Ч

    //ExtRAM�ź�
    inout wire [31:0] ext_ram_data,  //ExtRAM����
    output wire [19:0] ext_ram_addr, //ExtRAM��ַ
    output wire[3:0] ext_ram_be_n,  //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire ext_ram_ce_n,       //ExtRAMƬѡ������Ч
    output wire ext_ram_oe_n,       //ExtRAM��ʹ�ܣ�����Ч
    output wire ext_ram_we_n,       //ExtRAMдʹ�ܣ�����Ч

    //ֱ�������ź�
    output wire txd,  //ֱ�����ڷ��Ͷ�
    input  wire rxd,  //ֱ�����ڽ��ն�

    //Flash�洢���źţ��ο� JS28F640 оƬ�ֲ�
    output wire [22:0]flash_a,      //Flash��ַ��a0����8bitģʽ��Ч��16bitģʽ������
    inout  wire [15:0]flash_d,      //Flash����
    output wire flash_rp_n,         //Flash��λ�źţ�����Ч
    output wire flash_vpen,         //Flashд�����źţ��͵�ƽʱ���ܲ�������д
    output wire flash_ce_n,         //FlashƬѡ�źţ�����Ч
    output wire flash_oe_n,         //Flash��ʹ���źţ�����Ч
    output wire flash_we_n,         //Flashдʹ���źţ�����Ч
    output wire flash_byte_n,       //Flash 8bitģʽѡ�񣬵���Ч����ʹ��flash��16λģʽʱ����Ϊ1

    //ͼ������ź�
    output wire[2:0] video_red,    //��ɫ���أ�3λ
    output wire[2:0] video_green,  //��ɫ���أ�3λ
    output wire[1:0] video_blue,   //��ɫ���أ�2λ
    output wire video_hsync,       //��ͬ����ˮƽͬ�����ź�
    output wire video_vsync,       //��ͬ������ֱͬ�����ź�
    output wire video_clk,         //����ʱ�����
    output wire video_de           //��������Ч�źţ���������������
);

/* =========== Demo code begin =========== */
assign base_ram_be_n = 4'b0000;
assign ext_ram_be_n = 4'b0000;

// PLL��Ƶʾ��
wire locked, clk_98M, clk_500M;
reg clk_top;
reg clk_uart;
integer i;
reg [3:0] k;

pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // �ⲿʱ������
  // Clock out ports
  .clk_out1(clk_98M), // ʱ�����1��Ƶ����IP���ý���������
  .clk_out2(clk_500M), // ʱ�����2��Ƶ����IP���ý���������
  // Status and control signals
  .reset(reset_btn), // PLL��λ����
  .locked(locked)    // PLL����ָʾ�����"1"��ʾʱ���ȶ���
                     // �󼶵�·��λ�ź�Ӧ���������ɣ����£�
 );

reg reset_of_clk98M;
reg reset_of_clk500M;
reg reset_of_clktop;
// �첽��λ��ͬ���ͷţ���locked�ź�תΪ�󼶵�·�ĸ�λreset_of_clk98M
always@(posedge clk_98M or negedge locked) begin
    if(~locked) reset_of_clk98M <= 1'b1;
    else        reset_of_clk98M <= 1'b0;
end
always@(posedge clk_500M or negedge locked) begin
    if(~locked) reset_of_clk500M <= 1'b1;
    else        reset_of_clk500M <= 1'b0;
end

always@(posedge clk_500M or negedge locked) begin
    if(~locked) reset_of_clktop <= 1'b1;
    else        reset_of_clktop <= 1'b0;
end
/*
always @(posedge clk_500M) begin 
    if (reset_of_clk500M) begin 
        k <= 0;
        clk_top <= 1'b0;
    end
    else begin
         if (k < 4'd4) begin
            k <= k + 4'd1;
        end
        else begin 
            clk_top <= ~clk_top;
            k <= 4'd0;
        end
    end
end*/


always @(posedge clk_500M or posedge reset_of_clk500M) begin 
    if (reset_of_clk500M) begin 
        k <= 0;
        clk_top <= 1'b0;
    end
    else begin
     if (k < 4'd5) begin
        clk_top <= 1'b0;
        k <= k + 4'd1;
    end
    else if (k < 4'd9) begin 
        clk_top <= 1'b1;
        k <= k + 4'd1;
    end
    else begin 
        clk_top <= 1'b1;
        k <= 4'd0;
    end
    end
end

always @(posedge clk_98M) begin
    if (reset_of_clk98M) begin 
        i <= 0;
        clk_uart <= 1'b0;
    end
    else if (i < 5120) i <= i + 1;
    else begin 
        clk_uart <= ~clk_uart;
        i <= 0;
    end 
end

    wire ce;
    
    wire [31:0] ram_rdata;
    wire [31:0] dram_write_addr;
    wire [31:0] dram_read_addr;
    wire dwrite_ce;
    wire [31:0] wdata;
    wire dread_ce;
    wire rfin_a;
    wire wfin_a;
    wire rfin_c;
    wire iread_ce;
    wire [31:0] iram_addr;
    wire [31:0] ram_inst;

    //����
    wire clean_recv_flag;
    wire uart_read_ce;
    wire uart_read_fin;
    wire uart_write_ce;
    wire uart_write_fin;
    wire [7:0] uart_wdata;
    wire [7:0] uart_rdata;    //���ڶ�������
    reg recv_flag;           //���ձ�־λ  1:�����յ�����
    reg send_flag;           //���ͱ�־λ  1:���ڿ���
    reg t_recv_flag;
    reg t_send_flag;
    reg rd_recv_flag;
    reg rd_send_flag;
     
    wire rd_uart_write_ce;
    wire [7:0] rd_uart_wdata;
    wire rd_clean_recv_flag;
    wire [7:0] rd_uart_rdata;
    
    
    wire [31:0] base_rdata;
    wire [31:0] ext_rdata;
    wire [31:0] base_wdata;
    wire [31:0] ext_wdata;
    wire base_read_ce;
    wire base_write_ce;
    wire ext_read_ce;
    wire ext_write_ce;
    wire [19:0] base_addr;
    wire [19:0] ext_addr;
    wire stall_mem;
    
    wire rd_base_read_ce;
    wire rd_base_write_ce;
    wire rd_ext_read_ce;
    wire rd_ext_write_ce;
    wire [19:0] rd_base_addr;
    wire [19:0] rd_ext_addr;
    wire [31:0] rd_base_wdata;
    wire [31:0] rd_ext_wdata;
    
    wire [31:0] rd_base_rdata;
    wire [31:0] rd_ext_rdata;
    
    wire base_fin;
    wire ext_fin;
    
    wire [31:0] base_ram_wdata;
    wire [31:0] base_ram_rdata;
    assign base_ram_data = (base_write_ce == 1'b1)? base_ram_wdata:32'hzzzzzzzz;
    assign base_ram_rdata = base_ram_data;
            
    wire [31:0] ext_ram_wdata;
    wire [31:0] ext_ram_rdata;
    assign ext_ram_data = (ext_write_ce == 1'b1)?ext_ram_wdata:32'hzzzzzzz;
    assign ext_ram_rdata = ext_ram_data;
    
    wire uart_txd;
    
    wire uart_write_flag;
    //wire uart_read_flag;
    
    
    
assign uart_read_ce = (reset_of_clk98M == 1'b1)?1'b0:1'b1;
/*
reg t_recv_flag;
always @(posedge clk_98M) t_recv_flag <= recv_flag;*/
/*
always @(posedge clk_98M or posedge reset_of_clk98M) begin
    if (reset_of_clk98M)
        t_recv_flag <= 1'b0;
    else
        t_recv_flag <= recv_flag;
end*/

reg uart_read_flag;

always @(posedge clk_top or posedge reset_of_clk500M) begin 
    if (reset_of_clk500M) uart_read_flag <= 1'b0;
    else if (clean_recv_flag) uart_read_flag <= 1'b1;
    else if (uart_read_fin == 1'b0) uart_read_flag <= 1'b0;
end

    always @(*) begin
            if (uart_read_fin == 1'b1 && !uart_read_flag) recv_flag <= 1'b1;
            else if (uart_read_flag) recv_flag <= 1'b0;
            else recv_flag <= 1'b0;
    end
    
    
//assign recv_flag = (uart_read_fin)?((uart_read_flag)?1'b0:1'b1):1'b0;

/*
reg t_send_flag;
always @(posedge clk_98M) t_send_flag <= send_flag;*/

always @(*) begin 
        if (uart_write_fin) begin 
            if (uart_write_flag) send_flag <= 1'b0;            
            else send_flag <= 1'b1;
        end
        else send_flag <= 1'b0;
end

//assign send_flag = (uart_write_fin)?((uart_write_flag)?1'b0:1'b1):1'b0;

assign txd = uart_txd;

    top top(
        .clk(clk_top),
        .rst(reset_of_clktop),
        .ce(ce),
        .stall_mem(stall_mem),
        .ram_rdata(ram_rdata),
        .dram_write_addr(dram_write_addr),
        .dram_read_addr(dram_read_addr),
        .dwrite_ce(dwrite_ce),
        .wdata(wdata),
        .dread_ce(dread_ce),
        .iread_ce(iread_ce),
        .iram_addr(iram_addr),
        .ram_inst(ram_inst),
        .irom_fin(base_fin),
        .uart_wdata(uart_wdata),
        .uart_write_ce(uart_write_ce),
        .uart_rdata(rd_uart_rdata),
        .clean_recv_flag(clean_recv_flag),
        .recv_flag(recv_flag),
        .send_flag(send_flag)
    );

uart_asyn_ram uart_asyn_ram(
    .wr_clk(clk_top),
    .wr_rst(reset_of_clktop),
    .wr_uart_write_ce(uart_write_ce),
    .wr_clean_recv_flag(clean_recv_flag),
    .wr_uart_wdata(uart_wdata),
    .rd_clk(clk_uart),
    .rd_rst(reset_of_clk98M),
    .rd_uart_write_ce(rd_uart_write_ce),
    .rd_clean_recv_flag(rd_clean_recv_flag),
    .rd_uart_wdata(rd_uart_wdata)
    );


uart_read_asyn_ram uart_read_asyn_ram(
    .wr_clk(clk_uart),
    .wr_rst(reset_of_clk98M),
    .wr_uart_rdata(uart_rdata),
    .rd_clk(clk_top),
    .rd_rst(reset_of_clk500M),
    .rd_uart_rdata(rd_uart_rdata)
    );
        
uart_read uart_read(
    .clk(clk_uart),
    .clk_98M(clk_98M),
    //.clk_top(clk_top),
    .rst(reset_of_clk98M),
    //.rst_top(reset_of_clk500M),
    .read_ce(uart_read_ce),             //
    .din(rxd),
    //.clean_recv_flag(clean_recv_flag),
    .rfin(uart_read_fin),
    //.flag(uart_read_flag),
    .dout(uart_rdata)
);

uart_write uart_write(
    .clk(clk_uart),
    .clk_top(clk_top),
    .rst(reset_of_clk98M),
    .rst_top(reset_of_clktop),
    .write_ce(rd_uart_write_ce),                         //дʹ��
    .din(rd_uart_wdata),                              //����mem
    .wfin(uart_write_fin),
    .flag(uart_write_flag),
    .dout(uart_txd)
);

memory_manager memory_manager(
.clk(clk_top),
.rst(reset_of_clktop),
.stall_mem(stall_mem),
.dram_write_addr(dram_write_addr),
.dram_read_addr(dram_read_addr),
.iram_addr(iram_addr),
.base_rdata(base_rdata),
.ext_rdata(ext_rdata),
.dram_wdata(wdata),
.dwrite_ce(dwrite_ce),
.dread_ce(dread_ce),
.iread_ce(iread_ce),
.iram_rdata(ram_inst),
.dram_rdata(ram_rdata),
.base_wdata(base_wdata),
.ext_wdata(ext_wdata),
.base_read_ce(base_read_ce),
.base_write_ce(base_write_ce),
.ext_read_ce(ext_read_ce),
.ext_write_ce(ext_write_ce),
.base_addr(base_addr),
.ext_addr(ext_addr)
);

ram_rw base_ram(
.clk(clk_500M),
.rst(reset_of_clk500M),
.read_ce(base_read_ce),
.write_ce(base_write_ce),
.write_data(base_wdata),
.addr(base_addr),
.fin(base_fin),
.rom_rdata(base_ram_rdata),
.rom_wdata(base_ram_wdata),
.rom_addr(base_ram_addr),
.we(base_ram_we_n),
 .ce(base_ram_ce_n),
.oe(base_ram_oe_n),
.read_data(base_rdata)
);

ram_rw ext_ram(
.clk(clk_500M),
.rst(reset_of_clk500M),
.read_ce(ext_read_ce),
.write_ce(ext_write_ce),
.write_data(ext_wdata),
.addr(ext_addr),
.rom_rdata(ext_ram_rdata),
.rom_wdata(ext_ram_wdata),
.rom_addr(ext_ram_addr),
.we(ext_ram_we_n),
 .ce(ext_ram_ce_n),
.oe(ext_ram_oe_n),
.read_data(ext_rdata)
);
/*
ila_0 u_ila_0(
.clk(clk_50M),
.probe0(base_addr),
.probe1(base_ram_rdata)
);*/

endmodule
