module regs(
    input clk,
    input rst,
    input [4:0] rreg_a,
    input [4:0] rreg_b,
    input [4:0] wreg,
    input [31:0] wdata,        //д��Ĵ���������
    input RegWrite,            //�Ĵ���д�����ź�
    input [31:0] inst_address,       //jal ָ����
    input store_pc,                  //jalָ�����ź�
    output reg [31:0] rdata_a,
    output reg [31:0] rdata_b
);
reg [31:0] regs[0:31];

initial regs[0] = 32'h00000000;     //�Ĵ���ֵ��ʼ��Ϊ0


//д��������ʱ�ӱ������д����
always @(posedge clk) begin 
    if(rst == 1'b0) begin 
        if(RegWrite == 1'b1&& wreg != 5'b00000 && wreg != 5'd31 ) begin     //���ܶԼĴ���0д
            regs[wreg] <= wdata;
        end
       // else if(RegWrite == 1'b1&& wreg != 5'b00000 && wreg == 5'd31 ) begin
            //reg_jal <= wdata;
       // end
        else if(store_pc) regs[31] <= inst_address + 32'd8;            //pc+8
        else begin 
            regs[wreg] <= regs[wreg];
        end
    end 
    else begin
        regs[wreg] <= regs[wreg];
    end
end


//������������ʱ�ӱ���
//���Ĵ���1

always @(*) begin 
    if(rst == 1'b1) begin 
        rdata_a <= 32'h00000000;
    end 
    else if(rreg_a == wreg && RegWrite) begin       //����ֱͨ
        rdata_a <= wdata;
    end
    else begin
        rdata_a <= regs[rreg_a];
    end
end
//���Ĵ���2

always @(*) begin 
    if(rst == 1'b1) begin 
        rdata_b <= 32'h00000000;
    end 
    else if(rreg_b == wreg && RegWrite) begin 
        rdata_b <= wdata;
    end
    else begin 
        rdata_b <= regs[rreg_b];
    end
end
/*
always @(posedge clk) begin 
    if (store_pc) begin
        regs[31] <= inst_address + 3'd8;            //pc+8
    end
    else begin 
        regs[31] <= regs[31];
    end 
end*/


endmodule
