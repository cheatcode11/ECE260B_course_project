module async_fifo #(parameter depth = 8, parameter data_width = 8)
    (wr_clk, wr_rst, rd_clk, rd_rst, wr, rd, wr_data, rd_data, full, empty);

    input wr_clk, wr_rst; 
    input rd_clk, rd_rst; 
    input wr; 
    input rd; 
    input [data_width-1:0] wr_data; 
    output reg [data_width-1:0] rd_data; 
    output full;
    output empty;
    parameter ptr_width = $clog2(depth) + 1;

    reg [ptr_width-1:0] bwr_ptr, brd_ptr; 
    reg [ptr_width-1:0] gwr_ptr, grd_ptr; 
    wire [ptr_width-1:0] gwr_ptr_sync, grd_ptr_sync; 
    reg [31:0] error;
    reg [data_width-1:0] fifo [0:depth]; 

    synchronizer #(.width(ptr_width)) sync_wptr (rd_clk, rd_rst, gwr_ptr, gwr_ptr_sync);
    synchronizer #(.width(ptr_width)) sync_rptr (wr_clk, wr_rst, grd_ptr, grd_ptr_sync);

    always @(posedge wr_clk ) begin
        if (wr_rst) begin
            bwr_ptr <= 0;
            gwr_ptr <= 0;
            error<= 0;
        end 
        else if (wr && !full) begin
            bwr_ptr <= bwr_ptr + 1;
            gwr_ptr <= (bwr_ptr + 1) ^ ((bwr_ptr + 1) >> 1);
        end
    end

    always @(posedge rd_clk ) begin
        if (rd_rst) begin
            brd_ptr <= 0;
            grd_ptr <= 0;
            rd_data <= 0;
        end 
        else if (rd && !empty) begin
            brd_ptr <= brd_ptr + 1;
            grd_ptr <= (brd_ptr + 1) ^ ((brd_ptr + 1) >> 1);
        end
    end

    // Write logic
    always @(posedge wr_clk) begin
        if (wr && !full) begin
            fifo[bwr_ptr] <= wr_data;
        end
        else 
        error = error + 1;
    end

    // Read logic
    always @(posedge rd_clk) begin
        if (rd && !empty) begin
            rd_data <= fifo[brd_ptr];
        end
        else
        error = error + 1;
    end

    // Full and empty logic
    assign full = (wr_rst) ? 1'b0 : (bwr_ptr[ptr_width-2] == brd_ptr[ptr_width-2]) && ((brd_ptr[ptr_width-1] != bwr_ptr[ptr_width-1]));
    assign empty = (rd_rst) ? 1'b0 : (bwr_ptr == brd_ptr);

endmodule

