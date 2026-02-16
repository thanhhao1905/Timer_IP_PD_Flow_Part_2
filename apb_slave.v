module apb_slave
(
	input wire psel,
	input wire pwrite,
	input wire penable,
	input wire [31:0]pwdata,
	input wire [11:0]paddr,
	input wire [3:0]pstrb,
	input wire pready_w,
	input wire [31:0]rdata,
	input wire [31:0]data0_out,
	output reg [11:0]addr,
	output reg wr_en,
	output reg rd_en,
	output reg [31:0]wdata,
	output reg [3:0]wstrb,
	output reg pready,
	output reg [31:0]prdata,
	output reg pslverr
);
	reg pslverr_w;

always @(*) begin

	wr_en   = psel && penable && pwrite && !pready_w;
	rd_en   = psel && penable && !pwrite && !pready_w;

	addr    = paddr;
	wdata   = pwdata;
	wstrb   = pstrb;
	pready  = pready_w;
	pslverr = pslverr_w;
	prdata  = rdata;
end

always @(*) begin
	pslverr_w =1'b0;
	if(psel && penable && pwrite && (paddr == 12'h000) && pstrb[1] ) begin
		if(data0_out[0]) begin
			if( (pwdata[1] != data0_out[1]) || (pwdata[11:8] >= 4'd9) || (pwdata[11:8] != data0_out[11:8]) ) begin
			pslverr_w =1'b1;
			end
		end else if (pwdata [11:8] >= 4'd9) begin
			pslverr_w =1'b1;
		end
	end
end

endmodule


