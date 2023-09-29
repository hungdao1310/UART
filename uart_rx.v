module uart_rx #(
    parameter n = 8,
    parameter f_MHz = 50,
    parameter baud_rate = 9600 
)(
    input clk, rst_n, RX,
    output recv_req, bit_begin,
    output [n-1:0] d_out,
    output [n+1:0] reg_RX // Thanh ghi lÆ°u láº¡i cÃ¡c bit RX nháº­n Ä‘Æ°á»£c
);
    localparam T_baud = f_MHz*1000000/baud_rate;
    wire inc_i, inc_t, rst_i, rst_t, i_eq_10, i_eq_0;
    wire t_eq_T_baud, t_eq_T_baud_half, load_bit, recv_signal;
    wire [1:0] state;

    datapath1 #(n, T_baud)
             dp(.clk(clk), .rst_n(rst_n), .inc_i(inc_i), .inc_t(inc_t), .recv_req(recv_req),
                .rst_i(rst_i), .rst_t(rst_t), .i_eq_10(i_eq_10), .t_eq_T_baud(t_eq_T_baud),
                .i_eq_0(i_eq_0), .t_eq_T_baud_half(t_eq_T_baud_half), .B(reg_RX), .recv_signal(recv_signal),
                .d_out(d_out), .bit_begin(bit_begin), .load_bit(load_bit), .RX(RX)
                );
    control1 cu(.clk(clk), .rst_n(rst_n), .inc_i(inc_i), .inc_t(inc_t),
               .rst_i(rst_i), .rst_t(rst_t), .i_eq_10(i_eq_10), .t_eq_T_baud(t_eq_T_baud),
               .i_eq_0(i_eq_0), .t_eq_T_baud_half(t_eq_T_baud_half), 
               .recv_signal(recv_signal), .bit_begin(bit_begin), .load_bit(load_bit)
               );
endmodule

module control1 (
    input clk, rst_n,
    input i_eq_10, i_eq_0, t_eq_T_baud, t_eq_T_baud_half, bit_begin,
    output reg inc_i, inc_t, rst_i, rst_t, load_bit, recv_signal
);
    localparam idle = 2'b00;
    localparam special_bit = 2'b01;
    localparam recv_bit = 2'b10;
    reg [1:0] next_state;
    reg [1:0] state;

    always @(state, i_eq_0, i_eq_10, t_eq_T_baud, t_eq_T_baud_half, bit_begin)
    begin
        inc_i = 0; inc_t = 0; rst_i = 0; rst_t = 0; 
        recv_signal = 0; load_bit = 0; next_state = state; 
        if (state == idle)
        begin
            if (bit_begin)
            begin
                rst_t = 1;
                rst_i = 1;
                next_state = special_bit;
            end
        end
        else if (state == special_bit)
        begin
            if (~t_eq_T_baud_half)
            begin
                inc_t = 1;
            end
				else if (t_eq_T_baud_half && i_eq_0)
            begin
                inc_i = 1;
                rst_t = 1;
                next_state = recv_bit;
            end
            else if (t_eq_T_baud_half && i_eq_10 && (~bit_begin))
            begin
                recv_signal = 1;
                load_bit = 1;
                next_state = idle;
            end
				else if (t_eq_T_baud_half && i_eq_10 && bit_begin)
				begin
                recv_signal = 1;
                load_bit = 1;
                rst_t = 1;
                rst_i = 1;
            end
        end
        else //state = recv_bit
        begin
            if (i_eq_10)
            begin
                next_state = special_bit;
                rst_t = 1;
            end
            if (~t_eq_T_baud) 
            begin
                inc_t = 1;
            end
            else if (t_eq_T_baud)
            begin
                rst_t = 1;
                inc_i = 1; 
            end
        end
    end

    always @(posedge clk or negedge rst_n) 
    begin
        if (~rst_n)
        begin
            // reset
            state <= idle;
        end
        else
        begin
            state <= next_state;
        end
    end
endmodule

module datapath1 #(
    parameter n = 8,
    parameter T_baud = 5200
)(
    input clk, rst_n, RX,
    input inc_i, inc_t, rst_i, rst_t, load_bit, recv_signal,
    output i_eq_0, i_eq_10, t_eq_T_baud, t_eq_T_baud_half, bit_begin, 
    output reg recv_req,
    output reg [n-1:0] d_out,
    output reg [n+1:0] B
);
    reg [$clog2(n+2)-1:0] cnt_i = 0;
    reg [$clog2(T_baud)-1:0] cnt_t = 0;
    
    
    assign i_eq_0 = (cnt_i == 0)?1:0;
    assign i_eq_10 = (cnt_i == n + 2)?1:0;
    assign t_eq_T_baud = (cnt_t == T_baud - 1)?1:0;
    assign t_eq_T_baud_half = (cnt_t == (T_baud >> 1) - 1)?1:0;
    assign bit_begin = ((1) && (~RX))?1:0;

    always @(posedge clk or negedge rst_n) 
    begin
        if (~rst_n)
        begin
            B <= 0;
        end
        else
        begin
            if ((load_bit) && (recv_signal))
            begin
                if (rst_t && rst_i)
                begin
                    d_out <= B[n:1];
                    recv_req <= 1;
                    cnt_i <= 0;
                    cnt_t <= 0;
                end
                else
                begin
                    d_out <= B[n:1];
                    recv_req <= 1;
                end
            end
            else 
            begin
                recv_req <= 0;
                if (inc_t)
                begin
                    cnt_t <= cnt_t + 1;
                end
                else if (inc_i && rst_t)
                begin
                    cnt_i <= cnt_i + 1;
                    cnt_t <= 0;
                    B <= {RX, B[n+1:1]}; // B >> 1
                end
                else if (rst_i && rst_t)
                begin
                    cnt_i <= 0;
                    cnt_t <= 0;
                end
                else if (rst_t)
                begin
                    cnt_t <= 0;
                end
            end
        end
    end
endmodule   