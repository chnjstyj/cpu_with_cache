`timescale 1ps/1ps

module top_tb;

reg clk;
reg rst;
reg dram_write_fin;
reg dram_read_fin;
reg [31:0] dram_read_data;
reg [31:0] rom_inst;
reg irom_fin;

wire ce;
wire [29:0] dram_addr;
wire dram_write_ce;
wire [31:0] dram_cache_wb_data;
wire dram_read_ce;
wire irom_read_ce;
wire [29:0] irom_addr;

reg [31:0] rom [127:0];
reg [31:0] ram [15:0];

always @(*) begin 
    forever begin
        #5;clk = !clk;
    end
end

initial begin
    $readmemh("rom.data",rom);
    $readmemh("ram.data",ram);
    clk = 0;
    irom_fin = 0;
    dram_read_fin = 0;
    dram_write_fin = 0;
end

initial begin
    rst = 1;
    #20;rst = 0;
end

always @(*) begin
    irom_fin = 0;
    if (irom_read_ce) begin 
        #30;irom_fin = 1;
        rom_inst = rom[irom_addr[6:0]];
    end
end

top u_top(
    .clk(clk),
    .rst(rst),
    .ce(ce),
    .stall_mem(1'b0),
    .dram_write_fin(dram_write_fin),
    .dram_read_fin(dram_read_fin),
    .ram_rdata(dram_read_data),
    .dram_write_addr(),
    .dram_read_addr(dram_addr),
    .dram_write_ce(dram_write_ce),
    .dram_cache_wb_data(dram_cache_wb_data),
    .dram_read_ce(dram_read_ce),
    .irom_read_ce(irom_read_ce),
    .irom_addr(irom_addr),
    .rom_inst(rom_inst),
    .irom_fin(irom_fin)
);

endmodule