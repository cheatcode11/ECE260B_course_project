module synchronizer #(parameter width = 4)
    (clk, rst, in, out);

    input clk, rst;
    input [width-1:0] in;
    output reg [width-1:0] out;

    reg [width-1:0] stage1;

    always @(posedge clk ) begin
        if (rst) begin
            stage1 <= 0;
            out <= 0;
        end else begin
            stage1 <= in;
            out <= stage1;
        end
    end

endmodule
