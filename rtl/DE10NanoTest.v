`timescale 1ns / 1ns
module DE10NanoTest (
    input                           FPGA_CLK1,
    input                           FPGA_CLK2,
    input                           FPGA_CLK3,
    input           [1:0]           KEY,
    input           [3:0]           SW,
    output          [7:0]           LED,
    inout                           HDMI_I2C_SCL,
    inout                           HDMI_I2C_SDA,
    inout                           HDMI_I2S,
    inout                           HDMI_LRCLK,
    inout                           HDMI_MCLK,
    inout                           HDMI_SCLK,
    output                          HDMI_TX_CLK,
    output          [23:0]          HDMI_TX_D,
    output                          HDMI_TX_HS,
    output                          HDMI_TX_VS,
    output                          HDMI_TX_DE,
    input                           HDMI_TX_INT,
    output                          HPS_DDR3_CK_P,
    output                          HPS_DDR3_CK_N,
    output                          HPS_DDR3_CKE,
    output                          HPS_DDR3_CS_N,
    output                          HPS_DDR3_RAS_N,
    output                          HPS_DDR3_CAS_N,
    output                          HPS_DDR3_WE_N,
    output          [14:0]          HPS_DDR3_ADDR,
    output          [2:0]           HPS_DDR3_BA,
    output          [3:0]           HPS_DDR3_DM,
    inout           [31:0]          HPS_DDR3_DQ,
    inout           [3:0]           HPS_DDR3_DQS_N,
    inout           [3:0]           HPS_DDR3_DQS_P,
    output                          HPS_DDR3_ODT,
    input                           HPS_DDR3_RZQ,
    output                          HPS_DDR3_RESET_N,
    output                          HPS_SD_CLK,
    inout                           HPS_SD_CMD,
    inout           [3:0]           HPS_SD_DATA,
    inout                           HPS_I2C0_SCLK,
    inout                           HPS_I2C0_SDAT,
    output                          HPS_UART_TX,
    input                           HPS_UART_RX,
    input                           HPS_USB_CLKOUT,
    inout           [7:0]           HPS_USB_DATA,
    input                           HPS_USB_DIR,
    input                           HPS_USB_NXT,
    output                          HPS_USB_STP,
    output                          HPS_ENET_GTX_CLK,
    inout                           HPS_ENET_INT_N,
    output                          HPS_ENET_MDC,
    inout                           HPS_ENET_MDIO,
    input                           HPS_ENET_RX_CLK,
    input           [3:0]           HPS_ENET_RX_DATA,
    input                           HPS_ENET_RX_DV,
    output          [3:0]           HPS_ENET_TX_DATA,
    output                          HPS_ENET_TX_EN,
    inout                           HPS_KEY,
    inout                           HPS_LED,
    inout                           HPS_CONV_USB_N,
    inout                           HPS_GSENSOR_INT
);

wire                            RstB;
wire                            RstSyncFCLK1;
wire                            RstSyncP;
wire                            RstSyncF;
wire                            H2F_RstB;
wire                            VPLL_Locked;
wire                            HDMI_READY;
wire                            PixelClk;
wire                            VideoReq;
wire    [23:0]                  VideoData;
wire                            FifoEmpty;
wire                            ACLK;
wire                            ARESETn;
wire    [31:0]                  ARADDR;
wire    [3:0]                   ARLEN;
wire    [2:0]                   ARSIZE;
wire    [1:0]                   ARBURST;
wire                            ARVALID;
wire                            ARREADY;
wire    [31:0]                  RDATA;
wire    [1:0]                   RRESP;
wire                            RLAST;
wire                            RVALID;
wire                            RREADY;

assign RstB = SW[0] & H2F_RstB & VPLL_Locked;

HDMI_PLL U_VPLL (
    .refclk                                                     (FPGA_CLK1                  ),
    .rst                                                        (1'b0                       ),
    .outclk_0                                                   (PixelClk                   ),
    .outclk_1                                                   (ACLK                       ),
    .locked                                                     (VPLL_Locked                )
);

RstSync U_RstSync (
    .Clk                                                        (FPGA_CLK1                  ),
    .RstB                                                       (RstB                       ),
    .RstBSync                                                   (RstSyncFCLK1               )
);

RstSync U_RstSync_A (
    .Clk                                                        (ACLK                       ),
    .RstB                                                       (RstSyncFCLK1 & HDMI_READY  ),
    .RstBSync                                                   (ARESETn                    )
);

RstSync U_RstSync_F (
    .Clk                                                        (ACLK                       ),
    .RstB                                                       (RstSyncFCLK1 & HDMI_READY  ),
    .RstBSync                                                   (RstSyncF                   )
);

RstSync U_RstSync_P (
    .Clk                                                        (PixelClk                   ),
    .RstB                                                       (RstSyncFCLK1 & HDMI_READY & ~FifoEmpty),
    .RstBSync                                                   (RstSyncP                   )
);


AxiMemRdCtrl U_AxiMemRdCtrl (
    .ACLK                                                       (ACLK                       ),
    .ARESETn                                                    (ARESETn                    ),
    .ARADDR                                                     (ARADDR                     ),
    .ARLEN                                                      (ARLEN                      ),
    .ARSIZE                                                     (ARSIZE                     ),
    .ARBURST                                                    (ARBURST                    ),
    .ARVALID                                                    (ARVALID                    ),
    .ARREADY                                                    (ARREADY                    ),
    .RDATA                                                      (RDATA                      ),
    .RRESP                                                      (RRESP                      ),
    .RLAST                                                      (RLAST                      ),
    .RVALID                                                     (RVALID                     ),
    .RREADY                                                     (RREADY                     ),
    .FifoEmpty                                                  (FifoEmpty                  ),
    .VideoClk                                                   (PixelClk                   ),
    .VideoRstB                                                  (RstSyncF                   ),
    .VideoReq                                                   (VideoReq                   ),
    .VideoData                                                  (VideoData                  )
);

VGACtrlTop U_VGACtrl (
    .PixelClk                                                   (PixelClk                   ),
    .RstB                                                       (RstSyncP                   ),
    .VideoDin                                                   (VideoData                  ),
    .VideoDE                                                    (HDMI_TX_DE                 ),
    .VideoHS                                                    (HDMI_TX_HS                 ),
    .VideoVS                                                    (HDMI_TX_VS                 ),
    .VideoReq                                                   (VideoReq                   ),
    .VideoXPos                                                  (),
    .VideoYPos                                                  (),
    .VideoDout                                                  (HDMI_TX_D                  )
);

assign HDMI_TX_CLK = PixelClk;

I2C_HDMI_Config U_I2C_HDMI_Config (
    .iCLK                                                       (FPGA_CLK1                  ),
    .iRST_N                                                     (RstSyncFCLK1               ),
    .I2C_SCLK                                                   (HDMI_I2C_SCL               ),
    .I2C_SDAT                                                   (HDMI_I2C_SDA               ),
    .HDMI_TX_INT                                                (HDMI_TX_INT                ),
    .READY                                                      (HDMI_READY                 )
);

HPS U_HPS (
    .clk_clk                                                    (FPGA_CLK1                  ),
    .reset_reset_n                                              (1'b1                       ),
    .hps_memory_mem_ck                                          (HPS_DDR3_CK_P              ),
    .hps_memory_mem_ck_n                                        (HPS_DDR3_CK_N              ),
    .hps_memory_mem_cke                                         (HPS_DDR3_CKE               ),
    .hps_memory_mem_cs_n                                        (HPS_DDR3_CS_N              ),
    .hps_memory_mem_ras_n                                       (HPS_DDR3_RAS_N             ),
    .hps_memory_mem_cas_n                                       (HPS_DDR3_CAS_N             ),
    .hps_memory_mem_we_n                                        (HPS_DDR3_WE_N              ),
    .hps_memory_mem_a                                           (HPS_DDR3_ADDR              ),
    .hps_memory_mem_ba                                          (HPS_DDR3_BA                ),
    .hps_memory_mem_dm                                          (HPS_DDR3_DM                ),
    .hps_memory_mem_dq                                          (HPS_DDR3_DQ                ),
    .hps_memory_mem_dqs                                         (HPS_DDR3_DQS_P             ),
    .hps_memory_mem_dqs_n                                       (HPS_DDR3_DQS_N             ),
    .hps_memory_mem_odt                                         (HPS_DDR3_ODT               ),
    .hps_memory_oct_rzqin                                       (HPS_DDR3_RZQ               ),
    .hps_memory_mem_reset_n                                     (HPS_DDR3_RESET_N           ),
    .hps_io_hps_io_emac1_inst_TX_CLK                            (HPS_ENET_GTX_CLK           ),
    .hps_io_hps_io_emac1_inst_TXD0                              (HPS_ENET_TX_DATA[0]        ),
    .hps_io_hps_io_emac1_inst_TXD1                              (HPS_ENET_TX_DATA[1]        ),
    .hps_io_hps_io_emac1_inst_TXD2                              (HPS_ENET_TX_DATA[2]        ),
    .hps_io_hps_io_emac1_inst_TXD3                              (HPS_ENET_TX_DATA[3]        ),
    .hps_io_hps_io_emac1_inst_RX_CLK                            (HPS_ENET_RX_CLK            ),
    .hps_io_hps_io_emac1_inst_RXD0                              (HPS_ENET_RX_DATA[0]        ),
    .hps_io_hps_io_emac1_inst_RXD1                              (HPS_ENET_RX_DATA[1]        ),
    .hps_io_hps_io_emac1_inst_RXD2                              (HPS_ENET_RX_DATA[2]        ),
    .hps_io_hps_io_emac1_inst_RXD3                              (HPS_ENET_RX_DATA[3]        ),
    .hps_io_hps_io_emac1_inst_RX_CTL                            (HPS_ENET_RX_DV             ),
    .hps_io_hps_io_emac1_inst_TX_CTL                            (HPS_ENET_TX_EN             ),
    .hps_io_hps_io_emac1_inst_MDC                               (HPS_ENET_MDC               ),
    .hps_io_hps_io_emac1_inst_MDIO                              (HPS_ENET_MDIO              ),
    .hps_io_hps_io_sdio_inst_CLK                                (HPS_SD_CLK                 ),
    .hps_io_hps_io_sdio_inst_CMD                                (HPS_SD_CMD                 ),
    .hps_io_hps_io_sdio_inst_D0                                 (HPS_SD_DATA[0]             ),
    .hps_io_hps_io_sdio_inst_D1                                 (HPS_SD_DATA[1]             ),
    .hps_io_hps_io_sdio_inst_D2                                 (HPS_SD_DATA[2]             ),
    .hps_io_hps_io_sdio_inst_D3                                 (HPS_SD_DATA[3]             ),
    .hps_io_hps_io_usb1_inst_D0                                 (HPS_USB_DATA[0]            ),
    .hps_io_hps_io_usb1_inst_D1                                 (HPS_USB_DATA[1]            ),
    .hps_io_hps_io_usb1_inst_D2                                 (HPS_USB_DATA[2]            ),
    .hps_io_hps_io_usb1_inst_D3                                 (HPS_USB_DATA[3]            ),
    .hps_io_hps_io_usb1_inst_D4                                 (HPS_USB_DATA[4]            ),
    .hps_io_hps_io_usb1_inst_D5                                 (HPS_USB_DATA[5]            ),
    .hps_io_hps_io_usb1_inst_D6                                 (HPS_USB_DATA[6]            ),
    .hps_io_hps_io_usb1_inst_D7                                 (HPS_USB_DATA[7]            ),
    .hps_io_hps_io_usb1_inst_CLK                                (HPS_USB_CLKOUT             ),
    .hps_io_hps_io_usb1_inst_STP                                (HPS_USB_STP                ),
    .hps_io_hps_io_usb1_inst_DIR                                (HPS_USB_DIR                ),
    .hps_io_hps_io_usb1_inst_NXT                                (HPS_USB_NXT                ),
    .hps_io_hps_io_uart0_inst_TX                                (HPS_UART_TX                ),
    .hps_io_hps_io_uart0_inst_RX                                (HPS_UART_RX                ),
    .hps_io_hps_io_i2c0_inst_SCL                                (HPS_I2C0_SCLK              ),
    .hps_io_hps_io_i2c0_inst_SDA                                (HPS_I2C0_SDAT              ),
    .hps_io_hps_io_gpio_inst_GPIO09                             (HPS_CONV_USB_N             ),
    .hps_io_hps_io_gpio_inst_GPIO35                             (HPS_ENET_INT_N             ),
    .hps_io_hps_io_gpio_inst_GPIO61                             (HPS_GSENSOR_INT            ),
    .hps_io_hps_io_gpio_inst_GPIO54                             (HPS_KEY                    ),
    .hps_io_hps_io_gpio_inst_GPIO53                             (HPS_LED                    ),
    .hps_h2f_reset_reset_n                                      (H2F_RstB                   ),
    .hps_f2h_axi_clock_clk                                      (ACLK                       ),
    .hps_f2h_axi_slave_araddr                                   (ARADDR                     ),
    .hps_f2h_axi_slave_arlen                                    (ARLEN                      ),
    .hps_f2h_axi_slave_arid                                     (8'h0                       ),
    .hps_f2h_axi_slave_arsize                                   (ARSIZE                     ),
    .hps_f2h_axi_slave_arburst                                  (ARBURST                    ),
    .hps_f2h_axi_slave_arlock                                   (2'h0                       ),
    .hps_f2h_axi_slave_arprot                                   (3'h0                       ),
    .hps_f2h_axi_slave_arvalid                                  (ARVALID                    ),
    .hps_f2h_axi_slave_arcache                                  (4'h0                       ),
    .hps_f2h_axi_slave_awaddr                                   (32'h0                      ),
    .hps_f2h_axi_slave_awlen                                    (4'h0                       ),
    .hps_f2h_axi_slave_awid                                     (8'h0                       ),
    .hps_f2h_axi_slave_awsize                                   (3'h0                       ),
    .hps_f2h_axi_slave_awburst                                  (2'h0                       ),
    .hps_f2h_axi_slave_awlock                                   (2'h0                       ),
    .hps_f2h_axi_slave_awprot                                   (3'h0                       ),
    .hps_f2h_axi_slave_awvalid                                  (1'b0                       ),
    .hps_f2h_axi_slave_awcache                                  (4'h0                       ),
    .hps_f2h_axi_slave_bresp                                    (2'h0                       ),
    .hps_f2h_axi_slave_bid                                      (8'h0                       ),
    .hps_f2h_axi_slave_bvalid                                   (1'b0                       ),
    .hps_f2h_axi_slave_bready                                   (1'b1                       ),
    .hps_f2h_axi_slave_arready                                  (ARREADY                    ),
    .hps_f2h_axi_slave_awready                                  (),
    .hps_f2h_axi_slave_rready                                   (RREADY                     ),
    .hps_f2h_axi_slave_rdata                                    (RDATA                      ),
    .hps_f2h_axi_slave_rresp                                    (RRESP                      ),
    .hps_f2h_axi_slave_rlast                                    (RLAST                      ),
    .hps_f2h_axi_slave_rid                                      (8'h0                        ),
    .hps_f2h_axi_slave_rvalid                                   (RVALID                     ),
    .hps_f2h_axi_slave_wlast                                    (1'b0                       ),
    .hps_f2h_axi_slave_wvalid                                   (1'b0                       ),
    .hps_f2h_axi_slave_wdata                                    (32'h0                      ),
    .hps_f2h_axi_slave_wstrb                                    (4'h0                       ),
    .hps_f2h_axi_slave_wready                                   (),
    .hps_f2h_axi_slave_wid                                      (8'h0                       ),
    .hps_f2h_boot_from_fpga_boot_from_fpga_ready                (1'b1                       ),
    .hps_f2h_boot_from_fpga_boot_from_fpga_on_failure           (1'b0                       )
);

assign LED = {4'hA, SW};

endmodule
