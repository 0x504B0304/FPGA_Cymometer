//gate模块：产生周期是待测信号周期整数倍（代码中为5000倍）的门信号gate
module gate
(
        input                 clk_fs ,     // 基准时钟信号
        input                 rst_n   ,  // 复位信号
 
        //cymometer interface
        input                 clk_fx ,//待测信号
		  output		reg				gate , //门控信号
		  output    reg           gate_fs // 同步到基准时钟的门控信号
		  );
		  
localparam   GATE_TIME = 'd5;        // 门控时间设置
reg    [15:0]   gate_cnt    ;           // 门控计数
 
reg             gate_fs_r   ;           // 用于同步gate信号的寄存器
 
//门控信号计数器，使用被测时钟计数
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n)
        gate_cnt <= 16'd0; 
    else if(gate_cnt == GATE_TIME + 'd2)
        gate_cnt <= 16'd0;
    else
        gate_cnt <= gate_cnt + 1'b1;
end
	  
 
//门控信号，拉高时间为GATE_TIME个实测时钟周期
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n)
        gate <= 1'b0;
    else if(gate_cnt < 'd1)
        gate <= 1'b0;     
    else if(gate_cnt < GATE_TIME + 'd1)
        gate <= 1'b1;
    else if(gate_cnt <= GATE_TIME + 'd2)
        gate <= 1'b0;
    else 
        gate <= 1'b0;
end
 
//将门控信号同步到基准时钟下
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        gate_fs_r <= 1'b0;
        gate_fs   <= 1'b0;
    end
    else begin
        gate_fs_r <= gate;
        gate_fs   <= gate_fs_r;
    end
end
endmodule
