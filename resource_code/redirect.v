//�ض��� ��·��Ԫ
module redirect(
    input [4:0] ex_Rs,
    input [4:0] ex_Rt,
    input [4:0] mem_wb_wreg,
    input mem_wb_RegWrite,
    output reg control_rdata_a,
    output reg control_rdata_b,
    //jr  ����ض���
    input [31:0] ex_alu_result,
    input ex_RegWrite,
    input [4:0] ex_wreg,
    input [4:0] id_rreg_a,
    input id_jmp_reg,
    input [31:0] id_rdata_a,
    output reg [31:0] Rrs                 //���ӵ�pc��
);

always @(*) begin 
    if(mem_wb_RegWrite && mem_wb_wreg != 5'b00000 && ex_Rs == mem_wb_wreg)
        control_rdata_a <= 1'b1;     //��������mem/wb�׶�д�ؼĴ���������
    else 
        control_rdata_a <= 1'b0;
end 

always @(*) begin 
    if(mem_wb_RegWrite && mem_wb_wreg != 5'b00000 && ex_Rt == mem_wb_wreg)
        control_rdata_b <= 1'b1;     //��������mem/wb�׶�д�ؼĴ���������
    else 
        control_rdata_b <= 1'b0;
end 

always @(*) begin   //����ex ������
    if (ex_RegWrite && id_jmp_reg && ex_wreg == id_rreg_a) begin
        Rrs <= ex_alu_result;
    end
    else begin
       Rrs <= id_rdata_a; 
    end
end

endmodule