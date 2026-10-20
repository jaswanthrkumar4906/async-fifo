module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    // Write Domain
    input  wire                  wclk,
    input  wire                  wrst_n,
    input  wire                  winc,
    input  wire [DATA_WIDTH-1:0] wdata,
    output wire                  full,

    // Read Domain
    input  wire                  rclk,
    input  wire                  rrst_n,
    input  wire                  rinc,
    output wire [DATA_WIDTH-1:0] rdata,
    output wire                  empty
);

    // Pointers and synchronization signals
    reg  [ADDR_WIDTH:0] wptr, rptr;
    reg  [ADDR_WIDTH:0] wbin, rbin;
    wire [ADDR_WIDTH:0] wbin_next, rbin_next;
    wire [ADDR_WIDTH:0] wgray_next, rgray_next;
    wire [ADDR_WIDTH:0] wq2_rptr, rq2_wptr;

    // Memory address pointers
    wire [ADDR_WIDTH-1:0] waddr, raddr;
    wire                  wfull, rempty;

    // ---------------------------------------------------------
    // Memory instantiation
    // ---------------------------------------------------------
    assign waddr = wbin[ADDR_WIDTH-1:0];
    assign raddr = rbin[ADDR_WIDTH-1:0];

    dual_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_ram (
        .wclk(wclk),
        .wenc(winc && !full),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .raddr(raddr),
        .rdata(rdata)
    );

    // ---------------------------------------------------------
    // Synchronizers for Clock Domain Crossing (CDC)
    // ---------------------------------------------------------
    synchronizer #(
        .WIDTH(ADDR_WIDTH + 1)
    ) u_sync_r2w (
        .clk(wclk),
        .rst_n(wrst_n),
        .din(rptr),
        .dout(wq2_rptr)
    );

    synchronizer #(
        .WIDTH(ADDR_WIDTH + 1)
    ) u_sync_w2r (
        .clk(rclk),
        .rst_n(rrst_n),
        .din(wptr),
        .dout(rq2_wptr)
    );

    // ---------------------------------------------------------
    // Read Domain Logic (Pointer and Empty flag)
    // ---------------------------------------------------------
    assign rbin_next  = rbin + (rinc & !empty);
    assign rgray_next = (rbin_next >> 1) ^ rbin_next;
    assign rempty     = (rgray_next == rq2_wptr);

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
        rbin <= 0;
        rptr <= 0;
        end else begin
        rbin <= rbin_next;
        rptr <= rgray_next;
        end
    end

    assign empty = rempty;

    // ---------------------------------------------------------
    // Write Domain Logic (Pointer and Full flag)
    // ---------------------------------------------------------
    assign wbin_next  = wbin + (winc & !full);
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;
    
    // Full condition: MSB and MSB-1 inverted, remaining bits match
    assign wfull      = (wgray_next =={~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
        wbin <= 0;
        wptr <= 0;
        end else begin
        wbin <= wbin_next;
        wptr <= wgray_next;
        end
    end

    assign full = wfull;

endmodule