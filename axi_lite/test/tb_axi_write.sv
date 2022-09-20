
module tb_axi_write;
	
	reg ACLK;
	reg ARESETN;

	//write address channel
	reg [31:0] AWADDR;
	reg AWVALID;
	wire AWREADY;

	//write data channel
	reg [31:0]  WDATA;
	reg WVALID;
	wire  WREADY;

	//write response channel	
	wire [1:0]  BRESP;
	reg  BREADY;
	wire BVALID;

	//data output to external logic
	reg dev_ready;
	wire data_valid;
	wire [31:0] addr_out;
	wire [31:0] data_out; 

	axi_write uut0(.ACLK(ACLK),
					.ARESETN(ARESETN),

					.AWVALID(AWVALID),
					.AWREADY(AWREADY),
					.AWADDR(AWADDR),

					.WVALID(WVALID),
					.WREADY(WREADY),
					.WDATA(WDATA),

					.BRESP(BRESP),
					.BREADY(BREADY),
					.BVALID(BVALID),

					.dev_ready(dev_ready),
					.data_valid(data_valid),
					.addr_out(addr_out),
					.data_out(data_out)				
				);

	initial 
		begin
			dev_ready =1'b1;
			ACLK=1'b0;
			forever #5 ACLK=~ACLK;
		end
	initial	begin
			ARESETN=0;
			AWVALID=0;
			AWADDR=0;
			WVALID=0;
			WDATA=0;
			#16 ARESETN=1;
		
		#20
		
			AWVALID=1;
			AWADDR='b11;
			WVALID=1;
		#20
		
			WDATA='hfb13;
			BREADY=1;
			AWVALID=1;
			AWADDR=0;
			WVALID=1;
			BREADY=1;
		#20
		
			WDATA=0;
			AWVALID=0;
			AWADDR=0;
			WVALID=0;
			BREADY=0;
	end
endmodule 