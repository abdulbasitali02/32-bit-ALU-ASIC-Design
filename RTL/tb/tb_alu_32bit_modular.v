`timescale 1ns/1ps

/*

 * Testbench: tb_alu_32bit_modular

 *

 * Self-checking TB for alu_32bit_modular.

 * - Runs directed tests (arith / logic / shifts)

 * - Runs a randomized sweep

 * - Computes expected outputs using a golden model that matches the DUT spec:

 *    * Arithmetic: A + mux_in + Cin   where mux_in depends on sel[1:0]

 *    * Logic: AND/OR/XOR/NOT

 *    * Shifts: single-bit shift with DinL/DinR injected

 *    * Cout only valid for arithmetic; forced 0 otherwise

 */



module tb_alu_32bit_modular;



    // -----------------------------

    // Inputs to DUT

    // -----------------------------

    reg  [31:0] A, B;

    reg         Cin, DinL, DinR;

    reg  [3:0]  sel;



    // -----------------------------

    // Outputs from DUT

    // -----------------------------

    wire [31:0] F;

    wire        Cout;



    // -----------------------------

    // Expected (golden) results

    // -----------------------------

    reg  [31:0] expected_F;

    reg         expected_Cout;



    integer n;



    // -----------------------------

    // Instantiate DUT

    // -----------------------------

    alu_32bit_modular dut (

        .A    (A),

        .B    (B),

        .Cin  (Cin),

        .DinL (DinL),

        .DinR (DinR),

        .sel  (sel),

        .F    (F),

        .Cout (Cout)

    );



    // =============================

    // Main stimulus

    // =============================

    initial begin

        $display("\n============================================================");

        $display("   Functional Verification: 32-bit Modular ALU (self-check)");

        $display("============================================================\n");



        // Clean init

        A    = 32'd0;

        B    = 32'd0;

        Cin  = 1'b0;

        DinL = 1'b0;

        DinR = 1'b0;

        sel  = 4'h0;



        // -----------------------------

        // Directed Arithmetic Tests

        // -----------------------------

        $display("---- Arithmetic tests ----");

        apply_and_check(32'h00000000, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'h0, "ARITH: Transfer A");

        apply_and_check(32'hFFFFFFFF, 32'h00000000, 1'b1, 1'b0, 1'b0, 4'h0, "ARITH: Increment A (Cin=1)");



        apply_and_check(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, 1'b0, 1'b0, 4'h1, "ARITH: A + B (max)");

        apply_and_check(32'h00000001, 32'h00000001, 1'b1, 1'b0, 1'b0, 4'h1, "ARITH: A + B + 1");



        apply_and_check(32'h00000004, 32'h00000003, 1'b0, 1'b0, 1'b0, 4'h2, "ARITH: A - B - 1 (Cin=0)");

        apply_and_check(32'h00000004, 32'h00000003, 1'b1, 1'b0, 1'b0, 4'h2, "ARITH: A - B (Cin=1)");



        apply_and_check(32'h00000000, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'h3, "ARITH: Decrement A (underflow)");

        apply_and_check(32'h00000001, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'h3, "ARITH: Decrement A");



        apply_and_check(32'h80000000, 32'h7FFFFFFF, 1'b0, 1'b0, 1'b0, 4'h1, "ARITH: Overflow-style case");



        // -----------------------------

        // Directed Logic Tests

        // -----------------------------

        $display("---- Logic tests ----");

        apply_and_check(32'h0F0F0F0F, 32'hF0F0F0F0, 1'b0, 1'b0, 1'b0, 4'h4, "LOGIC: AND");

        apply_and_check(32'h0F0F0F0F, 32'hF0F0F0F0, 1'b0, 1'b0, 1'b0, 4'h5, "LOGIC: OR");

        apply_and_check(32'hAAAAAAAA, 32'h55555555, 1'b0, 1'b0, 1'b0, 4'h6, "LOGIC: XOR");

        apply_and_check(32'h00000000, 32'hDEADBEEF, 1'b0, 1'b0, 1'b0, 4'h7, "LOGIC: NOT A");



        // -----------------------------

        // Directed Shift Tests

        // -----------------------------

        $display("---- Shift tests ----");

        // shift-right: sel[3:2] = 2'b10 (lower bits don't matter for modular wiring)

        apply_and_check(32'h12345678, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'b10_00, "SHIFT: Right (DR=0)");

        apply_and_check(32'h12345678, 32'h00000000, 1'b0, 1'b0, 1'b1, 4'b10_11, "SHIFT: Right (DR=1, sel varied)");



        // shift-left: sel[3:2] = 2'b11

        apply_and_check(32'h12345678, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'b11_00, "SHIFT: Left (DL=0)");

        apply_and_check(32'h12345678, 32'h00000000, 1'b0, 1'b1, 1'b0, 4'b11_10, "SHIFT: Left (DL=1, sel varied)");



        // Small loop to sweep DinL/DinR combos on shifts

        for (n = 0; n < 4; n = n + 1) begin

            apply_and_check(32'h89ABCDEF, 32'h0, 1'b0, n[1], n[0], 4'b10_01, "SHIFT SWEEP: Right");

            apply_and_check(32'h89ABCDEF, 32'h0, 1'b0, n[1], n[0], 4'b11_01, "SHIFT SWEEP: Left");

        end



        // -----------------------------

        // Randomized Tests

        // -----------------------------

        $display("---- Randomized sweep ----");

        repeat (25) begin

            apply_and_check(

                $random,                 // A

                $random,                 // B

                $random & 1'b1,          // Cin

                $random & 1'b1,          // DinL

                $random & 1'b1,          // DinR

                $random & 16'h000F,      // sel

                "RANDOM"

            );

        end



        $display("\nAll functional verification tests completed.\n");

        $finish;

    end



    // =========================================================

    // Task: apply_and_check

    // - Drives inputs

    // - Computes expected output

    // - Waits for settle

    // - Checks & prints a readable verdict

    // =========================================================

    task apply_and_check;

        input [31:0] a;

        input [31:0] b;

        input        ci;

        input        dl;

        input        dr;

        input [3:0]  s;

        input [8*80:1] label;

        reg   [31:0] mux_in;

        reg   [32:0] sum_ext;

    begin

        // Drive signals

        A    = a;

        B    = b;

        Cin  = ci;

        DinL = dl;

        DinR = dr;

        sel  = s;



        // Defaults

        expected_F    = 32'd0;

        expected_Cout = 1'b0;



        // Golden model (matches behavioral spec)

        case (sel[3:2])

            2'b00: begin

                case (sel[1:0])

                    2'b00: mux_in = 32'h00000000;

                    2'b01: mux_in = B;

                    2'b10: mux_in = ~B;

                    2'b11: mux_in = 32'hFFFFFFFF;

                    default: mux_in = 32'h00000000;

                endcase

                sum_ext        = {1'b0, A} + {1'b0, mux_in} + Cin;

                expected_F     = sum_ext[31:0];

                expected_Cout  = sum_ext[32];

            end



            2'b01: begin

                case (sel[1:0])

                    2'b00: expected_F = A & B;

                    2'b01: expected_F = A | B;

                    2'b10: expected_F = A ^ B;

                    2'b11: expected_F = ~A;

                endcase

                expected_Cout = 1'b0;

            end



            2'b10: begin

                expected_F    = {DinR, A[31:1]};

                expected_Cout = 1'b0;

            end



            2'b11: begin

                expected_F    = {A[30:0], DinL};

                expected_Cout = 1'b0;

            end

        endcase



        // Let combinational logic settle

        #3;



        // Print + compare

        $display("------------------------------------------------------------");

        $display("%0s | sel=0x%0h  A=0x%08h  B=0x%08h  Cin=%0d DinL=%0d DinR=%0d",

                 label, sel, A, B, Cin, DinL, DinR);

        $display("Expected: F=0x%08h Cout=%0d | Got: F=0x%08h Cout=%0d",

                 expected_F, expected_Cout, F, Cout);



        if (sel[3:2] == 2'b00) begin

            // Arithmetic checks both F and Cout

            if ((F === expected_F) && (Cout === expected_Cout))

                $display("[PASS] Arithmetic");

            else

                $display("[FAIL] Arithmetic");

        end else begin

            // Logic/Shift checks only F (Cout forced 0 by spec)

            if (F === expected_F)

                $display("[PASS] Logic/Shift");

            else

                $display("[FAIL] Logic/Shift");

        end



        $display("------------------------------------------------------------\n");

    end

    endtask



endmodule


