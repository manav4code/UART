module UART_rx #(
    parameter wordSize = 8,
              halfWord = wordSize/2
) (
    output [wordSize - 1 : 0] rxDatareg,
    output                received,
                          halt,
                          error,

    input                 serialIn,
                          notReady,
                          sampleClk,
                          rst_b
);


// Wires: In:Controller -> Datapath
wire      clrSampleCounter,
          incSampleCounter,
          incBitCounter,
          clrBitCounter,
          shift,
          load;

// Wires: In:Datapath -> Controller
wire      serialIn_0,                            // Signal from datapath
          serialEq_3,                           // Signal from datapath
          serialLt_7,                           // Signal from datapath
          bitCountEq_8;
    

rxController rxControlUnit (
    // Output
    // to Datapath
    .clrBitCounter(clrBitCounter),           // Clear Bit Counter
    .clrSampleCounter(clrSampleCounter),     // Clear Sample Counter
    .incSampleCounter(incSampleCounter),     // Increment Sample Counter
    .incBitCounter(incBitCounter),           // Increment Bit Counter
    .shift(shift),
    .load(load),
    // to Host
    .halt(halt),
    .error(error),
    .received(received),
    
    // Input
    // From Host
    .sampleClk(sampleClk),
    .rst_b(rst_b),
    .notReady(notReady),
    // From Datapath
    .bitCountEq_8(bitCountEq_8),             // Compare with the number
    .serialIn_0(serialIn_0),
    .serialEq_3(serialEq_3),
    .serialLt_7(serialLt_7)
);

rxDatapath rxDatapathUnit(
    // Input
    // From Tx
    .serialIn(serialIn),
    // From Host
    .sampleClk(sampleClk),
    .rst_b(rst_b),
    // From Controller
    .clrSampleCounter(clrSampleCounter),
    .incSampleCounter(incSampleCounter),
    .clrBitCounter(clrBitCounter),
    .incBitCounter(incBitCounter),
    .shift(shift),
    .load(load),
    

    // Outputs to Controller
    .serialIn_0(serialIn_0),
    .serialEq_3(serialEq_3),
    .serialLt_7(serialLt_7),
    .bitCountEq_8(bitCountEq_8),

    // Output to host
    .rxDatareg(rxDatareg)
);

endmodule
