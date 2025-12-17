`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Module : arithmetic_unit
// Type   : Combinational (plus full adder cell)
// Function:
//   Produces a 1-bit arithmetic result using a full adder and a 4:1 MUX to
//   control the second operand to the adder.
//
//   Inputs:
//     Ai   - 1-bit operand A
//     Bi   - 1-bit operand B
//     Cini - Carry-in
//     sel  - 2-bit control for choosing the modified B input:
//
//       sel = 2'b00 -> mux_out = 0       (pass Ai + Cini)
//       sel = 2'b01 -> mux_out = Bi      (Ai + Bi + Cini)
//       sel = 2'b10 -> mux_out = ~Bi     (used e.g. for subtraction with Cini)
//       sel = 2'b11 -> mux_out = 1       (increment Ai + Cini by 1)
//
//   Outputs:
//     Di    - Sum output from full adder
//     Couti - Carry-out from full adder
// -----------------------------------------------------------------------------
module arithmetic_unit (
    input       Ai,      // Operand A bit
    input       Bi,      // Operand B bit
    input       Cini,    // Carry-in bit
    input [1:0] sel,     // Select modified B input for the adder
    output      Di,      // Sum output
    output      Couti    // Carry-out
);

    // MUX output that feeds the full adder's B input
    wire       mux_out;

    // Candidates for the second operand (B-like values) to the full adder
    wire [3:0] mux_inputs;

    // 4:1 MUX input logic for the second operand:
    assign mux_inputs[0] = 1'b0;   // sel = 00 → use 0
    assign mux_inputs[1] = Bi;     // sel = 01 → use Bi (addition)
    not   (mux_inputs[2], Bi);     // sel = 10 → use ~Bi (subtraction form)
    assign mux_inputs[3] = 1'b1;   // sel = 11 → use 1 (increment / offset)

    // 4:1 MUX instance to select which B-variant is used
    mux4to1 MUX_B (
        .a  (mux_inputs[0]),
        .b  (mux_inputs[1]),
        .c  (mux_inputs[2]),
        .d  (mux_inputs[3]),
        .sel(sel),
        .out(mux_out)
    );

    // Full Adder instance: Ai + mux_out + Cini
    full_adder FA (
        .Ai   (Ai),
        .Bi   (mux_out),
        .Cini (Cini),
        .Di   (Di),
        .Couti(Couti)
    );

endmodule







