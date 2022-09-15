//read address handshake
//keep track of which handshakes completed
//latching logic

module axi_read_logic(
	input ACLK,
	//input rstn, 
	//axi is reset low
	input ARESETn,

	//read address channel
	input [1:0]ARADDR,		
	input ARVALID,			
	output reg ARREADY,		


	//read data channel
	input [31:0] RDATA,		
	input RVALID,			
	output reg RREADY,		
	
	//data output to external logic
	output [31:0] data_out, 
	output [1:0] addr_out, 	//address output to external logic
	output data_valid		//signal indicating output data and address are valid
	);


	reg addr_done;
	reg data_done;

	//flip flops for latching data
	reg [31:0] data_latch;
	reg [1:0] addr_latch;

	assign data_out = data_latch;
	assign addr_out = addr_latch;
	assign data_valid = data_done & addr_done;
	//always indicate OKAY status for reads
	assign read_resp = 2'd0;


	//read address handshake
	always @(posedge ACLK)
	begin
		if(~ARESETn | (ARVALID & ARREADY) )
			ARREADY<=0;
		else(~ARREADY & ARVALID)
			ARREADY<=1;
	end


	//read data handshake
	always @(posedge ACLK)
	begin
		if(~ARESETn | (RVALID & RREADY) )
			RREADY<=0;
		else(~RREADY & RVALID)
			RREADY<=1;
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
				//look for addr handshake
				if(ARVALID & ARREADY) 
					addr_done<=1;
				//look for data handshake
				if(RVALID & RREADY) 
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
				//Check for Read Handshake
				if(RVALID & RREADY) 	
					data_latch<=RDATA;
				//Check for Address Handshake
				if(ARVALID & ARREADY)	
					addr_latch<=ARADDR;
			end
	end
endmodule