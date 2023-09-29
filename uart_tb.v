`timescale 1ns/1ps
module testbench #(
    parameter n = 8,
    parameter f_MHz = 50,
    parameter f_baud = 115200
);
    localparam T_baud = f_MHz*1000000/f_baud;
    localparam T_wait = 1*T_baud;
    
    reg clk, rst_n, RX; //input
    wire recv_req, send_req, TX, send_ack; //output

    uart #(n, f_MHz, f_baud) duv(
        .clk(clk),
        .rst_n(rst_n),
        // RX 
        .RX(RX),
        .recv_req(recv_req),
        // TX 
        .send_req(send_req),
        .TX(TX),
        .send_ack(send_ack)
    );
			
    initial begin
        clk = 0;
        forever #0.5 clk = ~clk; // Tạo chu kỳ đồng hồ
    end
    
    initial begin
        rst_n = 1;
        #1 rst_n = 0;
        #1 rst_n = 1;
    end
    initial begin
        $random;
        #2;
        repeat(100000) begin
            RX = 0; // start_bit
            repeat(4) begin
                #T_baud
                RX = $random;
                #T_baud;    
            end
            #T_baud
            RX = 1; // stop_bit
            #T_wait;
        end
    end

endmodule