module top(
    input wire clk,
    (* dont_touch = "1" *)input wire rst,
    output wire ce,
    input wire stall_mem,
    //drom
    input wire dram_write_fin,
    input wire dram_read_fin,
    input wire [31:0] ram_rdata,
    output wire [29:0] dram_write_addr,
    output wire [29:0] dram_read_addr,
    output wire dram_write_ce,
    output wire [31:0] dram_cache_wb_data,
    output wire dram_read_ce,
    //irom
    output wire irom_read_ce,
    output wire [29:0] irom_addr,
    input wire [31:0] rom_inst,
    input wire irom_fin
);
(* dont_touch = "1" *)wire [31:0] inst_address;
(* dont_touch = "1" *)wire [31:0] cur_inst;
wire [31:0] next_instaddress;
wire [5:0] opcode;
wire [4:0] rreg_a;
wire [4:0] rreg_b;
wire [4:0] wreg;
wire [15:0] imme_num;
wire [5:0] func;
wire [3:0] alu_control_sig;
wire ALU_zerotag;
wire [4:0] shamt;
(* dont_touch = "1" *)wire bgtz_sig;
wire Ebranch;
wire stall_pc_flush_if_id;

//dram cache
wire [29:0] dram_addr;
wire dram_cache_miss;
wire [31:0] dram_cache_data;

