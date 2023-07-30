module txDatapath #(
    parameter wordSize = 8,
               sizeBitCount = 3,
               loadOnes = {(wordSize + 1){1'b1}}
) (
    output serialOut,
           bitCounterMax,
    
    input [wordSize - 1 : 0] dataBus,
    input                    sigLoadDataReg,
                             loadShiftReg,
                             clear,
                             start,
                             shift,
                             clk,
                             rst_b
);
    
    reg [wordSize - 1 : 0]  dataReg;
    reg [wordSize : 0]      shiftReg;
    reg [sizeBitCount : 0]  bitCounter;

    assign serialOut = (shift) ? shiftReg[0] : 1'bz;
    assign bitCounterMax = (bitCounter < wordSize + 1) ? 1'b1 : 1'b0;

    always @(posedge clk, negedge rst_b) begin
        if(rst_b == 1'b0)begin
            shiftReg <= loadOnes;
            bitCounter <= 0;
        end
        else begin : transfer_operation
            if(sigLoadDataReg == 1'b1) dataReg <= dataBus;      // Load dataReg with dataBus

            if(loadShiftReg == 1'b1) shiftReg <= {dataReg,1'b1};

            if(start == 1'b1) shiftReg[0] <= 0;

            if(clear == 1'b1) bitCounter <=0;

            if(shift == 1'b1) begin
                shiftReg <= {1'b1,shiftReg[wordSize:1]};
                bitCounter <= bitCounter+1;
            end

        end

    end

endmodule
