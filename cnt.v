module cnt
   #(parameter    CLK_FS = 64'b100110001001011010000000,// 基准时钟频率,100M
	parameter  MAX       =  10'd64)  // 定义数据位宽        
    (   //system clock
        input                 clk_fs ,     // 时钟信号
        input                 rst_n   ,  // 复位信号
 
        //cymometer interface
        input                 clk_fx ,     // 待测信号
		input gate,       // 门控信号（与待测时钟同步）
		input gate_fs,    // 与基准时钟同步的门控信号
		input  neg_gate_fx,//
		input  neg_gate_fs,//
        
//		output reg	[MAX-1:0]   fs_cnt      ,           //门控时间内基准时钟信号的个数 
//		output reg	[MAX-1:0]   fx_cnt      ,          // 门控时间内待测信号的个数
		output reg	[MAX-1:0]   frequency,  // 待测信号的频率值
		output reg	[3:0]	point_index			//小数点位置
);
 
 
reg   [MAX-1:0]   fs_cnt_temp ;           // fs_cnt 计数
reg   [MAX-1:0]   fx_cnt_temp ;           // fx_cnt 计数
reg	[MAX-1:0]   fs_cnt      ;           //门控时间内基准时钟信号的个数 
reg	[MAX-1:0]   fx_cnt      ;          // 门控时间内待测信号的个数
reg	[MAX-1:0]   fs_cnt_     ;          // 临时
//wire    [MAX-1:0]   tmp ;           			 //临时存放商
reg    [MAX-1:0]   product_temp;          // 临时存放CLK_FS*fx_cnt的积

////多周期除法器
//devide div
//(
//	.clock (clk_fs),
//	.denom (fs_cnt),	//除数
//	.numer (CLK_FS*fx_cnt),		//被除数
//	.quotient(tmp),	//商
//	.remain()	//余数
//);


//门控时间内待测信号的计数，设置的为5000个，这里重新计数，只是用于检验信号是否正确
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n) begin
        fx_cnt_temp <= 32'd0;
        fx_cnt <= 32'd0;
    end
    else if(gate)begin
      fx_cnt_temp <= fx_cnt_temp + 1'b1;
    end   
    else if(neg_gate_fx) begin
        
        fx_cnt_temp <= 32'd0;
        fx_cnt <= fx_cnt_temp;
    end
end
 
//门控时间内基准时钟的计数
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        fs_cnt_temp <= 32'd0;
        fs_cnt <= 32'd0;
    end
    else if(gate_fs)
        begin
        fs_cnt_temp <= fs_cnt_temp + 1'b1;
        end
    else if(neg_gate_fs) begin
        fs_cnt_temp <= 32'd0;
		  fs_cnt <= fs_cnt_temp;
    end
end

//计算待测信号的频率值
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
	 //初值赋零
        frequency <= 64'd0;
    end
    else if(gate_fs&&(fs_cnt!=64'd0))
	 begin
			if(fs_cnt < 'd500)
			begin
				product_temp<=64'd5_000_000_000;
				fs_cnt_<=fs_cnt*'d100;
				point_index<=1;
			end
			else if(fs_cnt < 'd5000)
			begin
				product_temp<=64'd5_000_000_000;
				fs_cnt_<=fs_cnt*'d10;
				point_index<=2;
			end
			else if(fs_cnt > 64'd1_000_000)
			begin
				product_temp<=64'd50_000_000_000;
				fs_cnt_<=fs_cnt;
				point_index<=2;
			end
//			else if(fs_cnt > 64'd10_000_000)
//			begin
//				product_temp<=64'd50_000_000_000;
//				fs_cnt_<=fs_cnt;
//				point_index<=1;
//			end
			else
			begin
				product_temp<=64'd5_000_000_000;
				fs_cnt_<=fs_cnt;
				point_index<=0;
			end
			frequency <= product_temp/fs_cnt_;
	 end
 end
endmodule

