module cal_address(
    input [31:0] next_instaddress,
    input [31:0] imme,             //������id.v ��imme_num
    output [31:0] jc_instaddress   //��������תָ���ַ�����ӵ�pc��
);

assign jc_instaddress = next_instaddress + {7'b0000000,imme[25:0],2'b00};

endmodule 