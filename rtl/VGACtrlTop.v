module VGACtrlTop (
    input               PixelClk,
    input               RstB,
    input       [23:0]  VideoDin,
    output  reg         VideoDE,
    output  reg         VideoHS,
    output  reg         VideoVS,
    output              VideoReq,
    output      [11:0]  VideoXPos,
    output      [11:0]  VideoYPos,
    output  reg [23:0]  VideoDout
);

// VGA 1920 X 1080 Timing 74.25M@30Hz
//localparam  H_SYNC  = 12'd44;
//localparam  H_BACK  = 12'd148;
//localparam  H_DISP  = 12'd1920;
//localparam  H_FRONT = 12'd88;
//localparam  V_SYNC  = 12'd5;
//localparam  V_BACK  = 12'd36;
//localparam  V_DISP  = 12'd1080;
//localparam  V_FRONT = 12'd4;
// VGA 1280 X 720 Timing 74.25M@60Hz
localparam  H_SYNC  = 12'd40;
localparam  H_BACK  = 12'd220;
localparam  H_DISP  = 12'd1280;
localparam  H_FRONT = 12'd110;
localparam  V_SYNC  = 12'd5;
localparam  V_BACK  = 12'd20;
localparam  V_DISP  = 12'd720;
localparam  V_FRONT = 12'd5;
// VGA 1024 X 768 Timing 65M@60Hz
//localparam  H_SYNC  = 12'd136;
//localparam  H_BACK  = 12'd160;
//localparam  H_DISP  = 12'd1024;
//localparam  H_FRONT = 12'd24;
//localparam  V_SYNC  = 12'd6;
//localparam  V_BACK  = 12'd29;
//localparam  V_DISP  = 12'd768;
//localparam  V_FRONT = 12'd3;
// VGA 800 X 600 Timing 40M@60Hz
//localparam  H_SYNC  = 12'd128;
//localparam  H_BACK  = 12'd88;
//localparam  H_DISP  = 12'd800;
//localparam  H_FRONT = 12'd40;
//localparam  V_SYNC  = 12'd4;
//localparam  V_BACK  = 12'd23;
//localparam  V_DISP  = 12'd600;
//localparam  V_FRONT = 12'd1;

localparam  H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;
localparam  V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;

reg     [11:0]  HCnt;
reg     [11:0]  VCnt;

always @(posedge PixelClk or negedge RstB)
    if (RstB == 1'b0) begin
        HCnt <= 12'd0;
        VCnt <= 12'd0;
    end
    else begin
        if (HCnt < H_TOTAL - 12'd1)
            HCnt <= HCnt + 12'd1;
        else begin
            HCnt <= 12'd0;
            if (VCnt < V_TOTAL - 12'd1)
                VCnt <= VCnt + 12'd1;
            else
                VCnt <= 12'd0;
        end
    end

assign VideoReq  = (HCnt >= H_SYNC + H_BACK && HCnt < H_SYNC + H_BACK + H_DISP) && (VCnt >= V_SYNC + V_BACK && VCnt < V_SYNC + V_BACK + V_DISP);
assign VideoXPos = VideoReq ? HCnt - (H_SYNC + H_BACK) : 12'd0;
assign VideoYPos = VideoReq ? VCnt - (V_SYNC + V_BACK) : 12'd0;

always @(posedge PixelClk or negedge RstB)
    if (RstB == 1'b0) begin
        VideoDE     <= 1'b0;
        VideoHS     <= 1'b0;
        VideoVS     <= 1'b0;
        VideoDout   <= 24'hFFFFFF;
    end
    else begin
        VideoDE     <= VideoReq;
        VideoHS     <= HCnt < H_SYNC;
        VideoVS     <= VCnt < V_SYNC;
        VideoDout   <= VideoReq ? VideoDin : 24'hFFFFFF;
    end

endmodule

