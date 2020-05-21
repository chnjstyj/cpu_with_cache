module branch(
    input [31:0] next_instaddress,
    input [31:0] imme,             //������id.v ��imme_num
    input [31:0] rdata_a,                 //����regs.v
    input [31:0] rdata_b,
    input greater_than,                    //����opcode.v
    input equal_branch,
    output bgtz_sig,                     //���ӵ�pc.v
    output reg zero_sig,
    output [31:0] jc_instaddress   //��������תָ���ַ�����ӵ�pc��
);

wire [31:0] xor_result;
wire [31:0] zero_result;
assign zero_result = rdata_a - 32'h00000000;
assign xor_result = ~(rdata_a | rdata_b);
assign bgtz_sig = (zero_result != 32'h00000000 && zero_result[31] != 1'b1 && greater_than)?1'b1:1'b0;

assign jc_instaddress = next_instaddress + {7'b0000000,imme[25:0],2'b00};

always @(*) begin
    if(equal_branch) begin  
        if(xor_result == 32'h00000000)
            zero_sig <= 1'b0;
        else
            zero_sig <= 1'b1;
    end
    else begin
        if(xor_result == 32'h00000000)
            zero_sig <= 1'b1;
        else
            zero_sig <= 1'b0;
    end 
end

endmodule 