`timescale 1ns/1ps



/*

 * Module: alu_32bit_behavioral

 *

 * Description:

 * 32-bit behavioral ALU supporting arithmetic, logic, and shift operations.

 * Operation is selected via 4-bit control signal S.

 *

 * S[3:2] : Operation group

 *   00 → Arithmetic

 *   01 → Logic

 *   10 → Shift Right

 *   11 → Shift Left

 *

 * S[1:0] : Sub-operation within arithmetic or logic groups

 */



module alu_32bit_behavioral (

    input  [31:0] A,        // Operand A

    input  [31:0] B,        // Operand B

    input         CIN,      // Carry-in (used for arithmetic)

    input         DL,       // Shift-in bit for left shift

    input         DR,       // Shift-in bit for right shift

    input  [3:0]  S,        // ALU control signal

    output reg [31:0] F,    // ALU result

    output reg        COUT  // Carry-out flag

);



    // Internal signals

    reg [31:0] mux_in;      // Selected second operand for arithmetic

    reg [32:0] temp_sum;   // Extended sum to capture carry-out



    // Combinational ALU logic

    always @(*) begin



        // Default values (avoid inferred latches)

        mux_in   = 32'h00000000;

        temp_sum = 33'd0;

        F        = 32'd0;

        COUT     = 1'b0;



        case (S[3:2])



            // -------------------------------------------------

            // Arithmetic Operations

            // -------------------------------------------------

            2'b00: begin

                // Select arithmetic operand based on S[1:0]

                case (S[1:0])

                    2'b00: mux_in = 32'h00000000; // A (+ CIN) → Transfer A

                    2'b01: mux_in = B;            // A + B (+ CIN)

                    2'b10: mux_in = ~B;           // A - B - 1 (+ CIN)

                    2'b11: mux_in = 32'hFFFFFFFF; // A - 1 (+ CIN)

                endcase



                // Perform addition with carry

                temp_sum = {1'b0, A} + {1'b0, mux_in} + CIN;



                // Assign outputs

                F    = temp_sum[31:0];

                COUT = temp_sum[32];

            end



            // -------------------------------------------------

            // Logic Operations

            // -------------------------------------------------

            2'b01: begin

                case (S[1:0])

                    2'b00: F = A & B;  // AND

                    2'b01: F = A | B;  // OR

                    2'b10: F = A ^ B;  // XOR

                    2'b11: F = ~A;     // NOT A

                endcase

                COUT = 1'b0;

            end



            // -------------------------------------------------

            // Shift Right (1-bit)

            // -------------------------------------------------

            2'b10: begin

                F    = {DR, A[31:1]};

                COUT = 1'b0;

            end



            // -------------------------------------------------

            // Shift Left (1-bit)

            // -------------------------------------------------

            2'b11: begin

                F    = {A[30:0], DL};

                COUT = 1'b0;

            end



        endcase

    end



endmodule


