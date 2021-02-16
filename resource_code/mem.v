    module mem(                   //使用小端模式
    input clk,
    input rst,
    output reg stall_dram,
    input [31:0] alu_result,
    input [31:0] din,
    input [15:0] imme,
    input MemWrite,
    input MemRead,
    input MemtoReg,
    input [1:0] mem_sel,
    input lui_sig,
    (* dont_touch = "1" *)output reg [31:0] dout,
    output reg [29:0] dram_write_addr,
    output wire [29:0] dram_read_addr,
    output reg write_ce,
    output reg [31:0] wdata,
    output reg read_ce,
    input [31:0] ram_rdata
);

wire [29:0] dram_address;


localparam s0 = 1'b0;       //不暂停
localparam s1 = 1'b1;       //暂停

reg cur_state;
reg next_state;

reg [31:0] temp;
reg flag;
wire [31:0] real_ram_rdata;

always @(posedge clk or posedge rst) begin 
    if (rst) temp <= 32'h00000000;
    else if (next_state == s1) temp <= ram_rdata;
end

assign real_ram_rdata = (flag)?temp:ram_rdata;

assign dram_address = {3'b000,alu_result[28:2]};
assign dram_read_addr = dram_address;
reg [31:0] data_out;

always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) begin 
        write_ce <= 1'b0;
        dram_write_addr <= 30'b0;
    end
    else if(MemWrite) begin 
        write_ce <= 1'b1;
        dram_write_addr <= dram_address;
    end
    else write_ce <= 1'b0;
end

//写数据到内存
always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) begin 
        wdata <= 32'h00000000;
    end
    else begin 
        if(MemWrite) begin 
            case (mem_sel)
                2'b00:wdata <= 32'h00000000;
                2'b01:begin 
                    case (alu_result[1:0])
                        2'b11:wdata <= {{24{din[7]}},din[7:0]};
                        2'b10:wdata <= {{24{din[15]}},din[15:8]};
                        2'b01:wdata <= {{24{din[23]}},din[23:16]};
                        2'b00:wdata <= {{24{din[31]}},din[31:24]};
                        default:wdata <= 32'h00000000;
                    endcase
                end
                2'b10:wdata <= {{16{din[15]}},din[15:0]};
                2'b11:wdata <= din;
                default:wdata <= 32'h00000000;
            endcase
        end
    end
end 

//从内存读数据
always @(*) begin 
        if(MemRead) begin 
            read_ce <= 1'b1;
            case(mem_sel)
                2'b00:data_out <= 32'h00000000;
                2'b01:begin 
                    case(alu_result[1:0])
                        2'b11:data_out <= {{24{real_ram_rdata[31]}},real_ram_rdata[31:24]};
                        2'b10:data_out <= {{24{real_ram_rdata[23]}},real_ram_rdata[23:16]};
                        2'b01:data_out <= {{24{real_ram_rdata[15]}},real_ram_rdata[15:8]};
                        2'b00:data_out <= {{24{real_ram_rdata[7]}},real_ram_rdata[7:0]};
                        default:data_out <= 32'h00000000;
                    endcase
                end
                2'b10:data_out <= {16'h0000,real_ram_rdata[15:0]};
                2'b11:data_out <= real_ram_rdata;
                default:data_out <= real_ram_rdata;
            endcase 
        end
        else begin 
            data_out <= 32'h00000000;
            read_ce <= 1'b0;
        end
end

//决定哪个数据写回寄存器堆      写回
always @(*) begin 
    if (rst == 1'b1) dout <= 32'h00000000;
    else if (MemtoReg == 1'b1 && lui_sig != 1'b1)
        dout <= data_out;
    else if (MemtoReg != 1'b1 && lui_sig != 1'b1)
        dout <= alu_result;
    else if (lui_sig == 1'b1)
        dout <= {{imme},16'b0};
     else dout <= 32'h0;
end

always @(posedge clk or posedge rst) begin
    if (rst == 1'b1) cur_state <= s1;
    else cur_state <= next_state;
end

always @(*) begin 
    if (rst == 1'b1) next_state <= s0;
    else begin 
        case (cur_state) 
            s0:begin 
                if ((read_ce || write_ce)&&(!dram_address[20] || !dram_write_addr[20]) ) next_state <= s1;
                else next_state <= s0;
            end
            s1:begin 
                next_state <= s0;
            end
            default:next_state <= s0;
        endcase 
    end
end

always @(*) begin 
    if (rst == 1'b1) stall_dram <= 1'b0;
    else begin 
        case (next_state) 
            s0:stall_dram <= 1'b0;
            s1:stall_dram <= 1'b1;
            default:stall_dram <= 1'b0;
        endcase 
    end
end

always @(posedge clk or posedge rst) begin 
    if (rst == 1'b1) flag <= 1'b0;
    else begin 
        case (next_state) 
            s0:flag <= 1'b0;
            s1:flag <= 1'b1;
            default:flag <= 1'b0;
        endcase 
    end
end

endmodule 