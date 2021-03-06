module opcode_control(
    input [5:0] opcode,
    input rst,
    output reg RegDst,          //regs
    output reg Branch,          //if
    output reg MemRead,         //mem
    output reg MemtoReg,        //wb
    output reg [3:0] ALUOp,     //ex
    output reg MemWrite,        //mem
    output reg ALUSrc,          //ex
    output reg RegWrite,        //wb
    output reg Jump,            //if        //低电平有效
    output reg equal_branch,    //ex
    output wire store_pc,        //ex        //连接到reg中
    output wire lui_sig,          //mem       //lui指令信号,连接到mem中
    output wire greater_than
);

reg [12:0] control_sig;

always @(*) begin 
    if (rst == 1'b1) {equal_branch,Jump,RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= 16'h4000;
    else 
        {equal_branch,Jump,RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= control_sig;
end

always @(*) begin
   case (opcode)
       6'b000000: control_sig <= 13'b1110010000010;       //R-type
       6'b100011: control_sig <= 13'b1101111000000;       //lw
       6'b101011: control_sig <= 13'b1111100100000;       //sw
       6'b000100: control_sig <= 13'b1100000010110;       //beq
       6'b000010: control_sig <= 13'b1000000000000;       //j
       6'b001101: control_sig <= 13'b1101010000011;       //ori
       6'b101000: control_sig <= 13'b1111100100000;       //sb
       6'b101001: control_sig <= 13'b1111100100000;       //sh 
       6'h9: control_sig <= 13'b1101010000000;            //addiu
       6'h8: control_sig <= 13'b1101010000000;            //addi
       6'hc: control_sig <= 13'b1101010000100;            //andi
       6'h5: control_sig <= 13'b0101000010110;            //bne
       6'h3: control_sig <= 13'b1000000000000;            //jal
       6'h24: control_sig <= 13'b1101111000000;           //lbu
       6'h25: control_sig <= 13'b1101111000000;           //lhu
       6'hf: control_sig <= 13'b1101110000000;            //lui
       6'ha: control_sig <= 13'b1101010000101;            //slti
       6'hb: control_sig <= 13'b1101010000101;            //sltiu
       6'h7: control_sig <= 13'b1101000010001;            //bgtz
       6'he: control_sig <= 13'b1111010000110;            //xori
       6'h20: control_sig <= 13'b1101111000000;            //lb
       6'h1c:control_sig <= 13'b1110010001001;             //mul
       default: control_sig <= 13'b1100000000000;
   endcase 
end

assign greater_than = (opcode == 6'h7)?1'b1:1'b0;
assign store_pc = (opcode == 6'h3)?1'b1:1'b0;
assign lui_sig = (opcode == 6'hf)?1'b1:1'b0;

endmodule