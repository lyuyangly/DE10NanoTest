module AxiMemRdCtrl (
    input                   ACLK        ,
    input                   ARESETn     ,
    output  reg [31:0]      ARADDR      ,
    output      [7:0]       ARLEN       ,
    output      [2:0]       ARSIZE      ,
    output      [1:0]       ARBURST     ,
    output  reg             ARVALID     ,
    input                   ARREADY     ,
    input       [31:0]      RDATA       ,
    input       [1:0]       RRESP       ,
    input                   RLAST       ,
    input                   RVALID      ,
    output  reg             RREADY      ,
    output                  FifoEmpty   ,
    input                   VideoClk    ,
    input                   VideoRstB   ,
    input                   VideoReq    ,
    output      [23:0]      VideoData
);

localparam  FB_BASE_ADDR = 32'h3000_0000;
localparam  FB_MAX_ADDR  = 32'd1280*32'd720*32'd4;

localparam  S_IDLE = 3'h1;
localparam  S_ARSU = 3'h2;

reg     [2:0]   RState;
reg     [31:0]  RdAddr;
wire            wr_en;
wire            wr_afull;
wire            rd_aempty;

always @(posedge ACLK or negedge ARESETn)
    if (ARESETn == 1'b0) begin
        RdAddr  <= 32'h0;
        RState  <= S_IDLE;
        ARVALID <= 1'b0;
        ARADDR  <= 32'h0;
        RREADY  <= 1'b0;
    end
    else begin
        case (RState)
            S_IDLE: begin
                if (~wr_afull && (RdAddr < FB_MAX_ADDR)) begin
                    ARVALID <= 1'b1;
                    ARADDR  <= FB_BASE_ADDR + RdAddr;
                    RState  <= S_ARSU;
                end
                else begin
                    ARVALID <= 1'b0;
                end
            end
            S_ARSU: begin
                if (ARVALID & ARREADY) begin
                    ARVALID <= 1'b0;
                    RState  <= S_IDLE;
                    if (RdAddr < FB_MAX_ADDR - 32'd64)
                        RdAddr <= RdAddr + 32'd64;
                    else
                        RdAddr <= 32'd0;
                end
            end
            default: RState <= S_IDLE;
        endcase
        RREADY <= ~wr_afull;
    end

assign ARLEN    = 8'hF;
assign ARSIZE   = 3'h2;
assign ARBURST  = 2'h1;

assign wr_en = RVALID & RREADY;

async_fifo #(
    .DP             (8192           ),
    .DW             (24             )
)   U_FBFIFO (
    .wr_clk         (ACLK           ),
    .wr_reset_n     (ARESETn        ),
    .wr_en          (wr_en          ),
    .wr_data        (RDATA[23:0]    ),
    .full           (),
    .afull          (wr_afull       ),
    .rd_clk         (VideoClk       ),
    .rd_reset_n     (VideoRstB      ),
    .rd_en          (VideoReq       ),
    .rd_data        (VideoData      ),
    .empty          (FifoEmpty      ),
    .aempty         ()
);

endmodule

