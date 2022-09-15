//write address handshake
//write data handshake
//keep track of which handshakes completed
//latching logic
//write response logic

module axi_write_logic(
	input ACLK,
	//axi reset is active low
	input ARESETN,

	//write address channel
	input [1:0] AWADDR,
	input AWVALID,
	output reg AWREADY,

	//write data channel
	input [31:0]  WDATA ,
	input WVALID,
	output reg  WREADY,

	//write response channel	
	output [1:0]  BRESP,
	input  BREADY,
	output reg BVALID,

	//data output to external logic
	output [31:0] data_out, 
	output [1:0] addr_out, //address output to external logic
	output data_valid	//signal indicating output data and address are valid
	);


	reg addr_done;
	reg data_done;

	//flip flops for latching data
	reg [31:0] data_latch;
	reg [1:0] addr_latch;

	assign data_out = data_latch;
	assign addr_out = addr_latch;
	assign data_valid = data_done & addr_done;
	//always indicate OKAY status for writes
	assign  BRESP = 2'd0; 



	//write address handshake
	always @(posedge ACLK)
	begin
		if(~ARESETn | (AWVALID & AWREADY) )
			AWREADY<=0;
		else(~AWREADY & AWVALID)
			AWREADY<=1;
	end


	//write data handshake
	always @(posedge ACLK)
	begin
		if(~ARESETn | (WVALID &  WREADY) )
			 WREADY<=0;
		else(~ WREADY & WVALID)
			 WREADY<=1;
	end


	//keep track of which handshakes completed
	always @(posedge ACLK)
	begin
		//reset or both phases done
		if(ARESETn==0 || (addr_done & data_done) ) 
			begin
				addr_done<=0;
				data_done<=0;
			end
		else
			begin	
			if(AWVALID & AWREADY) //look for addr handshake
				addr_done<=1;
		
			if(WVALID &  WREADY) //look for data handshake
				data_done<=1;	
			end
	end


	//latching logic
	always @(posedge ACLK)
	begin
		if(ARESETn==0)
			begin
				data_latch<=32'd0;
				addr_latch<=2'd0;
			end
		else
			begin
				//look for data handshake
				if(WVALID &  WREADY) 
					data_latch<= WDATA;
			
				if(AWVALID & AWREADY)
					addr_latch<=AWADDR;
			end
	end


	//write response logic
	always @(posedge ACLK)
	begin	
		if( ARESETn==0 | (BVALID &  BREADY) )
			BVALID<=0;
		else(~BVALID & (data_done & addr_done) )
			BVALID<=1;	
	end
endmodule
