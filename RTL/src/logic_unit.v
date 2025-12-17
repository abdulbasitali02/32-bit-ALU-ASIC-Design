`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Module : logic_unit
// Type   : Combinational
// Function:
//   Implements basic bitwise logical operations between Ai and Bi.
//   The desired operation is selected using the 2-bit 'sel' signal.
//
//   sel = 2'b00 -> AND  (Ai & Bi)
//   sel = 2'b01 -> OR   (Ai | Bi)
//   sel = 2'b02 -> XOR  (Ai ^ Bi)
//   sel = 2'b11 -> NOT  (~Ai)
//
//   The four candidate results are fed into a 4:1 MUX.
// -----------------------------------------------------------------------------
module logic_unit (
    input       Ai,       // Operand A (1 bit)
    input       Bi,       // Operand B (1 bit)
    input [1:0] sel,      // Select which logic operation
    output      Ei        // Logic result
);

    // Candidate logic outputs that will be fed into the MUX:
    // mux_inputs[0] -> AND
    // mux_inputs[1] -> OR
    // mux_inputs[2] -> XOR
    // mux_inputs[3] -> NOT (of Ai)
    wire [3:0] mux_inputs;

    // Generate all possible logic results
    and (mux_inputs[0], Ai, Bi); // AND
    or  (mux_inputs[1], Ai, Bi); // OR
    xor (mux_inputs[2], Ai, Bi); // XOR
    not (mux_inputs[3], Ai);     // NOT of Ai

    // Use the 4:1 MUX to choose the final logic output based on 'sel'
    mux4to1 MUX_LOGIC (
        .a  (mux_inputs[0]), // AND
        .b  (mux_inputs[1]), // OR
        .c  (mux_inputs[2]), // XOR
        .d  (mux_inputs[3]), // NOT
        .sel(sel),
        .out(Ei)
    );

endmodule

