`timescale 1ns/1ps

module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    // Testbench signals
    reg                  wclk;
    reg                  wrst_n;
    reg                  winc;
    reg [DATA_WIDTH-1:0] wdata;
    wire                 full;

    reg                  rclk;
    reg                  rrst_n;
    reg                  rinc;
    wire [DATA_WIDTH-1:0] rdata;
    wire                 empty;

    // Instantiate Unit Under Test (UUT)
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .wdata(wdata),
        .full(full),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rdata(rdata),
        .empty(empty)
    );

    // Generate Write Clock (~25MHz -> 40ns period)
    always #20 wclk = ~wclk;

    // Generate Read Clock (~16.6MHz -> 60ns period - asynchronous clock domain)
    always #30 rclk = ~rclk;

    initial begin
        // Initialize signals
        wclk   = 0;
        wrst_n = 0;
        winc   = 0;
        wdata  = 0;
        rclk   = 0;
        rrst_n = 0;
        rinc   = 0;

        // Dump waveforms for GTKWave viewing
        $dumpfile("waveform.vcd");
        $dumpvars(0, fifo_tb);

        // Apply reset
        #50;
        wrst_n = 1;
        rrst_n = 1;
        #50;

        // Write data into FIFO
        @(posedge wclk);
        winc  = 1;
        wdata = 8'hAA;
        @(posedge wclk);
        wdata = 8'hBB;
        @(posedge wclk);
        wdata = 8'hCC;
        winc  = 0;

        // Read data back from FIFO
        #100;
        @(posedge rclk);
        rinc = 1;
        @(posedge rclk);
        @(posedge rclk);
        rinc = 0;

        #200;
        $finish;
    end

endmodule