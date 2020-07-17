module branch(
    input [31:0] next_instaddress,
    (* dont_touch = "1" *)input [31:0] imme,             //来自于id.v 的imme_num
    input greater_than,                    //来自opcode.v
    output bgtz_sig,                     //连接到pc.v
    output [31:0] jc_instaddress   //有条件跳转指令地址，连接到pc中
);

wire [31:0] xor_result;
//wire [31:0] zero_result;
assign zero_result = rdata_a - 32'h00000000;
assign xor_result = ~(rdata_a | rdata_b);
assign bgtz_sig = (zero_result != 32'h00000000 && zero_result[31] != 1'b1 && greater_than)?1'b1:1'b0;

assign jc_instaddress = next_instaddress + {{7{imme[25]}},imme[25:0],2'b00};
/*
always @(*) begin
    if(equal_branch) begin  
        if(xor_result == 32'h00000000)
            zero_sig <= 1'b1;
        else
            zero_sig <= 1'b0;
    end
    else begin
        if(xor_result == 32'h00000000)
            zero_sig <= 1'b0;
        else
            zero_sig <= 1'b1;
    end 
end*/

endmodule 