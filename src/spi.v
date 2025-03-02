module spi (
    input               clk,                // Clock 100 MHz
    input               rst_n,              // Reset active low
    input               spi_start,          // Start transmission
    input      [15:0]   data_tx,            // Data to send (2 bytes)
    input               miso,               // Master In Slave Out
    output reg  [7:0]   data_rx,            // Data received (2nd byte)
    output reg          sclk,               // Clock SPI (f = 100 / 32 = 3.125 MHz)
    output reg          mosi,               // Master Out Slave In
    output reg          cs_n,               // Chip Select (active low)
    output              spi_busy            // Busy flag
);

    reg [4:0]   bit_cnt;                    // Bit counter
    reg [4:0]   cnt;                        // State counter
    reg [15:0]  shift_reg;                  // Shift register
    reg [1:0]   state;                      // FSM state
    reg         miso_sync;                  // Synchronize MISO

    localparam  IDLE        = 2'b00, 
                LOAD        = 2'b01, 
                TRANSFER    = 2'b10, 
                DONE        = 2'b11;

    assign spi_busy = (state != IDLE);

    always @(posedge clk) begin
        miso_sync <= miso;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            sclk        <= 0;
            cs_n        <= 1;
            mosi        <= 0;
            data_rx     <= 0;
            bit_cnt     <= 0;
            cnt         <= 0;
            shift_reg   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    cs_n <= 1;
                    sclk <= 0;
                    if (spi_start) begin
                        state       <= LOAD;
                        shift_reg   <= data_tx;
                    end
                end
                LOAD: begin
                    cs_n    <= 0;
                    state   <= TRANSFER;
                    bit_cnt <= 16;
                end
                TRANSFER: begin
                    if (bit_cnt > 0) begin
                        cnt <= cnt + 1;
                        case (cnt)
                            0:  sclk <= 0;
                            8:  mosi <= shift_reg[15];                                
                            16: begin
                                sclk <= 1;
                                shift_reg <= {shift_reg[14:0], miso_sync};
                            end
                            24: bit_cnt <= bit_cnt - 1;
                        endcase
                    end else begin
                        cnt <= cnt + 1;
                        if (cnt == 0) begin
                            sclk    <= 0;
                            state   <= DONE;
                            data_rx <= shift_reg[7:0];
                        end
                    end
                end
                DONE: begin
                    cnt <= cnt + 1;
                    if (cnt == 16) begin
                        cnt     <= 0;
                        cs_n    <= 1;
                        state   <= IDLE;
                    end else begin
                        state   <= DONE;
                    end
                end
                default: state  <= IDLE;
            endcase
        end
    end
endmodule
