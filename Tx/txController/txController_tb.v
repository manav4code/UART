
`timescale 1ns / 1ps
module txController_tb;
    // File Variable
    integer fd;

    // Parameters
    parameter stateCount = 3;
    parameter idle = 3'b001;
    parameter waiting = 3'b010;
    parameter sending = 3'b100;

    // Inputs
    reg byteReady = 0;
    reg transmitByte = 0;
    reg clk = 0;
    reg bitCountMax = 0;
    reg rst_b = 1;
    reg loadDataReg = 0;

    // Outputs
    wire clear;
    wire shift;
    wire start;
    wire loadShiftReg;
    wire sigLoadDataReg;

    // Instantiate DUT (Design Under Test)
    txController #(
        .stateCount(stateCount),
        .idle(idle),
        .waiting(waiting),
        .sending(sending)
    ) dut (
        .byteReady(byteReady),
        .transmitByte(transmitByte),
        .clk(clk),
        .bitCountMax(bitCountMax),
        .rst_b(rst_b),
        .loadDataReg(loadDataReg),
        .clear(clear),
        .shift(shift),
        .start(start),
        .loadShiftReg(loadShiftReg),
        .sigLoadDataReg(sigLoadDataReg)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
	fd = $fopen("testbenchLog.txt", "w");
        rst_b = 0;
        #15;
        rst_b = 1;
    end

    // Stimulus
    initial begin
        // Test Case 1: Wait for byteReady, then start sending data
        loadDataReg = 0;
        byteReady = 1;
        #20;
        byteReady = 0;
        #10;
        loadDataReg = 1;
        #10;
        loadDataReg = 0;
        #10;
        loadDataReg = 1;
        #20;
        transmitByte = 1;
        #10;
        transmitByte = 0;
        #40;

        // Test Case 2: Transmit single byte immediately
        loadDataReg = 1;
        #20;
        transmitByte = 1;
        #10;
        transmitByte = 0;
        #40;

        // Test Case 3: Transmit multiple bytes
        loadDataReg = 1;
        #20;
        transmitByte = 1;
        #10;
        transmitByte = 0;
        #10;
        transmitByte = 1;
        #10;
        transmitByte = 0;
        #10;
        transmitByte = 1;
        #10;
        transmitByte = 0;
        #40;

        // Test Case 4: Do not load data and wait for byteReady
        loadDataReg = 0;
        #20;
        byteReady = 1;
        #20;
        byteReady = 0;
        #40;
	
	$fclose(fd);

        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        $fdisplay(fd, "Input: Time=%t, currentState=%b, byteReady=%b, transmitByte=%b, bitCountMax=%b, loadDataReg=%b \nOutput: Time=%t, currentState=%b, clear=%b, shift=%b, start=%b, loadShiftReg=%b, sigLoadDataReg=%b \n",
                 $time, dut.currentState, byteReady, transmitByte, bitCountMax, loadDataReg, $time, dut.currentState, clear, shift, start, loadShiftReg, sigLoadDataReg);
    end

endmodule
