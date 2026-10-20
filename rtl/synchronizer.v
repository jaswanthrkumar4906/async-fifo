module synchronizer #(
    parameter WIDTH = 5
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] din,
    output reg  [WIDTH-1:0] dout
);

    reg [WIDTH-1:0] q1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1   <= {WIDTH{1'b0}};
            dout <= {WIDTH{1'b0}};
        end else begin
            q1   <= din;
            dout <= q1;
        end
    end

endmodule
