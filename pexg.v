//pexg模块：用来捕获gate信号和基准时钟信号的低电平
module pexg
(
	input    clk_fs,     // 基准时钟信号
	input    rst_n,  		// 复位信号
 
	input    clk_fx, 		//被测信号
			
	input 	gate,
	input 	gate_fs,  
	output   neg_gate_fs,
	output   neg_gate_fx
);
reg                gate_fs_d0  ;           // 用于采集基准时钟下gate下降沿
reg                gate_fs_d1  ;           // 
reg                gate_fx_d0  ;           // 用于采集被测时钟下gate下降沿
reg                gate_fx_d1  ;           // 		  
//wire define
 
//边沿检测，捕获信号下降沿
assign neg_gate_fs = gate_fs_d1 & (~gate_fs_d0);
assign neg_gate_fx = gate_fx_d1 & (~gate_fx_d0);
 
 
//打拍采门控信号的下降沿（被测时钟）
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n) begin
        gate_fx_d0 <= 1'b0;
        gate_fx_d1 <= 1'b0;
    end
    else begin
        gate_fx_d0 <= gate;
        gate_fx_d1 <= gate_fx_d0;
    end
end
 
//打拍采门控信号的下降沿（基准时钟）
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        gate_fs_d0 <= 1'b0;
        gate_fs_d1 <= 1'b0;
    end
    else begin
        gate_fs_d0 <= gate_fs;
        gate_fs_d1 <= gate_fs_d0;
    end
end
endmodule

