module inst_rom(                 //ָ��Ĵ���
    (* dont_touch = "1" *)input [31:0] inst_address,
    input rst,
    output wire stall_pc_flush_if_id,
    output reg read_ce,
    (* dont_touch = "1" *)output [31:0] irom_addr,
    (* dont_touch = "1" *)input [31:0] ram_inst,
    input irom_fin,
    (* dont_touch = "1" *)output wire [31:0] inst 
);
assign irom_addr = {5'b00000,inst_address[28:2]};
//(* dont_touch = "1" *)reg flag;
//always @(inst_address or rom_inst) flag <= 1'b0;

always @(*) begin
    if (rst == 1'b1) read_ce <= 1'b0;
    else read_ce <= 1'b1;
    /*
    else if (clk == 1'b1) read_ce <= 1'b1;
    else read_ce <= 1'b0;
    */
end

assign inst = ram_inst;
assign stall_pc_flush_if_id = (ram_inst === 32'hzzzzzzzz)?1'b1:1'b0;         //��ͣȡֵ ���if_id


/*
always @(*) begin
    if(ce == 1'b0) begin
        inst <= 32'h00000000;
    end 
    else inst <= ram_inst;
end
*/
/*
mips ���ֽ�Ѱַ������ָ���ַҪ/2�������λ��ȡ��
��log2(1024) = 10,����ֻȡǰ10λ��
*/
endmodule  