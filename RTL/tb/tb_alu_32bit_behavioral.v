`timescale 1ns/1ps

/*

 * Testbench: tb_alu_32bit_behavioral

 *

 * Notes:

 * - Directed tests for arithmetic / logic / shift groups

 * - A small randomized sweep for extra confidence

 * - Self-checking: computes expected results in TB (golden model)

 * - Functionality matches DUT exactly (including carry behavior)

 */



module tb_alu_32bit_behavioral;



    // -----------------------------

    // DUT Inputs (regs)

    // -----------------------------

    reg  [31:0] A;

    reg  [31:0] B;

    reg         CIN;

    reg         DL;

    reg         DR;

    reg  [3:0]  S;



    // -----------------------------

    // DUT Outputs (wires)

    // -----------------------------

    wire [31:0] F;

    wire        COUT;



    // -----------------------------

    // Scoreboard / expected outputs

    // -----------------------------

    reg  [31:0] exp_F;

    reg         exp_COUT;



    integer t;



    // -----------------------------

    // Instantiate DUT

    // -----------------------------

    alu_32bit_behavioral dut (

        .A    (A),

        .B    (B),

        .CIN  (CIN),

        .DL   (DL),

        .DR   (DR),

        .S    (S),

        .F    (F),

        .COUT (COUT)

    );



    // =============================

    // Main stimulus

    // =============================

    initial begin

        $display("\n============================================================");

        $display("     Self-checking TB: alu_32bit_behavioral (32-bit)");

        $display("============================================================\n");



        // Initialize inputs

        A   = 32'd0;

        B   = 32'd0;

        CIN = 1'b0;

        DL  = 1'b0;

        DR  = 1'b0;

        S   = 4'h0;



        // ---------- Arithmetic (S[3:2] = 00) ----------

        $display("---- Arithmetic tests ----");

        do_alu_check(32'h00000000, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'h0, "ARITH: Transfer A (Cin=0)");

        do_alu_check(32'hFFFFFFFF, 32'h00000000, 1'b1, 1'b0, 1'b0, 4'h0, "ARITH: A + 0 + Cin (increment edge)");



        do_alu_check(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, 1'b0, 1'b0, 4'h1, "ARITH: A + B (max + max)");

        do_alu_check(32'h00000001, 32'h00000001, 1'b1, 1'b0, 1'b0, 4'h1, "ARITH: A + B + Cin");



        do_alu_check(32'h00000004, 32'h00000003, 1'b0, 1'b0, 1'b0, 4'h2, "ARITH: A + ~B + Cin (A-B-1)");

        do_alu_check(32'h00000004, 32'h00000003, 1'b1, 1'b0, 1'b0, 4'h2, "ARITH: A + ~B + Cin (A-B)");



        do_alu_check(32'h00000000, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'h3, "ARITH: A + 0xFFFF_FFFF + 0 (decrement underflow)");

        do_alu_check(32'h00000001, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'h3, "ARITH: decrement A");



        // ---------- Logic (S[3:2] = 01) ----------

        $display("---- Logic tests ----");

        do_alu_check(32'h0F0F0F0F, 32'hF0F0F0F0, 1'b0, 1'b0, 1'b0, 4'h4, "LOGIC: AND");

        do_alu_check(32'h0F0F0F0F, 32'hF0F0F0F0, 1'b0, 1'b0, 1'b0, 4'h5, "LOGIC: OR");

        do_alu_check(32'hAAAAAAAA, 32'h55555555, 1'b0, 1'b0, 1'b0, 4'h6, "LOGIC: XOR");

        do_alu_check(32'h00000000, 32'hDEADBEEF, 1'b0, 1'b0, 1'b0, 4'h7, "LOGIC: NOT A");



        // ---------- Shifts (S[3:2] = 10/11) ----------

        $display("---- Shift tests ----");

        do_alu_check(32'h12345678, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'b10_00, "SHIFT: right, DR=0");

        do_alu_check(32'h12345678, 32'h00000000, 1'b0, 1'b0, 1'b1, 4'b10_00, "SHIFT: right, DR=1");



        do_alu_check(32'h12345678, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'b11_00, "SHIFT: left, DL=0");

        do_alu_check(32'h12345678, 32'h00000000, 1'b0, 1'b1, 1'b0, 4'b11_00, "SHIFT: left, DL=1");



        // ---------- Random sweep ----------

        $display("---- Randomized sweep ----");

        for (t = 0; t < 20; t = t + 1) begin

            do_alu_check(

                $random,                 // A

                $random,                 // B

                $random & 1,             // CIN

                $random & 1,             // DL

                $random & 1,             // DR

                $random & 16'h000F,      // S

                "RANDOM"

            );

        end



        $display("\nAll checks complete.\n");

        $finish;

    end



    // =========================================================

    // Task: do_alu_check

    // - Drives inputs

    // - Computes expected outputs (golden model)

    // - Waits a short time, compares DUT vs expected

    // =========================================================

    task do_alu_check;

        input [31:0] a;

        input [31:0] b;

        input        cin;

        input        dl;

        input        dr;

        input [3:0]  sel;

        input [8*80:1] name; // string-like packed array (classic Verilog)

        reg   [31:0] arith_b;

        reg   [32:0] sum_ext;

    begin

        // Drive

        A   = a;

        B   = b;

        CIN = cin;

        DL  = dl;

        DR  = dr;

        S   = sel;



        // Default expected

        exp_F    = 32'd0;

        exp_COUT = 1'b0;



        // Golden model mirrors DUT behavior

        case (sel[3:2])



            // Arithmetic

            2'b00: begin

                case (sel[1:0])

                    2'b00: arith_b = 32'h00000000;

                    2'b01: arith_b = B;

                    2'b10: arith_b = ~B;

                    2'b11: arith_b = 32'hFFFFFFFF;

                    default: arith_b = 32'h00000000;

                endcase



                sum_ext   = {1'b0, A} + {1'b0, arith_b} + CIN;

                exp_F     = sum_ext[31:0];

                exp_COUT  = sum_ext[32];

            end



            // Logic

            2'b01: begin

                case (sel[1:0])

                    2'b00: exp_F = A & B;

                    2'b01: exp_F = A | B;

                    2'b10: exp_F = A ^ B;

                    2'b11: exp_F = ~A;

                endcase

                exp_COUT = 1'b0;

            end



            // Shift Right

            2'b10: begin

                exp_F    = {DR, A[31:1]};

                exp_COUT = 1'b0;

            end



            // Shift Left

            2'b11: begin

                exp_F    = {A[30:0], DL};

                exp_COUT = 1'b0;

            end

        endcase



        // Let combinational settle

        #2;



        // Report + check

        $display("------------------------------------------------------------");

        $display("%0s | S=0x%0h  A=0x%08h  B=0x%08h  CIN=%0d DL=%0d DR=%0d",

                 name, sel, A, B, CIN, DL, DR);

        $display("Expected: F=0x%08h COUT=%0d | Got: F=0x%08h COUT=%0d",

                 exp_F, exp_COUT, F, COUT);



        if ((F === exp_F) && (COUT === exp_COUT))

            $display("[PASS]");

        else begin

            $display("[FAIL]");

            // Optional: stop on first failure

            // $stop;

        end

        $display("------------------------------------------------------------\n");

    end

    endtask



endmodule


