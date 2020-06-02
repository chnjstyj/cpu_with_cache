    module mem(                   //ʹ��С��ģʽ
    input clk,
    input [31:0] alu_result,
    input [31:0] din,
    input [31:0] imme,
    input MemWrite,
    input MemRead,
    input MemtoReg,
    input [1:0] mem_sel,
    input lui_sig,
    //input [4:0] mem_wreg,
    //input mem_RegWrite,
    //output reg wb_RegWrite,
    //output reg [4:0] wb_wreg,
    output reg [31:0] dout
);

reg [7:0] ram_a[0:1023];
reg [7:0] ram_b[0:1023];
reg [7:0] ram_c[0:1023];
reg [7:0] ram_d[0:1023];
reg [31:0] data_out;
/*
always @(posedge clk) begin 
    wb_wreg <= mem_wreg;
    wb_RegWrite <= mem_RegWrite;
end
*/
//������
always @(*) begin
    if(MemRead) begin         //ȡ��10λ ��Ϊlog1024/log2 = 10  
        case (mem_sel)
            2'b00:data_out <= 32'h00000000;
            2'b01:data_out <= {24'h0,ram_a[alu_result[9:2]]};
            2'b10:data_out <= {16'h0,ram_b[alu_result[9:2]],ram_a[alu_result[9:2]]};
            2'b11:data_out <= {ram_d[alu_result[9:2]],ram_c[alu_result[9:2]],ram_b[alu_result[9:2]],ram_a[alu_result[9:2]]};
        endcase
    end
    else
        data_out <= 32'h00000000;
end

//д����     ��ʱ��������
always @(posedge clk) begin
    if (MemWrite) begin
        case (mem_sel)
            2'b00: ram_a[alu_result[9:2]] <= ram_a[alu_result[9:2]];              //scָ���Ȳ�ʵ��
            2'b01:begin                                                         //sb
                ram_a[alu_result[9:2]] <= din[7:0];
                ram_b[alu_result[9:2]] <= ram_b[alu_result[9:2]];
                ram_c[alu_result[9:2]] <= ram_c[alu_result[9:2]];
                ram_d[alu_result[9:2]] <= ram_d[alu_result[9:2]];                    
            end
            2'b10:begin                                                         //sh
                ram_a[alu_result[9:2]] <= din[7:0];
                ram_b[alu_result[9:2]] <= din[15:8];
                ram_c[alu_result[9:2]] <= ram_c[alu_result[9:2]];
                ram_d[alu_result[9:2]] <= ram_d[alu_result[9:2]];
            end
            2'b11:begin
                ram_a[alu_result[9:2]] <= din[7:0];
                ram_b[alu_result[9:2]] <= din[15:8];
                ram_c[alu_result[9:2]] <= din[23:16];
                ram_d[alu_result[9:2]] <= din[31:24];
            end
            default: ram_a[alu_result[9:2]] <= ram_a[alu_result[9:2]];
        endcase 
    end
    else 
        ram_a[alu_result[9:2]] <= ram_a[alu_result[9:2]];
end

//�����ĸ�����д�ؼĴ�����      д��
//assign dout = (MemtoReg == 1'b1)?data_out:alu_result;
always @(*) begin 
    if (MemtoReg == 1'b1 && lui_sig != 1'b1)
        dout <= data_out;
    else if (MemtoReg != 1'b1 && lui_sig != 1'b1)
        dout <= alu_result;
    else if (lui_sig == 1'b1)
        dout <= {{imme[15:0]},16'b0};
end


endmodule 