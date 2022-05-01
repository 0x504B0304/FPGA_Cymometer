//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//==========================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------
//  2017/6/19     meisq         1.0         Original
//*************************************************************************/
module seg_decode_scan(
	input           clk,
	input           rst_n,
	output reg[5:0] seg_sel,      //digital led chip select
	output reg[7:0] seg_data,     //eight segment digital tube output,MSB is the decimal point
	input[23:0]      bcd,
	input[3:0]		 point_index	//
);
parameter SCAN_FREQ = 200;     //scan frequency
parameter CLK_FREQ = 50000000; //clock frequency

parameter SCAN_COUNT = CLK_FREQ /(SCAN_FREQ * 6) - 1;

reg[31:0] scan_timer;  //scan time counter
reg[3:0] scan_sel;     //Scan select counter
reg[3:0] dig;
wire[6:0] seg_data_7;
seg_decoder seg_decoder_m0(
    .bin_data  (dig),
    .seg_data  (seg_data_7)
);

always@(posedge clk or negedge rst_n)
begin

	if(rst_n == 1'b0)
	begin
		scan_timer <= 32'd0;
		scan_sel <= 4'd0;
	end
	else if(scan_timer >= SCAN_COUNT)
	begin
		scan_timer <= 32'd0;
		if(scan_sel == 4'd0)
		begin
			scan_sel <= 4'd5;
		end
		else
		begin
			scan_sel <= scan_sel - 4'd1;
		end
	end
	else
		begin
			scan_timer <= scan_timer + 32'd1;
		end
end
issp
(
	.probe (frist_non_zer),
	.source(),
);
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		seg_sel <= 6'b111111;
		seg_data <= 8'hff;
	end
	else
	begin
		case(scan_sel)
			4'd0:
			begin
				seg_sel <= 6'b011111;
			end
			4'd1:
			begin
				seg_sel <= 6'b101111;
			end
			//...
			4'd2:
			begin
				seg_sel <= 6'b110111;
			end
			4'd3:
			begin
				seg_sel <= 6'b111011;
			end
			4'd4:
			begin
				seg_sel <= 6'b111101;
			end
			4'd5:
			begin
				seg_sel <= 6'b111110;
			end
			default:
			begin
				seg_sel <= 6'b111111;
			end
		endcase
		//if(scan_sel<frist_non_zer)
		//begin
			if(scan_sel==point_index)
				begin
					seg_data <= 1'b0<<7|seg_data_7;
				end
			else
				begin
					seg_data <= 1'b1<<7|seg_data_7;
				end
			dig<=bcd>>4*scan_sel;
		//end
		//else
			//seg_data<=8'b11111111;
	end
end

endmodule