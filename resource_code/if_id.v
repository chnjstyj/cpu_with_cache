module if_id(
    input clk,
    input rst,
    input [31:0] if_inst,
    input [31:0] if_cur_instaddress,                    //jalָ����
    input [31:0] if_next_instaddress,            //��ָ���ַ+4����һ��ָ���ַ
    output reg [31:0] id_inst,
    output reg [31:0] id_cur_instaddress,
    output reg [31:0] id_next_instaddress
);

always @(posedge clk) begin
    if(rst == 1'b0) begin
        id_inst <= 32'h00000000;
        id_cur_instaddress <= 32'h00000000;
        id_next_instaddress <= 32'h00000000;
    end
    else begin 
        id_inst <= if_inst;
        id_cur_instaddress <= if_cur_instaddress;
        id_next_instaddress <= if_next_instaddress;
    end 
end

endmodule