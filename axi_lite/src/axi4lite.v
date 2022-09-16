//Code for AXI_4Lite where we are using 2 modules ,seperate for Read and Write 
//These Modules are nothing but FSMs for Read and Config for AXI_4 Lite Slave

module AXI_4Lite(input AXI_CLK,input AXI_RESETn);

axi_4_write uut2(.ACLK(AXI_CLK),.ARESETn(AXI_RESETn));

axi_4_read uut1(.ARVALID(ARVALID),.ARREADY(ARREADY),.ARADDR(ARADDR),
				.RVALID(RVALID),.RREADY(RREADY),
				.RDATA(RDATA),.RRESP(RRESP),.ACLK(AXI_CLK),.ARESETn(AXI_RESETn));
endmodule