`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Module : alu_1bit
// Type   : Combinational 1-bit ALU cell
// Function:
//   Combines arithmetic, logic, and shift operations into a single 1-bit ALU
//   cell. Intended to be used in a bit-sliced, multi-bit ALU.
//
//   Inputs:
//     Ai      - Bit i of operand A
//     Bi      - Bit i of operand B
//     A_prev  - Bit A[i-1], used for right shift operations
//     A_next  - Bit A[i+1], used for left shift operations
//     Cini    - Carry-in bit (to arithmetic unit)
//     sel[3:0]- Operation selector:
//         sel[3:2] = 2'b00 → arithmetic_unit result (Di)
//         sel[3:2] = 2'b01 → logic_unit result (Ei)
//         sel[3:2] = 2'b10 → shift right  (A_prev)
//         sel[3:2] = 2'b11 → shift left   (A_next)
//
//         sel[1:0] are passed down to arithmetic_unit and logic_unit to
//         choose which specific arithmetic/logical operation to perform.
//
//   Outputs:
//     Fi    - Final ALU result for this bit
//     Couti - Carry-out from the arithmetic unit
// -----------------------------------------------------------------------------
module alu_1bit (
    input       Ai,          // Operand A bit
    input       Bi,          // Operand B bit
    input       A_prev,      // A[i-1] for shift-right
    input       A_next,      // A[i+1] for shift-left
    input       Cini,        // Carry-in for this bit
    input [3:0] sel,         // 4-bit operation select
    output      Fi,          // Final ALU output bit
    output      Couti        // Carry-out from arithmetic unit
);

    // Intermediate results from arithmetic and logical sub-units
    wire Di;   // Arithmetic result
    wire Ei;   // Logic result

    // Shift outputs for this bit
    wire shift_right;
    wire shift_left;

    // Internal control for shift decode
    wire n_sel2;
    wire and_right, and_left;

    // Decode sel[2] to distinguish between right/left shifts when sel[3]=1
    not (n_sel2, sel[2]);

    // -------------------------------------------------------------------------
    // Shift logic:
    //   - shift_right is selected when sel[3:2] = 2'b10
    //   - shift_left  is selected when sel[3:2] = 2'b11
    // -------------------------------------------------------------------------

    // If sel = 10xx → shift_right = A_prev
    and (and_right, sel[3],  n_sel2);
    and (shift_right, and_right, A_prev);

    // If sel = 11xx → shift_left = A_next
    and (and_left,  sel[3],  sel[2]);
    and (shift_left, and_left, A_next);

    // -------------------------------------------------------------------------
    // Arithmetic unit (controls arithmetic behavior based on sel[1:0])
    // -------------------------------------------------------------------------
    arithmetic_unit U_ARITH (
        .Ai   (Ai),
        .Bi   (Bi),
        .Cini (Cini),
        .sel  (sel[1:0]),
        .Di   (Di),
        .Couti(Couti)
    );

    // -------------------------------------------------------------------------
    // Logic unit (controls logical behavior based on sel[1:0])
    // -------------------------------------------------------------------------
    logic_unit U_LOGIC (
        .Ai  (Ai),
        .Bi  (Bi),
        .sel (sel[1:0]),
        .Ei  (Ei)
    );

    // -------------------------------------------------------------------------
    // Final 4:1 MUX for ALU output Fi:
    //   sel[3:2] = 00 → Di  (arithmetic result)
    //   sel[3:2] = 01 → Ei  (logic result)
    //   sel[3:2] = 10 → shift_right (A_prev)
    //   sel[3:2] = 11 → shift_left  (A_next)
    // -------------------------------------------------------------------------
    mux4to1 U_MUX (
        .a  (Di),          // Arithmetic path
        .b  (Ei),          // Logic path
        .c  (shift_right), // Shift-right path
        .d  (shift_left),  // Shift-left path
        .sel(sel[3:2]),
        .out(Fi)
    );

endmodule

