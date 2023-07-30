module rxController #(
    parameter states = 3,
              idle = 2'b00,
              starting = 2'b01,
              receiving = 2'b10
) (
    input notReady,                              // Signal from host
          serialIn_0,                            // Signal from datapath
          serialEq_3,                           // Signal from datapath
          serialLt_7,                           // Signal from datapath
          bitCountEq_8,                         // Signal from datapath
          sampleClk,
          rst_b,

    output reg received,
               clrSampleCounter,
               incSampleCounter,
               clrBitCounter,
               incBitCounter,
               shift,
               load,
               halt,
               error
);

    reg [states - 1 : 0] current, next;

    always @(current, notReady, serialIn_0, serialEq_3, serialLt_7) begin

        received = 0;
        clrSampleCounter = 0;
        incSampleCounter = 0;
        clrBitCounter = 0;
        incBitCounter = 0;
        shift = 0;
        load = 0;
        halt = 0;
        error = 0;
		  
		  next = idle;
			
        case (current)
            idle : begin
                if(serialIn_0 == 1'b0) next = idle;
                else next = starting;
            end
				
            starting : begin
                if(serialIn_0 == 1'b0)begin
                    next = idle;
                    clrSampleCounter = 1'b1;
                end
                else begin
                    if(serialEq_3 == 1'b1)begin
                        clrSampleCounter = 1'b1;
                        next = receiving;
                    end
                    else begin
                        incSampleCounter = 1'b1;
                        next = starting;
                    end
                end
            end
				
            receiving : begin
                if(serialLt_7 == 1'b1) begin 
						incSampleCounter = 1'b1;
						next = receiving;
					 end
                else begin
                    clrSampleCounter = 1'b1;
                    if(bitCountEq_8 == 1'b0)begin
                        shift = 1'b1;
                        incBitCounter = 1'b1;
                        next = receiving;
                    end
                    else begin
                        next = idle;
                        clrBitCounter = 1'b1;
                        received = 1'b1;

                        if(notReady == 1'b1) halt = 1'b1;               // Host not ready
                        else if(serialIn_0 == 1'b1) error = 1'b1;       // Invalid Stop Bit
                        else load = 1'b1;
                    end
                end
            end

            default: next = idle;
        endcase
    end

    always @(posedge sampleClk) begin
        if(rst_b == 1'b0)current = idle;
        else current = next;
    end
    
endmodule