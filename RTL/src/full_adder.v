`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Module : full_adder
// Type   : Combinational
// Function:
//   1-bit full adder. Computes sum (Di) and carry-out (Couti) of three
//   1-bit inputs: Ai, Bi, and Cini.
//
//   Di    = Ai ^ Bi ^ Cini
//   Couti = (Ai & Bi) | (Ai & Cini) | (Bi & Cini)
// -----------------------------------------------------------------------------
module full_adder (
    input  Ai,     // Operand A bit
    input  Bi,     // Operand B bit
    input  Cini,   // Carry-in bit
    output Di,     // Sum bit
    output Couti   // Carry-out bit
);

    // Internal wires for intermediate results
    wire xor1;
    wire and1, and2, and3;

    // Sum calculation
    xor (xor1, Ai, Bi);
    xor (Di,   xor1, Cini);

    // Carry-out calculation
    and (and1, Ai, Bi);
    and (and2, Ai, Cini);
    and (and3, Bi, Cini);
    or  (Couti, and1, and2, and3);

endmodule