//id�׶ο����ź�
wire [31:0] jump_address;
wire RegDst;
wire Branch;
wire MemRead;
wire MemtoReg;
wire [3:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
wire Jump;                    //�͵�ƽ��Ч
wire equal_branch;
wire store_pc;
wire lui_sig;
wire greater_than;

//ex�׶ο����ź�
wire jmp_reg;                //jr �ź���

//��ַ������
wire [31:0] jc_instaddress;

//�Ĵ����Ѷ�������
wire [31:0] rdata_a;
wire [31:0] rdata_b;

//alu����
wire [31:0] alu_rdata_a;
wire [31:0] alu_rdata_b;

//alu������
wire [31:0] alu_result;

//������Ƭѡ�ź�
wire [1:0] mem_sel;

//�������ӳ�
wire stall_dram;

//�������������� //�Ĵ���д���ַ �Ĵ���д���ź�
wire [31:0] mem_wdata;

//д����������
wire [31:0] wdata;

//��·�������
wire control_rdata_a;
wire control_rdata_b;
wire [31:0] Rrs;

//��ˮ������ģ������
wire flush_if_id;
wire flush_id_ex;
wire flush_ex_memwb;
wire stall_pc;
wire stall_if_id;
wire stall_id_ex;
wire stall_ex_memwb;

//ָ��cache
wire iread_ce;
//cache����
wire [31:0] irom_cache_data;
//ȱʧ�ź�
wire irom_cache_miss;

//��ˮ�����ģ��������
//if_id
wire [31:0] id_inst;
wire [31:0] id_next_instaddress;
wire [31:0] id_cur_instaddress;
if_id if_id(
    .clk(clk),
    .rst(rst),
    .stall_if_id(stall_if_id),
    .if_inst(cur_inst),
    .if_next_instaddress(next_instaddress),
    .if_cur_instaddress(inst_address),
    .flush_if_id(flush_if_id),
    .id_inst(id_inst),
    .id_next_instaddress(id_next_instaddress),
    .id_cur_instaddress(id_cur_instaddress)
);

//id_ex
wire ex_Branch;
wire ex_MemRead;
wire ex_MemtoReg;
wire [3:0] ex_ALUOp;
wire ex_MemWrite;
wire ex_ALUSrc;
wire ex_RegWrite;
wire ex_equal_branch;
wire ex_lui_sig;
wire [31:0] ex_next_instaddress;
wire [31:0] ex_rdata_a;
wire [31:0] ex_rdata_b;
wire [15:0] ex_imme_num;
wire [5:0] ex_func;
wire [4:0] ex_shamt;
(* dont_touch = "1" *)wire [5:0] ex_opcode;
wire [31:0] ex_cur_instaddress;
wire [4:0] ex_wreg;
wire [4:0] ex_Rs;
wire [4:0] ex_Rt;
wire ex_greater_than;
wire ex_store_pc;
wire ex_Ebranch;
wire [31:0] ex_jc_instaddress;
 
id_ex id_ex(
    .clk(clk),
    .rst(rst),
    .flush_id_ex(flush_id_ex),
    .stall_id_ex(stall_id_ex),
    .id_MemRead(MemRead),
    .id_MemtoReg(MemtoReg),
    .id_ALUOp(ALUOp),
    .id_MemWrite(MemWrite),
    .id_ALUSrc(ALUSrc),
    .id_RegWrite(RegWrite),
    .id_equal_branch(equal_branch),
    .id_store_pc(store_pc),
    .id_lui_sig(lui_sig),
    .id_next_instaddress(id_next_instaddress),
    .id_rdata_a(rdata_a),
    .id_rdata_b(rdata_b),
    .id_imme_num(imme_num),
    .id_func(func),
    .id_shamt(shamt),
    .id_opcode(opcode),
    .id_cur_instaddress(id_cur_instaddress),
    .id_wreg(wreg),
    .id_Rs(rreg_a),
    .id_Rt(rreg_b),
    .id_greater_than(greater_than),
    .ex_MemRead(ex_MemRead),
    .ex_MemtoReg(ex_MemtoReg),
    .ex_ALUOp(ex_ALUOp),
    .ex_MemWrite(ex_MemWrite),
    .ex_ALUSrc(ex_ALUSrc),
    .ex_RegWrite(ex_RegWrite),
    .ex_equal_branch(ex_equal_branch),
    .ex_store_pc(ex_store_pc),
    .ex_lui_sig(ex_lui_sig),
    .ex_next_instaddress(ex_next_instaddress),
    .ex_rdata_a(ex_rdata_a),
    .ex_rdata_b(ex_rdata_b),
    .ex_imme_num(ex_imme_num),
    .ex_func(ex_func),
    .ex_shamt(ex_shamt),
    .ex_opcode(ex_opcode),
    .ex_cur_instaddress(ex_cur_instaddress),
    .ex_wreg(ex_wreg),
    .ex_Rs(ex_Rs),
    .ex_Rt(ex_Rt),
    .ex_greater_than(ex_greater_than)
);

//ex_mem
wire mem_lui_sig;
wire mem_MemRead;
wire mem_MemWrite;
wire mem_MemtoReg;
wire mem_RegWrite;
wire [31:0] mem_alu_result;
wire [31:0] mem_rdata_b;
wire [5:0] mem_opcode;
wire [15:0] mem_imme_num;
wire [4:0] mem_wreg;
ex_mem ex_mem(
    .clk(clk),
    .rst(rst),
    .stall_ex_memwb(stall_ex_memwb),
    .ex_lui_sig(ex_lui_sig),
    .ex_MemRead(ex_MemRead),
    .ex_MemWrite(ex_MemWrite),
    .ex_MemtoReg(ex_MemtoReg),
    .ex_RegWrite(ex_RegWrite),
    .ex_alu_result(alu_result),
    .ex_rdata_b(alu_rdata_b),
    .ex_opcode(ex_opcode),
    .ex_imme_num(ex_imme_num),
    .ex_wreg(ex_wreg),
    .mem_lui_sig(mem_lui_sig),
    .mem_MemRead(mem_MemRead),
    .mem_MemWrite(mem_MemWrite),
    .mem_MemtoReg(mem_MemtoReg),
    .mem_RegWrite(mem_RegWrite),
    .mem_alu_result(mem_alu_result),
    .mem_rdata_b(mem_rdata_b),
    .mem_opcode(mem_opcode),
    .mem_imme_num(mem_imme_num),
    .mem_wreg(mem_wreg)
);

//��ˮ������ģ��
stall stall(
    .rst(rst),
    .stall_mem(stall_mem),
    .stall_dram(stall_dram),
    .stall_pc_flush_if_id(stall_pc_flush_if_id),
    .Jump(Jump),
    .jmp_reg(jmp_reg),
    .id_Branch(Branch),
    .mem_read_ce(dread_ce),
    .mem_write_ce(dwrite_ce),
    .bgtz_sig(bgtz_sig),
    .ex_RegWrite(ex_RegWrite),
    .irom_cache_miss(irom_cache_miss),
    .dram_cache_miss(dram_cache_miss),
    .flush_if_id(flush_if_id),
    .flush_id_ex(flush_id_ex),
    .flush_ex_memwb(flush_ex_memwb),
    .stall_pc(stall_pc),
    .stall_if_id(stall_if_id),
    .stall_id_ex(stall_id_ex),
    .stall_ex_memwb(stall_ex_memwb)
);

pc pc(
    .clk(clk),
    .rst(rst),
    .Ebranch(Ebranch),
    .Jump(Jump),
    //.imme(imme_num),
    .jmp_reg(jmp_reg),
    .Rrs(Rrs),                
    .jc_instaddress(jc_instaddress),
    .jump_address(jump_address),
    .inst_address(inst_address),
    .next_instaddress(next_instaddress),
    .bgtz_sig(bgtz_sig),
    .stall_pc(stall_pc),
    .ce(ce)
);

inst_rom inst_rom(
    .inst_address(inst_address),
    .clk(clk),
    .stall_pc(stall_pc),
    .rst(rst),
    .stall_pc_flush_if_id(stall_pc_flush_if_id),
    .inst(cur_inst),
    .read_ce(iread_ce),
    .irom_addr(irom_addr),
    .rom_inst(irom_cache_data),
    .irom_fin(irom_fin)
);

cache_control irom_cache_control(
    .clk(clk),
    .rst(rst),
    .addr(irom_addr),
    .wdata(),
    .mem_data(rom_inst),
    .wr(1'b0),
    .rd(iread_ce),
    .mem_write_fin(1'b0),
    .mem_read_fin(irom_fin),
    .miss(irom_cache_miss),
    .mem_read_ce(irom_read_ce),
    .mem_write_ce(),
    .cache_r_hit(),
    .cache_wb_data(),
    .cache_data(irom_cache_data)
);

id id(
    .inst(id_inst),
    .next_instaddress(id_next_instaddress),
    .RegDst(RegDst),
    .opcode(opcode),
    .rreg_a(rreg_a),
    .rreg_b(rreg_b),
    .wreg(wreg),
    .imme_num(imme_num),
    .func(func),
    .shamt(shamt),
    .jmp_reg(jmp_reg),
    .jump_address(jump_address)
);

opcode_control opcode_control(
    .opcode(opcode),
    .rst(rst),
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
    .lui_sig(lui_sig),
    .greater_than(greater_than)
);

regs regs(
    .clk(clk),
    .rst(rst),
    .rreg_a(rreg_a),
    .rreg_b(rreg_b),
    .wreg(mem_wreg),
    .wdata(mem_wdata),
    .RegWrite(mem_RegWrite),
    .rdata_a(rdata_a),
    .rdata_b(rdata_b),
    .inst_address(ex_cur_instaddress),
    .store_pc(ex_store_pc),
    .next_instaddress(id_next_instaddress),          //����if_id
    .imme(imme_num),                                 //
    .greater_than(greater_than),
    .equal_branch(equal_branch),
    .bgtz_sig(bgtz_sig),
    .Branch(Branch),
    .Ebranch(Ebranch),
    .jc_instaddress(jc_instaddress)
);

pre_alu pre_alu(
    .ex_rdata_a(ex_rdata_a),
    .ex_rdata_b(ex_rdata_b),
    .mem_wb_dout(mem_wdata),
    .control_rdata_a(control_rdata_a),
    .control_rdata_b(control_rdata_b),
    .rdata_a(alu_rdata_a),
    .rdata_b(alu_rdata_b)
);

alu alu(
    .data_a(alu_rdata_a),
    .data_b(alu_rdata_b),
    .imme(ex_imme_num),                           //�з�����չ �޷�����չ
    .ALUSrc(ex_ALUSrc),
    .alu_control(alu_control_sig),
    .alu_result(alu_result),
    .shamt(ex_shamt)
);

alu_control alu_control(
    .func(ex_func),
    .ALUOp(ex_ALUOp),
    .alu_control(alu_control_sig)
);

pre_mem pre_mem(
    .opcode(mem_opcode),
    .mem_sel(mem_sel)
);

mem mem(
    .clk(clk),
    .rst(rst),
    .stall_dram(stall_dram),
    .alu_result(mem_alu_result),
    .din(mem_rdata_b),            //���ԼĴ����ѵĵڶ�����������
    .MemWrite(mem_MemWrite),
    .MemRead(mem_MemRead),
    .MemtoReg(mem_MemtoReg),
    .dout(mem_wdata),
    .mem_sel(mem_sel),
    .lui_sig(mem_lui_sig),
    .imme(mem_imme_num),            //����id�׶ε�������
    .dram_read_addr(dram_read_addr),
    .dram_write_addr(dram_write_addr),
    .write_ce(dwrite_ce),
    .wdata(wdata),
    .read_ce(dread_ce),
    .ram_rdata(dram_cache_data)
);

assign dram_addr = dram_read_addr;

cache_control dram_cache_control(
    .clk(clk),
    .rst(rst),
    .addr(dram_addr),
    .wdata(wdata),     //cpuд��cache������ ����mem wdata
    .mem_data(ram_rdata),   //mem�滻cache�е����� �����ⲿmem
    .wr(dwrite_ce),
    .rd(dread_ce),
    .mem_write_fin(dram_write_fin),
    .mem_read_fin(dram_read_fin),
    .miss(dram_cache_miss),
    .mem_read_ce(dram_read_ce),
    .mem_write_ce(dram_write_ce),
    .cache_r_hit(),
    .cache_wb_data(dram_cache_wb_data),
    .cache_data(dram_cache_data)
);

redirect redirect(
    .ex_Rs(ex_Rs),
    .ex_Rt(ex_Rt),
    .mem_wb_wreg(mem_wreg),
    .mem_wb_RegWrite(mem_RegWrite),
    .control_rdata_a(control_rdata_a),
    .control_rdata_b(control_rdata_b),
    .ex_alu_result(alu_result),
    .ex_RegWrite(ex_RegWrite),
    .ex_wreg(ex_wreg),
    .id_rreg_a(rreg_a),
    .id_jmp_reg(jmp_reg),
    .id_rdata_a(rdata_a),
    .Rrs(Rrs)
);

endmodule