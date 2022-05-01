module binTobcd
 #( parameter                W = 30)  // input width
  ( input      [W-1      :0] bin   ,  // binary
    output reg [W+(W-4)/3:0] bcd   ); // bcd {...,thousands,hundreds,tens,ones}

  integer i,j;

  always @(bin) begin
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     // initialize with zeros
    bcd[W-1:0] = bin;                                   // initialize with input vector
    for(i = 0; i <= W-4; i = i+1)                       // iterate on structure depth
      for(j = 0; j <= i/3; j = j+1)                     // iterate on structure width
        if (bcd[W-i+4*j -: 4] > 4)                      // if > 4
          bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; // add 3
  end

endmodule

module top_cymometer(
    //system clock
    input                  sys_clk  ,    // 时钟信号（系统时钟，50MHz）
    input                  rst_n,    // 复位信号
    input                  clk_fx   ,    // 被测时钟

	output[5:0]seg_sel,		//数码管位选择
	output[7:0]seg_data,		//数码管译码结果
	output gate_out
	);

wire locked;
wire  clkout1;        //pll clock output
wire  clkout2;        //pll clock output
wire  clkout3;        //pll clock output
wire  clkout4;         //pll clock output

wire[63:0] feq_bin;	// 频率，二进制
wire[30:0] feq_bcd; 	// 频率，bcd码
wire[3:0]	point_index;
wire gate_fs,neg_gate_fs,neg_gate_fx,gate;

assign gate_out =gate_fs;
//parameter define
parameter    CLK_FS = 26'd50000000;      // 基准时钟频率值
 

pll pll_inst
(
	// Clock in ports
	.inclk0(sys_clk),           // IN 50Mhz
	// Clock out ports
	.c0(clkout1),           // OUT 25Mhz
	.c1(clkout2),           // OUT 50Mhz
	.c2(clkout3),           // OUT 75Mhz
	.c3(clkout4),           // OUT 100Mhz
	// Status and control signals
	.areset(~rst_n),        // IN
	.locked(locked)         //The signal of PLL normal operation
); 

gate//生成门控信号
(
        .clk_fs      (clkout4),     // 基准时钟信号
        .rst_n       (rst_n),  // 复位信号
 
        //cymometer interface
        .clk_fx      (clk_fx   ), //待测信号
		  .gate(gate ) , //门控信号
		  .gate_fs(gate_fs) // 同步到基准时钟的门控信号
		  );
 
pexg//边沿捕获
(
        .clk_fs      (clkout4),     // 基准时钟信号
        .rst_n       (rst_n),  // 复位信号
 
		  .gate(gate ) , //门控信号
		  .gate_fs(gate_fs), // 同步到基准时钟的门控信号
       .clk_fx      (clk_fx), //待测信号
		
		  .neg_gate_fs(neg_gate_fs),
		  .neg_gate_fx(neg_gate_fx)
		  );
		  
cnt  
    (
	 
	 //system clock
        .clk_fs      (clkout4),     // 基准时钟信号
        .rst_n       (rst_n),  // 复位信号
 
        //cymometer interface
        .clk_fx      (clk_fx   ), //待测信号
		  .gate(gate )  ,//门控信号
		  .gate_fs(gate_fs) ,// 同步到基准时钟的门控信号
		  .neg_gate_fs(neg_gate_fs),
		  .neg_gate_fx(neg_gate_fx),
        	
        .frequency(feq_bin),
		  .point_index(point_index)
);


binTobcd
(
	.bin	(feq_bin),
	.bcd	(feq_bcd)
);
//assign feq_bcd[23:20] = feq_bin/17'd100000%4'd10;    // 万位
//assign feq_bcd[19:16] = feq_bin/13'd10000%4'd10;    // 万位
//assign feq_bcd[15:12] = feq_bin/10'd1000%4'd10;  // 千位
//assign feq_bcd[11:8]  = feq_bin/8'd100%4'd10;   // 百位
//assign feq_bcd[7:4]   = feq_bin/4'd10%4'd10;    // 十位
//assign feq_bcd[3:0]   = feq_bin%4'd10;       // 个位

seg_decode_scan seg_scan_m0(
    .clk        (sys_clk),
    .rst_n      (rst_n),
    .seg_sel    (seg_sel),
    .seg_data   (seg_data),
    .bcd 		 (feq_bcd[23:0]),
	 .point_index(point_index)
);

//wire[6:0] seg_data_0;
//seg_decoder seg_decoder_m0(
//    .bin_data  (feq_bcd[19:16]),
//    .seg_data  (seg_data_0)
//);
//
//wire[6:0] seg_data_1;
//seg_decoder seg_decoder_m1(
//    .bin_data  (feq_bcd[19:16]),
//    .seg_data  (seg_data_1)
//);
//wire[6:0] seg_data_2;
//seg_decoder seg_decoder_m2(
//    .bin_data  (feq_bcd[15:12]),
//    .seg_data  (seg_data_2)
//);
//wire[6:0] seg_data_3;
//seg_decoder seg_decoder_m3(
//    .bin_data  (feq_bcd[11:8]),
//    .seg_data  (seg_data_3)
//);
//wire[6:0] seg_data_4;
//seg_decoder seg_decoder_m4(
//    .bin_data  (feq_bcd[7:4]),
//    .seg_data  (seg_data_4)
//);
//wire[6:0] seg_data_5;
//seg_decoder seg_decoder_m5(
//    .bin_data  (feq_bcd[3:0]),
//    .seg_data  (seg_data_5)
//);
//
//seg_scan seg_scan_m0(
//    .clk        (sys_clk),
//    .rst_n      (rst_n),
//    .seg_sel    (seg_sel),
//    .seg_data   (seg_data),
//    .seg_data_0 ({1'b1,seg_data_0}),      //The  decimal point at the highest bit,and low level effecitve
//    .seg_data_1 ({1'b1,seg_data_1}), 
//    .seg_data_2 ({1'b1,seg_data_2}),
//    .seg_data_3 ({1'b1,seg_data_3}),
//    .seg_data_4 ({1'b1,seg_data_4}),
//    .seg_data_5 ({1'b1,seg_data_5})
//);
endmodule
