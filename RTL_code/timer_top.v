module timer_top
(
	input wire sys_clk,
	input wire sys_rst_n,
	input wire tim_psel,
	input wire tim_pwrite,
	input wire tim_penable,
	input wire [11:0] tim_paddr,
	input wire [31:0] tim_pwdata,
	input wire [3:0] tim_pstrb,
	input wire dbg_mode,
	output wire [31:0] tim_prdata,
	output wire tim_pready,
	output wire tim_pslverr,
	output wire tim_int
);

	wire wr_en_w, rd_en_w, pready_w_w, pslverr_w_w;
	wire [31:0] wdata_w;
	wire [11:0] addr_w;
	wire [3:0] wstrb_w;
	wire [31:0] rdata_w;
	wire [31:0] data0_out_w;
	
	assign tim_pslverr = pslverr_w_w;

	apb_slave apb
(
	.psel(tim_psel),
	.pwrite(tim_pwrite),
	.penable(tim_penable),
	.pwdata(tim_pwdata),
	.paddr(tim_paddr),
	.pstrb(tim_pstrb),
	.pready_w(pready_w_w),
	.rdata(rdata_w),
	.data0_out(data0_out_w),
	.addr(addr_w),
	.wr_en(wr_en_w),
	.rd_en(rd_en_w),
	.wdata(wdata_w),
	.wstrb(wstrb_w),
	.pready(tim_pready),
	.prdata(tim_prdata),
	.pslverr(pslverr_w_w)
);

	
	reg_module register
(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.wr_en(wr_en_w),
	.rd_en(rd_en_w),
	.addr(addr_w),
	.wdata(wdata_w),
	.wstrb(wstrb_w),
	.debug_mode(dbg_mode),
	.pready_w(pready_w_w),
	.rdata(rdata_w),
	.data0_out(data0_out_w),
	.pslverr(pslverr_w_w),
	.timer_int(tim_int)
);

endmodule
