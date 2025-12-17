`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Module : mux4to1
// Type   : Combinational
// Function:
//   4-to-1 single-bit multiplexer. Selects one of the four 1-bit inputs (a, b,
//   c, d) based on the 2-bit select signal 'sel'.
//
//   sel = 2'b00 -> out = a
//   sel = 2'b01 -> out = b
//   sel = 2'b10 -> out = c
//   sel = 2'b11 -> out = d
// -----------------------------------------------------------------------------
module mux4to1 (
    input       a,      // Input 0
    input       b,      // Input 1
    input       c,      // Input 2
    input       d,      // Input 3
    input [1:0] sel,    // 2-bit select signal
    output      out     // Selected output
);

    // Internal inverted select lines
    wire n0, n1;

    // Internal AND terms for each input path
    wire and0, and1, and2, and3;

    // Decode select bits
    not (n0, sel[0]);
    not (n1, sel[1]);

    // Each input is ANDed with the appropriate select line combination
    and (and0, a, n1,   n0     ); // sel = 00
    and (and1, b, n1,   sel[0] ); // sel = 01
    and (and2, c, sel[1], n0   ); // sel = 10
    and (and3, d, sel[1], sel[0]); // sel = 11

    // OR all paths together to produce final output
    or  (out, and0, and1, and2, and3);

endmodule

