module inst_rom(                 //ָ��Ĵ���
    input clk,
    input rom_clk,
    input [31:0] inst_address,
    input ce,
    input [31:0] data,
    output reg [31:0] inst 
);

reg [31:0] inst_rom[0:1023];      //4kb��reg
reg read_ce;
reg [31:0] address;
always @(*) address <= {20'h00000,inst_address[11:2],2'b00};

wire [31:0] dout;
wire rfin;

initial $readmemh( "F:\inst_rom.data", inst_rom );

//
always @(*) begin
    if(ce == 1'b0) begin 
        inst <= 32'h00000000;
    end 
    else begin 
        inst <= inst_rom[inst_address[11:2]];
    end 
end 
/*
//���ڴ�
always @(*) begin 
    if(ce == 1'b0) begin
        inst <= 32'h00000000;
        read_ce <= 1'b0;
    end 
    else begin 
        read_ce <= 1'b1;
        if(rfin) inst <= dout;
        else inst <= inst;
    end
end
/*
mips ���ֽ�Ѱַ������ָ���ַҪ/2�������λ��ȡ��
��log2(1024) = 10,����ֻȡǰ10λ��
*/
rom_read rom_read(
    .clk(rom_clk),
    .rst(rst),
    .read_ce(read_ce),
    .address(address),
    .data(data),
    .dout(dout),
    .rfin(rfin)
);

endmodule  