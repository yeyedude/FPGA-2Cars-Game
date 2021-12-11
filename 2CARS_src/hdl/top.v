`timescale 1ns / 1ps

module top(
    input clk,
    input rstn,
    output VGA_HS,
    output VGA_VS,
    output [3:0]  VGA_R,
    output [3:0]  VGA_G,
    output [3:0]  VGA_B,
    // Top Car Control Switch
    input SW15,
    // Bottom Car Control Switch
    input SW0,
    // Restart Switch
    input SW6,
    output [7:0] LED,
    // Seven Segment Display Outputs
    output        CA        ,
    output        CB        ,
    output        CC        ,
    output        CD        ,
    output        CE        ,
    output        CF        ,
    output        CG        ,
    output [ 7:0] AN        ,
    output        DP        
    );

wire clk_25M;
wire enable_V_Counter;
wire [15:0] H_Count_Value;
wire [15:0] V_Count_Value;
//Seven Segment Display Signal
//Single digit 7 segment LED
wire   [6:0]  seg            ;
//Display number, input to seg7 to define segment pattern
wire   [31:0] disp_num;
// 16 bit BCD Converter Signals
// bcdout is sent to Scroll_Display Module
wire   [19:0] bcdout         ;

// Counters for speed regulation
reg [15:0] main_counter;
reg [15:0] ball_counter;
reg [15:0] divider_counter;
wire [4:0] data;

// Start Controls VGA
reg StartFlag = 0;

// 15
reg [15:0] OneLeft = 160;
reg [15:0] OneRight = 164;
reg [15:0] OneTop = 160;
reg [15:0] OneBot = 240;

reg [15:0] Five1Left = 170;
reg [15:0] Five1Right = 200;
reg [15:0] Five1Top = 160;
reg [15:0] Five1Bot = 164;

reg [15:0] Five2Left = 170;
reg [15:0] Five2Right = 174;
reg [15:0] Five2Top = 160;
reg [15:0] Five2Bot = 200;

reg [15:0] Five3Left = 170;
reg [15:0] Five3Right = 200;
reg [15:0] Five3Top = 195;
reg [15:0] Five3Bot = 199;

reg [15:0] Five4Left = 196;
reg [15:0] Five4Right = 200;
reg [15:0] Five4Top = 195;
reg [15:0] Five4Bot = 240;

reg [15:0] Five5Left = 170;
reg [15:0] Five5Right = 200;
reg [15:0] Five5Top = 236;
reg [15:0] Five5Bot = 240;
// 0
reg [15:0] Zero1Left = 160;
reg [15:0] Zero1Right = 190;
reg [15:0] Zero1Top = 400;
reg [15:0] Zero1Bot = 404;

reg [15:0] Zero2Left = 160;
reg [15:0] Zero2Right = 164;
reg [15:0] Zero2Top = 400;
reg [15:0] Zero2Bot = 480;

reg [15:0] Zero3Left = 186;
reg [15:0] Zero3Right = 190;
reg [15:0] Zero3Top = 400;
reg [15:0] Zero3Bot = 480;

reg [15:0] Zero4Left = 160;
reg [15:0] Zero4Right = 190;
reg [15:0] Zero4Top = 476;
reg [15:0] Zero4Bot = 480;
// 6
reg [15:0] Six1Left = 460;
reg [15:0] Six1Right = 490;
reg [15:0] Six1Top = 60;
reg [15:0] Six1Bot = 64;

reg [15:0] Six2Left = 460;
reg [15:0] Six2Right = 464;
reg [15:0] Six2Top = 60;
reg [15:0] Six2Bot = 140;

reg [15:0] Six3Left = 460;
reg [15:0] Six3Right = 490;
reg [15:0] Six3Top = 90;
reg [15:0] Six3Bot = 94;

reg [15:0] Six4Left = 486;
reg [15:0] Six4Right = 490;
reg [15:0] Six4Top = 90;
reg [15:0] Six4Bot = 140;

reg [15:0] Six5Left = 460;
reg [15:0] Six5Right = 490;
reg [15:0] Six5Top = 136;
reg [15:0] Six5Bot = 140;

//  Play
reg [15:0] Play1Left = 445;
reg [15:0] Play1Right = 460;
reg [15:0] Play1Top = 180;
reg [15:0] Play1Bot = 230;

reg [15:0] Play2Left = 450;
reg [15:0] Play2Right = 470;
reg [15:0] Play2Top = 185;
reg [15:0] Play2Bot = 225;

reg [15:0] Play3Left = 450;
reg [15:0] Play3Right = 480;
reg [15:0] Play3Top = 190;
reg [15:0] Play3Bot = 220;

reg [15:0] Play4Left = 450;
reg [15:0] Play4Right = 490;
reg [15:0] Play4Top = 195;
reg [15:0] Play4Bot = 215;

reg [15:0] Play5Left = 450;
reg [15:0] Play5Right = 500;
reg [15:0] Play5Top = 200;
reg [15:0] Play5Bot = 210;


// Dividers
reg [15:0] xTopDividerLeft = 50 ;
reg [15:0] xTopDividerRight = 800 ;
reg [15:0] yTopDividerTop = 40 ;
reg [15:0] yTopDividerBot = 50 ;

reg [15:0] xMidDividerLeft = 50 ;
reg [15:0] xMidDividerRight = 800 ;
reg [15:0] yMidDividerTop = 260 ;
reg [15:0] yMidDividerBot = 280 ;

reg [15:0] xBotDividerLeft = 50 ;
reg [15:0] xBotDividerRight = 800 ;
reg [15:0] yBotDividerTop = 490 ;
reg [15:0] yBotDividerBot = 500 ;

// Cars: 100w x 80h
reg [15:0] x1LimitLeft = 260;
reg [15:0] x1LimitRight = 360;
reg [15:0] y1LimitTop = 160;
reg [15:0] y1LimitBot = 240;

reg [15:0] x2LimitLeft = 260;
reg [15:0] x2LimitRight = 360;
reg [15:0] y2LimitTop = 300;
reg [15:0] y2LimitBot = 380;

// Obstacle Metrics
reg [15:0] ball_speed = 1;
reg [15:0] ball_space = 400;
reg ball_col = 0;
reg [15:0] ball_total = 0;

reg [15:0] lane1HeightTop = 60;
reg [15:0] lane2HeightTop = 175;
reg [15:0] lane3HeightTop = 300;
reg [15:0] lane4HeightTop = 415;

// Obstacles
reg [15:0] x1BallLeft = 800;
reg [15:0] x1BallRight = 840;
reg [15:0] y1BallTop = 60;
reg [15:0] y1BallBot = 125;

reg [15:0] x2BallLeft = 1200;
reg [15:0] x2BallRight = 1240;
reg [15:0] y2BallTop = 175;
reg [15:0] y2BallBot = 240;

reg [15:0] x3BallLeft = 1600;
reg [15:0] x3BallRight = 1640;
reg [15:0] y3BallTop = 60;
reg [15:0] y3BallBot = 125;

reg [15:0] x4BallLeft = 2000;
reg [15:0] x4BallRight = 2040;
reg [15:0] y4BallTop = 175;
reg [15:0] y4BallBot = 240;

reg [15:0] x5BallLeft = 1000;
reg [15:0] x5BallRight = 1040;
reg [15:0] y5BallTop = 415;
reg [15:0] y5BallBot = 480;

reg [15:0] x6BallLeft = 1400;
reg [15:0] x6BallRight = 1440;
reg [15:0] y6BallTop = 300;
reg [15:0] y6BallBot = 365;

reg [15:0] x7BallLeft = 1800;
reg [15:0] x7BallRight = 1840;
reg [15:0] y7BallTop = 415;
reg [15:0] y7BallBot = 480;

reg [15:0] x8BallLeft = 2200;
reg [15:0] x8BallRight = 2240;
reg [15:0] y8BallTop =  300;
reg [15:0] y8BallBot = 365;

clock_divider VGA_Clock_gen (clk, clk_25M);
horizontal_counter VGA_Horiz (clk_25M, enable_V_Counter, H_Count_Value);
vertical_counter VGA_Verti (clk_25M, enable_V_Counter, V_Count_Value);

seg7decimal u_seg7decimal (
  .x           (disp_num       ),
  .clk         (clk            ),
  .a_to_g      (seg            ),
  .an          (AN             ),
  .dp          (DP             )
);

bin_to_decimal u_bin_to_decimal (
  .B           ({ball_total}),             
  .bcdout      (bcdout             )    
);

fib_lfsr fib_lfsr ( clk, rstn, data);

always@(posedge clk_25M) begin
    main_counter = main_counter + 1;
    if (main_counter == 16'hFFFF) begin
        main_counter = 16'h0000;
        if (ball_col == 0)begin
            if (SW15 == 1)begin     
                y1LimitTop = 60;
                y1LimitBot = 140;  
            end
            else if (SW15 == 0)begin      
                y1LimitTop = 160;
                y1LimitBot = 240;      
            end
            if (SW0 == 1)begin   
                y2LimitTop = 300;
                y2LimitBot = 380;    
            end
            else if (SW0 == 0)begin   
                y2LimitTop = 400;
                y2LimitBot = 480;    
            end
        end
    end
end



always@(posedge clk_25M) begin
    ball_counter = ball_counter + 1;
    if (ball_counter == 16'hFFFF) begin
        ball_counter = 16'h0000;
        case (ball_total)
            24:begin
                ball_space = 350;
               end            
            40:begin
                ball_space = 350;
                ball_speed = 2;
               end 
            64:begin
                ball_space = 350;
                ball_speed = 3;
               end 
            104:begin
                ball_space = 300;
                ball_speed = 3;
               end 
            120:begin
                ball_space = 250;
                ball_speed = 3;
               end 
        endcase
        if (ball_col == 1) begin
        end
        else if (SW6 == 1)begin
            StartFlag = 0;
            // Lane 1 Obstacle Movement
            x1BallLeft = x1BallLeft - ball_speed;
            x1BallRight = x1BallRight - ball_speed;
            // Lane 2 Obstacle Movement
            x2BallLeft = x2BallLeft - ball_speed;
            x2BallRight = x2BallRight - ball_speed;
            // Lane 3 Obstacle Movement
            x3BallLeft = x3BallLeft - ball_speed;
            x3BallRight = x3BallRight - ball_speed;
            // Lane 4 Obstacle Movement
            x4BallLeft = x4BallLeft - ball_speed;
            x4BallRight = x4BallRight - ball_speed;
            // Lane 5 Obstacle Movement
            x5BallLeft = x5BallLeft - ball_speed;
            x5BallRight = x5BallRight - ball_speed;
            // Lane 6 Obstacle Movement
            x6BallLeft = x6BallLeft - ball_speed;
            x6BallRight = x6BallRight - ball_speed;
            // Lane 7 Obstacle Movement
            x7BallLeft = x7BallLeft - ball_speed;
            x7BallRight = x7BallRight - ball_speed;
            // Lane 8 Obstacle Movement
            x8BallLeft = x8BallLeft - ball_speed;
            x8BallRight = x8BallRight - ball_speed;
            
            // Lane 1/2 obstacle 1 Conditions
            if ((x1BallLeft <= x1LimitRight) && (x1BallRight >= x1LimitLeft) && ((y1BallTop == y1LimitTop) || (y1BallBot == y1LimitBot)))begin
                ball_col = 1;
            end
            else if (x1BallRight == 0)begin
                x1BallLeft = x4BallRight + ball_space;
                x1BallRight = x1BallLeft + 40;
                ball_total = ball_total + 1;
                y1BallTop = (data[0])?lane1HeightTop:lane2HeightTop;//lane2HeightTop:lane1HeightTop;
                y1BallBot = y1BallTop + 65;
            end
            // Lane 1/2 obstacle 2 Conditions
            if ((x2BallLeft <= x1LimitRight) && (x2BallRight >= x1LimitLeft) && ((y2BallTop == y1LimitTop) || (y2BallBot == y1LimitBot)))begin
                ball_col = 1;
            end
            else if (x2BallRight == 0)begin
                x2BallLeft = x1BallRight + ball_space;
                x2BallRight = x2BallLeft + 40;
                ball_total = ball_total + 1;
                y2BallTop = (data[1])?lane1HeightTop:lane2HeightTop;
                y2BallBot = y2BallTop + 65;
            end
            // Lane 1/2 obstacle 3 Conditions
            if ((x3BallLeft <= x2LimitRight) && (x3BallRight >= x2LimitLeft) && ((y3BallTop == y1LimitTop) || (y3BallBot == y1LimitBot)))begin
                ball_col = 1;
            end
            else if (x3BallRight == 0)begin
                x3BallLeft = x2BallRight + ball_space;
                x3BallRight = x3BallLeft + 40;
                ball_total = ball_total + 1;
                y3BallTop = (data[2])?lane1HeightTop:lane2HeightTop;//lane2HeightTop:lane1HeightTop;
                y3BallBot = y3BallTop + 65;
            end
            // Lane 1/2 obstacle 4 Conditions
            if ((x4BallLeft <= x1LimitRight) && (x4BallRight >= x1LimitLeft) && ((y4BallTop == y1LimitTop) || (y4BallBot == y1LimitBot)))begin
                ball_col = 1;
            end
            else if (x4BallRight == 0)begin
                x4BallLeft = x3BallRight + ball_space;
                x4BallRight = x4BallLeft + 40;
                ball_total = ball_total + 1;
                y4BallTop = (data[3])?lane1HeightTop:lane2HeightTop;
                y4BallBot = y4BallTop + 65;
            end
            
            // Lane 3/4 obstacle 5 Conditions
            if ((x5BallLeft <= x2LimitRight) && (x5BallRight >= x2LimitLeft) && ((y5BallTop == y2LimitTop) || (y5BallBot == y2LimitBot)))begin
                ball_col = 1;
            end
            else if (x5BallRight == 0)begin
                x5BallLeft = x8BallRight + ball_space;
                x5BallRight = x5BallLeft + 40;
                ball_total = ball_total + 1;
                y5BallTop = (data[4])?lane3HeightTop:lane4HeightTop;
                y5BallBot = y5BallTop + 65;
            end
            // Lane 3/4 obstacle 6 Conditions
            if ((x6BallLeft <= x2LimitRight) && (x6BallRight >= x2LimitLeft) && ((y6BallTop == y2LimitTop) || (y6BallBot == y2LimitBot)))begin
                ball_col = 1;
            end
            else if (x6BallRight == 0)begin
                x6BallLeft = x5BallRight + ball_space;
                x6BallRight = x6BallLeft + 40;
                ball_total = ball_total + 1;
                y6BallTop = (data[0])?lane3HeightTop:lane4HeightTop;//lane4HeightTop:lane3HeightTop;
                y6BallBot = y6BallTop + 65;
            end
            // Lane 3/4 obstacle 7 Conditions
            if ((x7BallLeft <= x2LimitRight) && (x7BallRight >= x2LimitLeft) && ((y7BallTop == y2LimitTop) || (y7BallBot == y2LimitBot)))begin
                ball_col = 1;
            end
            else if (x7BallRight == 0)begin
                x7BallLeft = x6BallRight + ball_space;
                x7BallRight = x7BallLeft + 40;
                ball_total = ball_total + 1;
                y7BallTop = (data[1])?lane3HeightTop:lane4HeightTop;
                y7BallBot = y7BallTop + 65;
            end
            // Lane 3/4 obstacle 8 Conditions
            if ((x8BallLeft <= x2LimitRight) && (x8BallRight >= x2LimitLeft) && ((y8BallTop == y2LimitTop) || (y8BallBot == y2LimitBot)))begin
                ball_col = 1;
            end
            else if (x8BallRight == 0)begin
                x8BallLeft = x7BallRight + ball_space;
                x8BallRight = x8BallLeft + 40;
                ball_total = ball_total + 1;
                y8BallTop = (data[2])?lane3HeightTop:lane4HeightTop;//lane4HeightTop:lane3HeightTop;
                y8BallBot = y8BallTop + 65;
            end
        end
        if (SW6 == 0)begin
            // Reset Conditions
            StartFlag = 1;
            ball_col = 0;
            ball_speed = 1;
            ball_total = 0;
            // Obstacles
            x1BallLeft = 800;
            x1BallRight = x1BallLeft + 40;
            y1BallTop = lane1HeightTop;
            y1BallBot = y1BallTop + 65;
            
            x2BallLeft = 1200;
            x2BallRight = x2BallLeft + 40;
            y2BallTop = lane2HeightTop;
            y2BallBot = y2BallTop + 65;
            
            x3BallLeft = 1600;
            x3BallRight = x3BallLeft + 40;
            y3BallTop = lane1HeightTop;
            y3BallBot = y3BallTop + 65;
            
            x4BallLeft = 2000;
            x4BallRight = x4BallLeft + 40;
            y4BallTop = lane2HeightTop;
            y4BallBot = y4BallTop + 65;
            
            x5BallLeft = 1000;
            x5BallRight = x5BallLeft + 40;
            y5BallTop = lane3HeightTop;
            y5BallBot = y5BallTop + 65;
            
            x6BallLeft = 1400;
            x6BallRight = x6BallLeft + 40;
            y6BallTop = lane4HeightTop;
            y6BallBot = y6BallTop + 65;
            
            x7BallLeft = 1800;
            x7BallRight = x7BallLeft + 40;
            y7BallTop = lane3HeightTop;
            y7BallBot = y7BallTop + 65;
            
            x8BallLeft = 2200;
            x8BallRight = x8BallLeft + 40;
            y8BallTop = lane4HeightTop;
            y8BallBot = y8BallTop + 65;
            
        end
    end
end

// Outputs
assign disp_num = {bcdout};
assign CA = seg[0];
assign CB = seg[1];
assign CC = seg[2];
assign CD = seg[3];
assign CE = seg[4];
assign CF = seg[5];
assign CG = seg[6];
// VGA Output
assign VGA_HS = (H_Count_Value < 96)?1'b0:1'b1;
assign VGA_VS = (V_Count_Value < 2)?1'b0:1'b1;
assign VGA_R = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 35 ) ? 4'hA:4'h0;
assign VGA_G = ( 
              // Car VGA   
                 (H_Count_Value<(x1LimitRight)&&H_Count_Value>(x1LimitLeft)&&V_Count_Value<(y1LimitBot)&&V_Count_Value>(y1LimitTop))
              || (H_Count_Value<(x2LimitRight)&&H_Count_Value>(x2LimitLeft)&&V_Count_Value<(y2LimitBot)&&V_Count_Value>(y2LimitTop))
              // Divider VGA
              || (H_Count_Value<(xMidDividerRight)&&H_Count_Value>(xMidDividerLeft)&&V_Count_Value<(yMidDividerBot)&&V_Count_Value>(yMidDividerTop))
              || (H_Count_Value<(xTopDividerRight)&&H_Count_Value>(xTopDividerLeft)&&V_Count_Value<(yTopDividerBot)&&V_Count_Value>(yTopDividerTop))
              || (H_Count_Value<(xBotDividerRight)&&H_Count_Value>(xBotDividerLeft)&&V_Count_Value<(yBotDividerBot)&&V_Count_Value>(yBotDividerTop))
              // Obstacle VGA
              || (H_Count_Value<(x1BallRight)&&H_Count_Value>(x1BallLeft)&&V_Count_Value<(y1BallBot)&&V_Count_Value>(y1BallTop))
              || (H_Count_Value<(x2BallRight)&&H_Count_Value>(x2BallLeft)&&V_Count_Value<(y2BallBot)&&V_Count_Value>(y2BallTop))
              || (H_Count_Value<(x3BallRight)&&H_Count_Value>(x3BallLeft)&&V_Count_Value<(y3BallBot)&&V_Count_Value>(y3BallTop))
              || (H_Count_Value<(x4BallRight)&&H_Count_Value>(x4BallLeft)&&V_Count_Value<(y4BallBot)&&V_Count_Value>(y4BallTop))
              || (H_Count_Value<(x5BallRight)&&H_Count_Value>(x5BallLeft)&&V_Count_Value<(y5BallBot)&&V_Count_Value>(y5BallTop))
              || (H_Count_Value<(x6BallRight)&&H_Count_Value>(x6BallLeft)&&V_Count_Value<(y6BallBot)&&V_Count_Value>(y6BallTop))
              || (H_Count_Value<(x7BallRight)&&H_Count_Value>(x7BallLeft)&&V_Count_Value<(y7BallBot)&&V_Count_Value>(y7BallTop))
              || (H_Count_Value<(x8BallRight)&&H_Count_Value>(x8BallLeft)&&V_Count_Value<(y8BallBot)&&V_Count_Value>(y8BallTop))
              // Start Page
              || (StartFlag&&(H_Count_Value<(Play1Right)&&H_Count_Value>(Play1Left)&&V_Count_Value<(Play1Bot)&&V_Count_Value>(Play1Top)))
              || (StartFlag&&(H_Count_Value<(Play2Right)&&H_Count_Value>(Play2Left)&&V_Count_Value<(Play2Bot)&&V_Count_Value>(Play2Top)))
              || (StartFlag&&(H_Count_Value<(Play3Right)&&H_Count_Value>(Play3Left)&&V_Count_Value<(Play3Bot)&&V_Count_Value>(Play3Top)))
              || (StartFlag&&(H_Count_Value<(Play4Right)&&H_Count_Value>(Play4Left)&&V_Count_Value<(Play4Bot)&&V_Count_Value>(Play4Top)))
              || (StartFlag&&(H_Count_Value<(Play5Right)&&H_Count_Value>(Play5Left)&&V_Count_Value<(Play5Bot)&&V_Count_Value>(Play5Top)))
              
              || (StartFlag&&(H_Count_Value<(OneRight)&&H_Count_Value>(OneLeft)&&V_Count_Value<(OneBot)&&V_Count_Value>(OneTop)))
              
              || (StartFlag&&(H_Count_Value<(Five1Right)&&H_Count_Value>(Five1Left)&&V_Count_Value<(Five1Bot)&&V_Count_Value>(Five1Top)))
              || (StartFlag&&(H_Count_Value<(Five2Right)&&H_Count_Value>(Five2Left)&&V_Count_Value<(Five2Bot)&&V_Count_Value>(Five2Top)))
              || (StartFlag&&(H_Count_Value<(Five3Right)&&H_Count_Value>(Five3Left)&&V_Count_Value<(Five3Bot)&&V_Count_Value>(Five3Top)))
              || (StartFlag&&(H_Count_Value<(Five4Right)&&H_Count_Value>(Five4Left)&&V_Count_Value<(Five4Bot)&&V_Count_Value>(Five4Top)))
              || (StartFlag&&(H_Count_Value<(Five5Right)&&H_Count_Value>(Five5Left)&&V_Count_Value<(Five5Bot)&&V_Count_Value>(Five5Top)))
              
              || (StartFlag&&(H_Count_Value<(Zero1Right)&&H_Count_Value>(Zero1Left)&&V_Count_Value<(Zero1Bot)&&V_Count_Value>(Zero1Top)))
              || (StartFlag&&(H_Count_Value<(Zero2Right)&&H_Count_Value>(Zero2Left)&&V_Count_Value<(Zero2Bot)&&V_Count_Value>(Zero2Top)))
              || (StartFlag&&(H_Count_Value<(Zero3Right)&&H_Count_Value>(Zero3Left)&&V_Count_Value<(Zero3Bot)&&V_Count_Value>(Zero3Top)))
              || (StartFlag&&(H_Count_Value<(Zero4Right)&&H_Count_Value>(Zero4Left)&&V_Count_Value<(Zero4Bot)&&V_Count_Value>(Zero4Top)))
              
              || (StartFlag&&(H_Count_Value<(Six1Right)&&H_Count_Value>(Six1Left)&&V_Count_Value<(Six1Bot)&&V_Count_Value>(Six1Top)))
              || (StartFlag&&(H_Count_Value<(Six2Right)&&H_Count_Value>(Six2Left)&&V_Count_Value<(Six2Bot)&&V_Count_Value>(Six2Top)))
              || (StartFlag&&(H_Count_Value<(Six3Right)&&H_Count_Value>(Six3Left)&&V_Count_Value<(Six3Bot)&&V_Count_Value>(Six3Top)))
              || (StartFlag&&(H_Count_Value<(Six4Right)&&H_Count_Value>(Six4Left)&&V_Count_Value<(Six4Bot)&&V_Count_Value>(Six4Top)))
              || (StartFlag&&(H_Count_Value<(Six5Right)&&H_Count_Value>(Six5Left)&&V_Count_Value<(Six5Bot)&&V_Count_Value>(Six5Top)))
              ) ? 4'hF:4'h0;
assign VGA_B = (H_Count_Value < 784 && H_Count_Value > 143 && V_Count_Value < 515 && V_Count_Value > 35 ) ? 4'h0:4'h0;


endmodule
