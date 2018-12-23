/*
    // Instantiate clockDiv pixel with div = 32'd4, out =pixelClk    
    clockDiv pixel(.clk(clk),
                   .div(32'd4),
                   .out(pixelClk)
    );
*/
module clockDiv(input clk,
                input [31:0]div,
                output reg out);
    reg [31:0] count;
    reg inc;
    reg max;
    // All Always blocks run in parallel don't get confused
    always begin // This block will execute continuously and will update 'inc'
        max = div >> 1;
        inc = (count > max);
    end
    always@(posedge clk) begin
        case(inc)
            1:begin
                count = 0;
                out = ~out;
            end
            0:begin
                count = count + 1;
            end
        endcase
    end
endmodule