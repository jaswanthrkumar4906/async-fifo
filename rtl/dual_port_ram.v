module dual_port_ram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wclk,
    input  wire                  wenc,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire                  rclk,
    input  wire [ADDR_WIDTH-1:0] raddr,
    output reg  [DATA_WIDTH-1:0] rdata
);

    // Memory array declaration (2^ADDR_WIDTH deep by DATA_WIDTH wide)
    reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];

    // Write operation on write clock domain
    always @(posedge wclk) begin
        if (wenc) begin
            mem[waddr] <= wdata;
        end
    end

    // Read operation on read clock domain (asynchronous read from register array)
    always @(posedge rclk) begin
        rdata <= mem[raddr];
    end

endmodule