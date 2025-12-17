`timescale 1ns/1ps

/*

 * Module: alu_32bit_modular

 *

 * Description:

 * 32-bit ALU built from 32 instances of alu_1bit using a generate-for loop.

 *

 * Key ideas:

 * - Each bit-slice gets Ai/Bi plus its neighbor bits for shift operations.

 * - Carry ripples from bit 0 → bit 31 for arithmetic operations.

 * - Cout is only meaningful for arithmetic (sel[3:2] == 2'b00); otherwise forced to 0.

 */



module alu_32bit_modular (

    input  [31:0] A,        // Operand A

    input  [31:0] B,        // Operand B

    input         Cin,      // Carry-in (bit 0)

    input         DinL,     // Serial-in bit for shift-left (feeds into bit 0 "next")

    input         DinR,     // Serial-in bit for shift-right (feeds into bit 31 "prev")

    input  [3:0]  sel,      // Operation select (passed into each slice)

    output [31:0] F,        // Result bus

    output        Cout      // Carry-out (arithmetic only)

);



    // Internal carry chain (carry_out of each slice)

    wire [31:0] c_chain;



    genvar k;

    generate

        for (k = 0; k < 32; k = k + 1) begin : GEN_ALU_SLICES



            // Neighbor bits used for shifting:

            // - A_prev corresponds to the bit above (k+1) or DinR at the MSB boundary

            // - A_next corresponds to the bit below (k-1) or DinL at the LSB boundary

            wire a_prev_bit;

            wire a_next_bit;



            assign a_prev_bit = (k == 31) ? DinR   : A[k + 1];

            assign a_next_bit = (k == 0)  ? DinL   : A[k - 1];



            // Carry into this slice:

            // - bit 0 uses Cin

            // - all others use previous slice carry

            wire c_in_bit;

            assign c_in_bit = (k == 0) ? Cin : c_chain[k - 1];



            // 1-bit ALU slice instance

            alu_1bit u_alu_1bit (

                .Ai    (A[k]),

                .Bi    (B[k]),

                .A_prev(a_prev_bit),

                .A_next(a_next_bit),

                .Cini  (c_in_bit),

                .sel   (sel),

                .Fi    (F[k]),

                .Couti (c_chain[k])

            );

        end

    endgenerate



    // Final carry-out comes from MSB slice

    // Only propagate it for arithmetic operations; otherwise output 0

    assign Cout = (sel[3:2] == 2'b00) ? c_chain[31] : 1'b0;



endmodule


