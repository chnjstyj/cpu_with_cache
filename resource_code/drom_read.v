`timescale 1ns/1ps
module drom_read(
    input clk,         //2ns
    input rst,
    input read_ce,                 //��ʹ���ź�
    input [31:0] address,
    input [31:0] dout,
    output [19:0] rom_addr,
    output reg [31:0] data,
    output reg ce,
    output we,
    output reg oe,
    output reg rfin               //���ݶ�ȡ����ź�
    //output lb,
    //output ub
);

localparam s0 = 2'b00;
localparam s1 = 2'b01;
localparam s2 = 2'b11;
localparam s3 = 2'b10;

(* dont_touch = "1" *)reg [1:0] i;

(* dont_touch = "1" *)reg [1:0] cur_state;
reg [1:0] next_state;
reg state_fin;

always @(posedge clk) begin 
    if (rst) begin 
        cur_state <= s0;
    end
    else begin 
        cur_state <= next_state;
    end 
end 

always @(*) begin 
    case (cur_state)
        s0:begin 
            if (read_ce) begin 
                next_state <= s1;
            end
            else next_state <= s0;
        end
        s1:begin 
            if (state_fin) begin 
                next_state <= s2;
            end
            else next_state <= s1;
        end
        s2:begin 
            if (state_fin) begin 
                next_state <= s3;
            end
            else next_state <= s2;
        end
        s3:begin 
            if (state_fin) begin 
                next_state <= s0;
            end
            else next_state <= s3;
        end
        default:begin
            next_state <= s0;
        end 
    endcase
end



always @(posedge clk) begin
    if (rst) begin
        i <= 2'd0;
        data <= 32'h00000000;
        ce <= 1'b1;
        oe <= 1'b1;
        //rom_addr <= 16'h0000;
        state_fin <= 1'b0;
    end 
    else begin 
        case (next_state)
            s0:begin           //׼��
            i <= 2'd0;
            data <= 32'h00000000;
            ce <= 1'b1;
            oe <= 1'b1;
            //rom_addr <= 16'h0000;
            rfin <= 1'b0;
            state_fin <= 1'b0;
            end 
            s1:begin          //��ʱ2ns,oe&ce����
                    //rom_addr <= address;
                    oe <= 1'b0;
                    ce <= 1'b0;
                    state_fin <= 1'b1;
                    i <= 2'd0;
            end
            s2:begin         //��2ns��������
                //if (i < 2'd1) begin 
                    state_fin <= 1'b1;
                    //i <= i + 2'd1; 
                    data <= dout;
                //end 
                //else begin 
                    //state_fin <= 1'b1;
                    i <= 2'd0;
                //end 
            end
            s3: begin                   //��2ns������ce&oe,��2ns���
                if (i == 2'd0) begin 
                    state_fin <= 1'b0;
                    oe <= 1'b0;
                    ce <= 1'b0;
                    i <= i + 1;
                    rfin <= 1'b1;
                end
                else begin 
                    //rfin <= 1'b1;
                    oe <= 1'b1;
                    ce <= 1'b1;
                    state_fin <= 1'b1;
                    i <= 2'd0;
                    rfin <= 1'b0;
                end 
            end
            default:begin 
                i <= 2'd0;
                data <= 32'h00000000;
                ce <= 1'b1;
                oe <= 1'b1;
                //rom_addr <= 16'h0000;
                rfin <= 1'b0;
            end 
        endcase
    end
end

assign rom_addr = (read_ce == 1'b1 && next_state != s0)?address:32'h00000000;

assign we = 1'b1;


endmodule




    