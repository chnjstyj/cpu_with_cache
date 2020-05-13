module opcode_control(
    input [5:0] opcode,
    output RegDst,
    output Branch,
    output MemRead,
    output MemtoReg,
    output [3:0] ALUOp,
    output MemWrite,
    output ALUSrc,
    output RegWrite,
    output Jump,                    //低电平有效
    output equal_branch,
    output store_pc,                //连接到alu中
    output lui_sig                  //lui指令信号,连接到mem中
);

reg [12:0] control_sig;

assign {branch_satisfy,Jump,RegDst,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} 
    = control_sig;

always @(*) begin
   case (opcode)
       6'b000000: control_sig <= 13'b1110010000010;       //R-type
       6'b100011: control_sig <= 13'b1101111000000;       //lw
       6'b101011: control_sig <= 13'b1111100100000;       //sw
       6'b000100: control_sig <= 13'b1100000010001;       //beq
       6'b000010: control_sig <= 13'b1000000000000;       //j
       6'b001101: control_sig <= 13'b1101010000011;       //ori
       6'b101000: control_sig <= 13'b1111100100000;       //sb
       6'b101001: control_sig <= 13'b1111100100000;       //sh 
       6'h9: control_sig <= 13'b1101010000000;            //addiu
       6'h8: control_sig <= 13'b1101010000000;            //addi
       6'hc: control_sig <= 13'b1101010000100;            //andi
       6'h5: control_sig <= 13'b0101000010001;            //bne
       6'h3: control_sig <= 13'b1000000000000;            //jal
       6'h24: control_sig <= 13'b1101111000000;           //lbu
       6'h25: control_sig <= 13'b1101111000000;           //lhu
       6'hf: control_sig <= 13'b1101111000000;            //lui
       6'ha: control_sig <= 13'b1101010000101;            //slti
       6'hb: control_sig <= 13'b1101010000101;            ///sltiu
       default: control_sig <= 13'b1100000000000;
   endcase 
end

assign store_pc = (opcode == 6'h3)?1'b1:1'b0;
assign lui_sig = (opcode == 6'hf)?1'b1:1'b0;

endmodule