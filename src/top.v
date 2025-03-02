module top(
    input       clk,
    input       rst_n,
    input       miso,
    output      sclk,
    output      mosi,
    output      cs_n,
    output      rst,
    output      RGB1_B,
    output      RGB1_G,
    output      RGB1_R,
    output      RGB2_B,
    output      RGB2_G,
    output      RGB2_R
);

    wire        card_OK;
    wire [31:0] UID;

    rc522 rc522_inst(
        .clk            (clk),
        .rst_n          (rst_n),
        .miso           (miso),
        .sclk           (sclk),
        .mosi           (mosi),
        .cs_n           (cs_n),
        .rst            (rst),
        .UID            (UID),
        .card_OK        (card_OK),
        .RGB1_B         (RGB1_B),
        .RGB1_G         (RGB1_G),
        .RGB1_R         (RGB1_R),
        .RGB2_B         (RGB2_B),
        .RGB2_G         (RGB2_G),
        .RGB2_R         (RGB2_R)
    );

endmodule
