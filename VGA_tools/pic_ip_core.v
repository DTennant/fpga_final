module vga_driver
(
    input                   I_clk   , // 系统100MHz时钟
    input                   I_rst_n , // 系统复位
    output   reg   [3:0]    O_red   , // VGA红色分量
    output   reg   [3:0]    O_green , // VGA绿色分量
    output   reg   [3:0]    O_blue  , // VGA蓝色分量
    output                  O_hs    , // VGA行同步信�?
    output                  O_vs      // VGA场同步信�?
);

// 分辨率为640*480时行时序各个参数定义
parameter       C_H_SYNC_PULSE      =   96  , 
                C_H_BACK_PORCH      =   48  ,
                C_H_ACTIVE_TIME     =   640 ,
                C_H_FRONT_PORCH     =   16  ,
                C_H_LINE_PERIOD     =   800 ;

// 分辨率为640*480时场时序各个参数定义               
parameter       C_V_SYNC_PULSE      =   2   , 
                C_V_BACK_PORCH      =   33  ,
                C_V_ACTIVE_TIME     =   480 ,
                C_V_FRONT_PORCH     =   10  ,
                C_V_FRAME_PERIOD    =   525 ;

parameter       C_IMAGE_WIDTH       =   128     ,
                C_IMAGE_HEIGHT      =   128     ,
                C_IMAGE_PIX_NUM     =   16384   ;              

parameter       C_H_OFFSET          =   256     ,
                C_V_OFFSET          =   128     ,
                C_H_OFFSET_1        =   256     ,
                C_V_OFFSET_1        =   256     ;

reg     [11:0]      R_h_cnt         ; // 行时序计数器
reg     [11:0]      R_v_cnt         ; // 列时序计数器

reg     [13:0]      R_santa_addr    ;
wire    [15:0]      W_santa_data    ;

wire            W_active_flag   ; // �?活标志，当这个信号为1时RGB的数据可以显示在屏幕�?

//////////////////////////////////////////////////////////////////
//功能�? 产生25MHz的像素时�?
//////////////////////////////////////////////////////////////////
clockDiv pixel(.clk(I_clk),
               .div(32'd4),
               .out(R_clk_25M)
);
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// 功能：产生行时序
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
        R_h_cnt <=  12'd0   ;
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
        R_h_cnt <=  12'd0   ;
    else
        R_h_cnt <=  R_h_cnt + 1'b1  ;
end                

assign O_hs =   (R_h_cnt < C_H_SYNC_PULSE) ? 1'b0 : 1'b1    ; 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// 功能：产生场时序
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n)
        R_v_cnt <=  12'd0   ;
    else if(R_v_cnt == C_V_FRAME_PERIOD - 1'b1)
        R_v_cnt <=  12'd0   ;
    else if(R_h_cnt == C_H_LINE_PERIOD - 1'b1)
        R_v_cnt <=  R_v_cnt + 1'b1  ;
    else
        R_v_cnt <=  R_v_cnt ;                        
end                

assign O_vs =   (R_v_cnt < C_V_SYNC_PULSE) ? 1'b0 : 1'b1    ; 
//////////////////////////////////////////////////////////////////  

// 产生有效区域标志，当这个信号为高时往RGB送的数据才会显示到屏幕上
assign W_active_flag =  (R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH                     ))  &&
                        (R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_ACTIVE_TIME     ))  && 
                        (R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH                    ))  &&
                        (R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_ACTIVE_TIME     ))  ;                     

//////////////////////////////////////////////////////////////////
// 功能：把ROM里面的图片数据输�?
//////////////////////////////////////////////////////////////////
always @(posedge R_clk_25M or negedge I_rst_n)
begin
    if(!I_rst_n) 
        R_rom_addr  <=  14'd0 ;
    else if(W_active_flag)     
        begin
               if(R_h_cnt >= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_OFFSET_1                       )  && 
                   R_h_cnt <= (C_H_SYNC_PULSE + C_H_BACK_PORCH + C_H_OFFSET_1 + C_IMAGE_WIDTH  - 1'b1)  &&
                   R_v_cnt >= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_OFFSET_1                       )  && 
                   R_v_cnt <= (C_V_SYNC_PULSE + C_V_BACK_PORCH + C_V_OFFSET_1 + C_IMAGE_HEIGHT - 1'b1)  )
                    begin
                        O_red   <= W_santa_data[11:8];
                        O_green <= W_santa_data[7:4];
                        O_blue  <= W_santa_data[3:0];
                        if(R_santa_addr == C_IMAGE_PIX_NUM - 1'b1)
                            R_santa_addr <= 14'd0;
                        else
                            R_santa_addr <= R_santa_addr + 1'b1;
                    end
                else
                begin
                    O_red       <=  4'd0        ;
                    O_green     <=  4'd0        ;
                    O_blue      <=  4'd0        ;
                    R_rom_addr  <=  R_rom_addr  ;
                end                          
        end
    else
        begin
            O_red       <=  4'd0        ;
            O_green     <=  4'd0        ;
            O_blue      <=  4'd0        ;
            R_rom_addr  <=  R_rom_addr  ;
        end          
end
rom_santa U_rom_santa (
  .clka(R_clk_25M),    // input wire clka
  .addra(R_santa_addr),  // input wire [13 : 0] addra
  .douta(W_santa_data)  // output wire [15 : 0] douta
);


endmodule
