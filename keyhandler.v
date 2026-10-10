module key_handler (
    input  wire       clk,
    input  wire       rst,       
    input  wire [7:0] data,      
    input  wire       ready,      
    input  wire       key_valid,  

    output reg        nextdata_n, // 低电平确认取走
    output reg  [7:0] scan_code,  // 保存当前按键扫描码
    output reg        display_valid,
    output reg  [7:0] count       
);
    

localparam WAIT_PRESS   = 2'd0,
           PRESSED      = 2'd1,
           WAIT_RELEASE = 2'd2,
           SKIP_RELEASE = 2'd3;

reg [1:0] state;
reg       ack_phase;
always@(posedge clk)begin
  if(!rst)begin
    nextdata_n<= 1'b1;
    state <= WAIT_PRESS;
    ack_phase <= 1'b0;
    scan_code <= 8'h00;
    count <= 8'd0;
    display_valid <=1'b0;
  end
  else if(ack_phase)begin
    nextdata_n <=1'b1;
    ack_phase <= 1'b0;
  end
  else if(ready)begin
    case(state)
        WAIT_PRESS:begin
          if(data == 8'hF0)begin
            state <= SKIP_RELEASE;
          end
          else if(key_valid)begin
            scan_code <= data;
            
            state<= PRESSED;
            count <= count + 1'b1;
            display_valid <= 1'b1;

          end
        end
        PRESSED:begin
            if(data == 8'hF0)begin   
                state <= WAIT_RELEASE;
        end 
        
        end  
        WAIT_RELEASE: begin
                
                    display_valid <= 1'b0;
                    state         <= WAIT_PRESS;
                
                    
                end
        SKIP_RELEASE:begin
          state<=WAIT_PRESS;
        end
        default:begin
          state<=WAIT_PRESS;
          display_valid <= 1'b0;
        end
    endcase
    nextdata_n <= 1'b0;
    ack_phase<=1'b1;
            
end
end
endmodule