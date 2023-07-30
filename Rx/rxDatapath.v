module rxDatapath #(
    parameter wordSize = 4'b1000,
              halfWord = wordSize/2,
              counterBits = 4
) (
    output reg [wordSize-1:0] rxDatareg,
    output serialIn_0,
           serialEq_3,
           serialLt_7,
           bitCountEq_8,
    
    input serialIn,
          clrSampleCounter,
          incSampleCounter,
          incBitCounter,
          clrBitCounter,
          shift,
          load,
          sampleClk,
          rst_b
);

reg [wordSize - 1 : 0] rxShiftReg;
reg [counterBits - 1 : 0] sampleCounter;
reg [counterBits : 0] bitCounter;


assign serialIn_0 = (serialIn == 1'b0);
assign serialEq_3 = (sampleCounter == halfWord - 1);
assign serialLt_7 = (sampleCounter < wordSize - 1);
assign bitCountEq_8 = (bitCounter == wordSize);

always @(posedge sampleClk) begin
    if(rst_b == 1'b0)begin
        // reset all register
        sampleCounter <= 0;
        bitCounter <= 0;
        rxDatareg <= 0;
        rxShiftReg <= 0;
    end
    else begin
        if(clrSampleCounter == 1'b1) sampleCounter <= 1'b0;
        else if(incSampleCounter) sampleCounter <= sampleCounter + 1'b1;

        if(clrBitCounter == 1'b1) bitCounter <= 1'b0;
        else if(incBitCounter == 1'b1) bitCounter <= bitCounter + 1'b1;

        if(shift == 1'b1) rxShiftReg <= {serialIn, rxShiftReg[wordSize-1:1]};
        if(load == 1'b1) rxDatareg <= rxShiftReg;
    end
end
    
endmodule