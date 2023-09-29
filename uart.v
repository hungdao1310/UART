module uart #(
    parameter n = 8,
    parameter f_MHz = 50,
    parameter baud_rate = 921600
) (
    input clk, rst_n, RX,
    output recv_req, send_req, TX, send_ack
);
    localparam T_baud = f_MHz*1000000/baud_rate;
    wire [n-1:0] register;
	 
    uart_rx #(n, f_MHz, baud_rate)
        rx(
            .clk(clk), .rst_n(rst_n), .recv_req(recv_req), 	
            .d_out(register), .RX(RX)
        );
		  
	 assign send_req = recv_req;
	 
    uart_tx #(n, f_MHz, baud_rate)
        tx(
            .clk(clk), .rst_n(rst_n), .send_req(recv_req),
            .send_ack(send_ack), .TX(TX), .d_in(register)
        );
endmodule 