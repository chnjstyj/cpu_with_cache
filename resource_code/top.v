module top(
    input clk,
    input rst
);

wire ce;
wire [31:0] inst_address;
wire [31:0] cur_inst;
wire [5:0] opcode;
wire [4:0] rreg_a;
wire [4:0] rreg_b;
wire [4:0] wreg;
wire [31:0] imme_num;
wire [5:0] func;
wire [3:0] alu_control_sig;
wire ALU_zerotag;
wire [4:0] shamt;

//�����ź�
wire RegDst;
wire Branch;
wire MemRead;
wire MemtoReg;
wire [3:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
wire Jump;                    //�͵�ƽ��Ч
wire unsigned_num;           //��ʱ����
wire equal_branch;
wire store_pc;
wire jmp_reg;                //jr �ź���
wire lui_sig;

//�Ĵ����Ѷ�������
wire [31:0] rdata_a;
wire [31:0] rdata_b;

//alu������
wire [31:0] alu_result;

//������Ƭѡ�ź�
wire [1:0] mem_sel;

//��������������
wire [31:0] mem_rdata;

pc pc(
    .clk(clk),
    .rst(rst),
    .Branch(Branch),
    .ALU_zerotag(ALU_zerotag),
    .Jump(Jump),
    .imme(imme_num),
    .cur_inst(cur_inst),
    .inst_address(inst_address),
    .ce(ce),
    .jmp_reg(jmp_reg),
    .Rrs(rdata_a)
);

inst_reg inst_reg(
    .clk(clk),
    .inst_address(inst_address),
    .ce(ce),
    .inst(cur_inst)
);

id id(
    .inst(cur_inst),
    .RegDst(RegDst),
    .opcode(opcode),
    .rreg_a(rreg_a),
    .rreg_b(rreg_b),
    .wreg(wreg),
    .imme_num(imme_num),
    .func(func),
    .shamt(shamt)
);

alu_control alu_control(
    .func(func),
    .ALUOp(ALUOp),
    .opcode(opcode),
    .alu_control(alu_control_sig),
    .jmp_reg(jmp_reg)
);

opcode_control opcode_control(
    .opcode(opcode),
    .RegDst(RegDst),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .Jump(Jump),
    .equal_branch(equal_branch),
    .store_pc(store_pc),
    .lui_sig(lui_sig)
);

regs regs(
    .clk(clk),
    .rst(rst),
    .rreg_a(rreg_a),
    .rreg_b(rreg_b),
    .wreg(wreg),
    .wdata(mem_rdata),
    .RegWrite(RegWrite),
    .rdata_a(rdata_a),
    .rdata_b(rdata_b),
    .inst_address(inst_address),
    .store_pc(store_pc)
);

alu alu(
    .data_a(rdata_a),
    .data_b(rdata_b),
    .imme(imme_num),
    .ALUSrc(ALUSrc),
    .alu_control(alu_control_sig),
    .zero_sig(ALU_zerotag),
    .alu_result(alu_result),
    .unsigned_num(unsigned_num),
    .equal_branch(equal_branch),
    .shamt(shamt)
);

pre_mem pre_mem(
    .opcode(opcode),
    .mem_sel(mem_sel)
);

mem mem(
    .clk(clk),
    .alu_result(alu_result),
    .din(rdata_b),            //���ԼĴ����ѵĵڶ�����������
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .dout(mem_rdata),
    .mem_sel(mem_sel),
    .lui_sig(lui_sig),
    .imme(imme_num)            //����id�׶ε�������
);

endmodule