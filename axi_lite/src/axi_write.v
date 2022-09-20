	
module axi_write(
  //////////global control signals
  input ACLK,
  input ARESETN,
  
  //////////write address channel
  
  input 	   AWVALID,// master is sending new address  
  input [31:0] AWADDR, //write adress of transaction
  output reg   AWREADY,//slave is ready to accept request
      
  //////////write data channel
  
  input 	   WVALID,// master is sending new data
  input [31:0] WDATA, // data
  output reg   WREADY, // slave is ready to accept new data  
    
  //////////write response channel
 
  input            BREADY,//master is ready to accept response
  output reg       BVALID,//slave has valid response
  output reg [1:0] BRESP, // status of write transaction 
  
  //data output to external logic
    input          dev_ready,
	output  [31:0] data_out, 
	output  [31:0] addr_out, //address output to external logic
	output  data_valid	//signal indicating output data and address are valid
);
  
  	reg addr_done;
	reg data_done;

	//flip flops for latching data
	reg [31:0] addr_latch;
	reg [31:0] data_latch;
	reg data_valid_latch;

	assign data_out = data_latch;
	assign addr_out = addr_latch;
	assign data_valid = data_valid_latch ;
  

  //states
  parameter [2:0] awidle = 3'b000, awstart = 3'b001, wwait = 3'b010 , wlatch = 3'b011 , bwait = 3'b100 , bresp = 3'b101 ;
  reg [2:0]state;
  reg [2:0]awnext_state;
  

  /////////////RESET 
  always@(posedge ACLK, negedge ARESETN)
  begin
  	if(~ARESETN)
  		state <= awidle;
  	else
  		state <= awnext_state;
  end
  	
  
  /////////////fsm for write address, write data, write response channel
  always@(*)
    begin
        case(state)
     		 awidle:
      				begin
        				if( ~AWVALID | ~dev_ready)
        					awnext_state=awidle;
        				else
        					awnext_state = awstart;		  
     				end
      
      		awstart: 
      				begin
        				if(WVALID && dev_ready)  
        					awnext_state = wlatch;
        				else
          					awnext_state = wwait;
      				end
      

      		wwait: 
      				begin
      					if(WVALID && dev_ready)
      						awnext_state = wlatch;
      					else
      						awnext_state = wwait;
      				end

      		wlatch:
      				begin
      					if(BREADY )
      						awnext_state = bresp;
      					else
      						awnext_state = bwait;
      				end


      		bwait : begin
      					if(BREADY)
      						awnext_state = bresp ;
      					else
      						awnext_state = bwait;
      				end

      		bresp: 
      				begin
        				awnext_state = awidle;	
      				end  

      		default: 
      				begin
      					awnext_state = awidle;
      				end
     	endcase
    end


	always@(*)
		begin
			case(state)
				awidle: 
					begin
						AWREADY = 0;
						//AWREADY = 0;
						WREADY = 0;
						BVALID = 0;
						data_valid_latch = 0;
					end


      		awstart: 
      				begin
      					AWREADY = dev_ready;
						WREADY = 0;
      					addr_latch = AWADDR;
        				addr_done = AWVALID && dev_ready;
    	    		end
      

      		wwait: 
      				begin
      					AWREADY = 0;
      					WREADY = dev_ready;
      				end

      		wlatch:
      				begin
      					WREADY = dev_ready;
      					AWREADY = 0;
      					BVALID = 1;
      					data_latch = WDATA;
      					data_done = WVALID && WREADY;
      				end


      		bwait : begin
      					WREADY = 0;
      					BVALID = 1;
      				end

      		bresp: 
      				begin
      					data_valid_latch = data_done;
        				BVALID = 1;
        				BRESP = 2'b00;
      				end

      		default: 
      				begin
      					BVALID = 0;
        				BRESP = 2'b00;
      				end  
     		endcase
    	end	
endmodule // axi_slave
  









































/*
//write address handshake
//write data handshake
//keep track of which handshakes completed
//latching logic
//write response logic

module axi_write(
	input ACLK,
	//axi reset is active low
	input ARESETN,

	//write address channel
	input [1:0] AWADDR,
	input AWVALID,
	output reg AWREADY,

	//write data channel
	input [31:0]  WDATA,
	input WVALID,
	output reg WREADY,

	//write response channel	
	output [1:0]  BRESP,
	input  BREADY,
	output reg BVALID,

	//data output to external logic
	output [31:0] data_out, 
	output [1:0] addr_out, //address output to external logic
	output data_valid,	//signal indicating output data and address are valid
	output dev_ready
	);


	reg addr_done;
	reg data_done;

	//flip flops for latching data
	reg [31:0] data_latch;
	reg [1:0] addr_latch;

	assign data_out = data_latch;
	assign addr_out = addr_latch;
	assign data_valid = data_done & addr_done ;
	assign dev_ready = 1'b1;
	//always indicate OKAY status for writes
	assign  BRESP = 2'd0; 



	//write address handshake
	always @(posedge ACLK)
	begin
		if(~ARESETN | (AWVALID & AWREADY) | ~dev_ready )
			AWREADY<=0;
		else if(~AWREADY & AWVALID)
			AWREADY<=1;
	end


	//write data handshake
	always @(posedge ACLK)
	begin
		if( ARESETN==0 | (WVALID &  WREADY) | ~dev_ready )
			 WREADY<=0;
		else if( WREADY==0 & WVALID)
			 WREADY<=1;
	end


	//keep track of which handshakes completed
	always @(posedge ACLK)
	begin
		//reset or both phases done
		if( ARESETN==0 || (addr_done & data_done ) ) 
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
		if(~ARESETN)
			begin
				addr_latch<=2'd0;
				data_latch<=32'd0;
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
		if( ARESETN==0 | (BVALID &  BREADY) )
			BVALID<=0;
		else if(BVALID==0 & (data_done & addr_done) )
			BVALID<=1;	
	end
endmodule
















////////// read address channel
  
   output reg	ARREADY,  //read address ready signal from slave
   input [31:0]	ARADDR,	  //read address signal
   input	    ARVALID,  //address read valid signal
  
 //////////read data channel
   
   output reg RVALID,		//read data valid signal
   input RREADY,			//
   output reg [31:0] RDATA,  //read data from slave
   output reg [1:0] RRESP,	//read response signal

//////reset decoder 
  always@(posedge ACLK , negedge RESETN)
    begin
      if(!RESETN) begin
        awstate <= awidle;  //idle state for write address FSM
        wstate  <= widle;   //idle state for write data fsm
        bstate  <= bidle;   //idle state for write response fsm
        end
      else
        begin
        awstate <= awnext_state;
        wstate  <= wnext_state;
        bstate  <= bnext_state;
        end
    end

*/