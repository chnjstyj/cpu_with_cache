module pc(
    input clk,
    input rst,
    input Branch,                  //��������ת�ź�
    input zero_sig,             //ALU���־λ
    input Jump,                    //��������ת�ź� �͵�ƽ��Ч
    (* dont_touch = "1" *)input [31:0] imme,             //������id.v ��imme_num
    input jmp_reg,                 //jr �ź�
    input [31:0] Rrs,                     //R[rs] �Ĵ�������
    input [31:0] jc_instaddress,   //��������תָ���ַ
    //input [31:0] id_cur_inst,         //����ִ�е�ָ��
    //input [31:0] id_next_instaddress,
    input [31:0] jump_address,
    input bgtz_sig,
    input stall_pc,
    output reg [31:0] inst_address,
    output [31:0] next_instaddress,
    output reg ce           
);

//wire ifbranch;
//wire [31:0] next_instaddress ;


assign Ebranch = Branch && zero_sig;
assign next_instaddress = inst_address + 4'b0100;         //��ָ���ַ+4

always @(posedge clk) begin 
    if(ce == 1'b0) begin 
        inst_address <= 32'h80000000;
    end 
    else if (stall_pc == 1'b1) begin    
        inst_address <= inst_address - 4'b0100;            //��ͣȡ��һָ�� 
    end
    else if(!Ebranch&&Jump&&!jmp_reg&&!bgtz_sig) begin       //��ִ����������ת����������ת
        inst_address <= next_instaddress;
    end 
    else if(Ebranch&&Jump) begin                              //ִ����������ת
        inst_address <= jc_instaddress;          
    end
    else if(bgtz_sig) begin 
        inst_address <= jc_instaddress; 
    end
    else if(jmp_reg) begin 
        inst_address <= Rrs;
    end
    else if (!Jump) begin 
        //inst_address <= {id_next_instaddress[31:28],id_cur_inst[25:0],2'b00};
        inst_address <= jump_address;
    end 
end

always @(posedge clk) begin 
    if(rst == 1'b1) begin 
        ce <= 1'b0;
    end 
    else begin 
        ce <= 1'b1;
    end
end 

endmodule 
