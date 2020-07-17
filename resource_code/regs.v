(* dont_touch = "1" *)module regs(
    input clk,
    input rst,
    input [4:0] rreg_a,
    input [4:0] rreg_b,
    (* dont_touch = "1" *)input [4:0] wreg,
    input [31:0] wdata,        //д��Ĵ���������
    input RegWrite,            //�Ĵ���д�����ź�
    input [31:0] inst_address,       //jal ָ����
    input store_pc,                  //jalָ�����ź�
    //(*keep = "1"*)output wire t0,
    //(*keep = "1"*)output wire k0,
    //(*keep = "1"*)output wire k1,
    output reg [31:0] rdata_a,
    output reg [31:0] rdata_b,
    //branch 
    input [31:0] next_instaddress,
    input equal_branch,
    input Branch,
    (* dont_touch = "1" *)input [15:0] imme,             //������id.v ��imme_num
    input greater_than,                    //����opcode.v
    //output reg zero_sig,
    output reg bgtz_sig,                     //���ӵ�pc.v
    output wire Ebranch,
    output wire [31:0] reg_rs,
    output wire [31:0] reg_rt,
    output [31:0] jc_instaddress   //��������תָ���ַ�����ӵ�pc��
);
reg [31:0] regs[0:31];
//ץȡ�Ĵ����ź�
//wire [31:0] t0;
/*
assign t0 = regs[8];
assign k0 = regs[26];
assign k1 = regs[27];
*/
//always @(*) regs[0] = 32'h00000000;     //�Ĵ���ֵ��ʼ��Ϊ0


//д��������ʱ�ӱ������д����
always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) begin
        regs[0] <= 32'h00000000;
        regs[1] <= 32'h00000000;
        regs[2] <= 32'h00000000;
        regs[3] <= 32'h00000000;
        regs[4] <= 32'h00000000;
        regs[5] <= 32'h00000000;
        regs[6] <= 32'h00000000;
        regs[7] <= 32'h00000000;
        regs[8] <= 32'h00000000;
        regs[9] <= 32'h00000000;
        regs[10] <= 32'h00000000;
        regs[11] <= 32'h00000000;
        regs[12] <= 32'h00000000;
        regs[13] <= 32'h00000000;
        regs[14] <= 32'h00000000;
        regs[15] <= 32'h00000000;
        regs[16] <= 32'h00000000;
        regs[17] <= 32'h00000000;
        regs[18] <= 32'h00000000;
        regs[19] <= 32'h00000000;
        regs[20] <= 32'h00000000;
        regs[21] <= 32'h00000000;
        regs[22] <= 32'h00000000;
        regs[23] <= 32'h00000000;
        regs[24] <= 32'h00000000;
        regs[25] <= 32'h00000000;
        regs[26] <= 32'h00000000;
        regs[27] <= 32'h00000000;
        regs[28] <= 32'h00000000;
        regs[29] <= 32'h00000000;
        regs[30] <= 32'h00000000;
        regs[31] <= 32'h00000000;
    end
    else begin
    if(RegWrite == 1'b1 && wreg != 5'b00000 && wreg != 5'd31 ) begin     //���ܶԼĴ���0д
        regs[wreg] <= wdata;
    end
    if(store_pc == 1'b1) regs[31] <= inst_address + 32'd8;            //pc+8
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

wire [31:0] xor_result;
wire [31:0] zero_result;
reg [31:0] rs;
reg [31:0] rt;
reg zero_sig;
//reg bgtz_sig;
always @(*) begin 
    if(rreg_a == wreg && RegWrite) rs <= wdata;
    else rs <= rdata_a;
    if(rreg_b == wreg && RegWrite) rt <= wdata;
    else rt <= rdata_b;
 end
 
assign zero_result = rs - 32'h00000000;
assign xor_result = rs - rt;
assign jc_instaddress = next_instaddress + {{14{imme[15]}},imme,2'b00};
assign Ebranch = Branch && zero_sig;

always @(*) begin
    if (zero_result != 32'h00000000 && zero_result[31]!= 1'b1 && greater_than == 1'b1)
        bgtz_sig <= 1'b1;
    else bgtz_sig <= 1'b0;
end

//��ת����: zero_sig == 1'b1
//xor: ��ͬΪ1 ��ͬΪ0
always @(*) begin
    if(equal_branch) begin  //�������ת
        if(xor_result == 32'h00000000)     //ÿλ���ȫΪ0 ��ȫ��ͬ ��ת
            zero_sig <= 1'b1;  
        else
            zero_sig <= 1'b0;
    end
    else begin             //��ͬ����ת
        if(xor_result == 32'h00000000)    //ÿλ���ȫΪ0 ��ȫ��ͬ ����ת
            zero_sig <= 1'b0;
        else
            zero_sig <= 1'b1;
    end 
end

assign reg_rs = rs;
assign reg_rt = rt;


endmodule
