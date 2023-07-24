module txController #(
    parameter stateCount = 3,
              idle = 3'b001,
              waiting = 3'b010,
              sending = 3'b100

)(
    input byteReady,            // Signal from Control Unit, asserting loadShiftReg in idle state
    input transmitByte,         // Asserts start signal
    input clk,                  
    input bitCountMax,             // Signals status of bitCounter
    input rst_b,                // Resets all register and bitCounter
    input loadDataReg,          // Asserts sigLoadDataReg

    output reg clear,               // Clears bit counter
    output reg shift,               // Shifts Shift Register by 1-bit, also increaments bit counter by 1
    output reg start,              // Initiates Shifting of bits in Shift Register
    output reg loadShiftReg,       // Loads Data from Data Register into internal Shift Register
    output reg sigLoadDataReg      // Signal Data Register to Load Bus Data
);

reg [stateCount-1:0] currentState, nextState;

always @(currentState, loadDataReg, byteReady, transmitByte, bitCountMax) begin : control_logic

    sigLoadDataReg = 0;
    loadShiftReg = 0;
    start = 0;
    shift = 0;
    clear = 0;
    nextState = idle;

    case (currentState)
        idle :  
            if(loadDataReg) begin
                sigLoadDataReg = 1'b1;
                nextState = idle;
            end 
            else if(byteReady) begin
                loadShiftReg = 1'b1;
                nextState = waiting;
            end

        waiting: 
            if(transmitByte == 1'b1) begin
                start = 1;
                nextState = sending;
            end
            else nextState = waiting;

        sending: 
            if(bitCountMax == 1'b1)begin
                shift = 1;
                nextState = sending;
            end
            else begin
                clear = 1;
                nextState = idle;
            end

        default: nextState = idle; 
    endcase
end

always @(posedge clk, negedge rst_b) begin : state_transition
    if(rst_b == 1'b0) currentState <= idle;
    else currentState <= nextState;
end


endmodule
