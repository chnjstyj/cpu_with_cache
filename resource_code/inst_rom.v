module inst_rom(                 //ָ��Ĵ���
    (* dont_touch = "1" *)input wire [31:0] inst_address,
    input wire clk,
    input wire stall_pc,
    input wire rst,
    output wire stall_pc_flush_if_id,
    output reg read_ce,
    (* dont_touch = "1" *)output wire [31:0] irom_addr,
    (* dont_touch = "1" *)input wire [31:0] ram_inst,
    input wire irom_fin,
    (* dont_touch = "1" *)output wire [31:0] inst 
);

assign irom_addr = {5'b00000,inst_address[28:2]};

always @(*) begin
    if (rst == 1'b1) read_ce <= 1'b0;
    else read_ce <= 1'b1;
end

assign inst = ram_inst;

assign stall_pc_flush_if_id = (ram_inst === 32'hzzzzzzzz)?1'b1:1'b0;         //��ͣȡֵ ���if_id

/*
mips ���ֽ�Ѱַ������ָ���ַҪ/2�������λ��ȡ��
��log2(1024) = 10,����ֻȡǰ10λ��
*/
endmodule  