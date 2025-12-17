`timescale 1ns/1ps

/*

 * Testbench: tb_alu32_modular_vs_behavioral

 *

 * Purpose:

 * - Instantiates BOTH implementations:

 *     1) alu_32bit_modular

 *     2) alu_32bit_behavioral

 * - Applies identical stimulus to each

 * - Compares outputs cycle-by-cycle

 *

 * Compare rules:

 * - Arithmetic (sel[3:2] == 2'b00): compare F and Cout

 * - Logic/Shift: compare only F (Cout is expected 0 / ignored)

 */



module tb_alu32_modular_vs_behavioral;



    // Shared stimulus

    reg  [31:0] A, B;

    reg         Cin, DinL, DinR;

    reg  [3:0]  sel;



    // Outputs from each DUT

    wire [31:0] F_mod, F_beh;

    wire        Cout_mod, Cout_beh;



    integer k;



    // -----------------------------

    // DUT #1: Modular (bit-sliced)

    // -----------------------------

    alu_32bit_modular u_mod (

        .A    (A),

        .B    (B),

        .Cin  (Cin),

        .DinL (DinL),

        .DinR (DinR),

        .sel  (sel),

        .F    (F_mod),

        .Cout (Cout_mod)

    );



    // -----------------------------

    // DUT #2: Behavioral (reference)

    // -----------------------------

    alu_32bit_behavioral u_beh (

        .A    (A),

        .B    (B),

        .CIN  (Cin),

        .DL   (DinL),

        .DR   (DinR),

        .S    (sel),

        .F    (F_beh),

        .COUT (Cout_beh)

    );



    // =============================

    // Main stimulus

    // =============================

    initial begin

        $display("\n============================================================");

        $display("      Modular vs Behavioral ALU (32-bit) Cross-Check TB");

        $display("============================================================\n");



        // init

        A    = 32'd0;

        B    = 32'd0;

        Cin  = 1'b0;

        DinL = 1'b0;

        DinR = 1'b0;

        sel  = 4'h0;



        // -----------------------------

        // Arithmetic checks

        // -----------------------------

        $display("---- Arithmetic comparisons ----");

        drive_and_compare(32'h00000000, 32'h00000000, 1'b0, 1'b0, 1'b0, 4'h0, "ARITH: Transfer A");

        drive_and_compare(32'hFFFFFFFF, 32'h00000000, 1'b1, 1'b0, 1'b0, 4'h0, "ARITH: Increment A (Cin=1)");



        drive_and_compare(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0, 1'b0, 1'b0, 4'h1, "ARITH: A + B (max)");

        drive_and_compare(32'h00000001, 32'h00000001, 1'b1, 1'b0, 1'b0, 4'h1, "ARITH: A + B + 1");



        drive_and_compare(32'h00000004, 32'h00000003, 1'b0, 1'b0, 1'b0, 4'h2, "ARITH: A - B - 1");

        drive_and_compare(32'h00000004, 32'h00000003, 1'b1, 1'b0, 1'b0, 4'h2, "ARITH: A - B");



        drive_and_compare(32'h00000003, 32'h00000004, 1'b0, 1'b0, 1'b0, 4'h2, "ARITH: A - B - 1 (B>A)");

        drive_and_compare(32'h00000003, 32'h00000004, 1'b1, 1'b0, 1'b0, 4'h2, "ARITH: A - B (B>A)");



        drive_and_compare(32'h00000000, 32'hDEADBEEF, 1'b0, 1'b0, 1'b0, 4'h3, "ARITH: Decrement A (underflow)");

        drive_and_compare(32'h00000001, 32'hDEADBEEF, 1'b0, 1'b0, 1'b0, 4'h3, "ARITH: Decrement A");

        drive_and_compare(32'hFFFFFFFF, 32'hDEADBEEF, 1'b1, 1'b0, 1'b0, 4'h3, "ARITH: Transfer A (sel=3,Cin=1)");



        drive_and_compare(32'h80000000, 32'h7FFFFFFF, 1'b0, 1'b0, 1'b0, 4'h1, "ARITH: Overflow-style case");



        // -----------------------------

        // Logic checks

        // -----------------------------

        $display("---- Logic comparisons ----");

        drive_and_compare(32'h0F0F0F0F, 32'hF0F0F0F0, 1'b0, 1'b0, 1'b0, 4'h4, "LOGIC: AND");

        drive_and_compare(32'h0F0F0F0F, 32'hF0F0F0F0, 1'b0, 1'b0, 1'b0, 4'h5, "LOGIC: OR");

        drive_and_compare(32'hAAAAAAAA, 32'h55555555, 1'b0, 1'b0, 1'b0, 4'h6, "LOGIC: XOR");

        drive_and_compare(32'h00000000, 32'h12345678, 1'b0, 1'b0, 1'b0, 4'h7, "LOGIC: NOT A");



        // -----------------------------

        // Shift checks (sweep DinL/DinR)

        // -----------------------------

        $display("---- Shift comparisons ----");

        for (k = 0; k < 4; k = k + 1) begin

            // DinL = k[1], DinR = k[0]

            drive_and_compare(32'h12345678, 32'h0, 1'b0, k[1], k[0], 4'h8, "SHIFT: Right (sel=8)");

            drive_and_compare(32'h12345678, 32'h0, 1'b0, k[1], k[0], 4'hA, "SHIFT: Right (sel=A)");



            drive_and_compare(32'h12345678, 32'h0, 1'b0, k[1], k[0], 4'hC, "SHIFT: Left (sel=C)");

            drive_and_compare(32'h12345678, 32'h0, 1'b0, k[1], k[0], 4'hD, "SHIFT: Left (sel=D)");

        end



        // -----------------------------

        // Random cross-check

        // -----------------------------

        $display("---- Random cross-check ----");

        repeat (30) begin

            drive_and_compare(

                $random,                 // A

                $random,                 // B

                $random & 1'b1,          // Cin

                $random & 1'b1,          // DinL

                $random & 1'b1,          // DinR

                $random & 16'h000F,      // sel

                "RANDOM"

            );

        end



        $display("\nAll modular vs behavioral comparisons completed.\n");

        $finish;

    end



    // =========================================================

    // Task: drive_and_compare

    // - Drive common stimulus

    // - Wait for settle

    // - Print both outputs

    // - Enforce match policy

    // =========================================================

    task drive_and_compare;

        input [31:0] tA, tB;

        input        tCin, tDinL, tDinR;

        input [3:0]  tSel;

        input [8*80:1] tag;

    begin

        A    = tA;

        B    = tB;

        Cin  = tCin;

        DinL = tDinL;

        DinR = tDinR;

        sel  = tSel;



        // allow combinational propagation

        #3;



        $display("------------------------------------------------------------");

        $display("%0s | sel=0x%0h  A=0x%08h  B=0x%08h  Cin=%0d DinL=%0d DinR=%0d",

                 tag, sel, A, B, Cin, DinL, DinR);



        if (sel[3:2] == 2'b00) begin

            // Arithmetic: compare both F and Cout

            $display("MOD: F=0x%08h Cout=%0d", F_mod, Cout_mod);

            $display("BEH: F=0x%08h Cout=%0d", F_beh, Cout_beh);



            if ((F_mod === F_beh) && (Cout_mod === Cout_beh))

                $display("[PASS] Arithmetic match");

            else

                $display("[FAIL] Arithmetic mismatch");

        end else begin

            // Logic/Shift: compare only F

            $display("MOD: F=0x%08h (Cout=%0d ignored)", F_mod, Cout_mod);

            $display("BEH: F=0x%08h (Cout=%0d ignored)", F_beh, Cout_beh);



            if (F_mod === F_beh)

                $display("[PASS] Logic/Shift match");

            else

                $display("[FAIL] Logic/Shift mismatch");

        end



        $display("------------------------------------------------------------\n");

    end

    endtask



endmodule


