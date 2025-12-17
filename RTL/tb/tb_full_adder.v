`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Testbench : tb_full_adder
// DUT       : full_adder
// Purpose   : Exhaustively verify 1-bit full adder behavior for all combinations
//             of Ai, Bi, and Cini.
// -----------------------------------------------------------------------------
module tb_full_adder;

    // DUT inputs
    reg Ai;
    reg Bi;
    reg Cini;

    // DUT outputs
    wire Di;
    wire Couti;

    // Expected results
    reg expected_Di;
    reg expected_Couti;

    integer a, b, cin;
    integer error_count;

    // Instantiate DUT
    full_adder uut (
        .Ai   (Ai),
        .Bi   (Bi),
        .Cini (Cini),
        .Di   (Di),
        .Couti(Couti)
    );

    // -------------------------------------------------------------------------
    // Stimulus + checking
    // -------------------------------------------------------------------------
    initial begin
        error_count = 0;

        $display("==============================================================");
        $display("   Functional Verification: full_adder");
        $display("==============================================================");
        $display(" Ai Bi Cin | Di  Cout | Exp_Di Exp_Cout | Result");
        $display("--------------------------------------------------------------");

        // Exhaustive check of all 2^3 input combinations
        for (a = 0; a <= 1; a = a + 1) begin
            for (b = 0; b <= 1; b = b + 1) begin
                for (cin = 0; cin <= 1; cin = cin + 1) begin
                    // Drive inputs
                    Ai   = a[0];
                    Bi   = b[0];
                    Cini = cin[0];

                    #1; // Allow combinational logic to settle

                    // Compute expected outputs (same equations as DUT)
                    expected_Di    = Ai ^ Bi ^ Cini;
                    expected_Couti = (Ai & Bi) | (Ai & Cini) | (Bi & Cini);

                    // Display and check
                    if (Di !== expected_Di || Couti !== expected_Couti) begin
                        error_count = error_count + 1;
                        $display("  %0d  %0d  %0d |  %0d    %0d  |   %0d       %0d   | FAIL",
                                 Ai, Bi, Cini, Di, Couti, expected_Di, expected_Couti);
                    end
                    else begin
                        $display("  %0d  %0d  %0d |  %0d    %0d  |   %0d       %0d   | PASS",
                                 Ai, Bi, Cini, Di, Couti, expected_Di, expected_Couti);
                    end
                end
            end
        end

        $display("--------------------------------------------------------------");
        if (error_count == 0)
            $display("All Full Adder tests PASSED.");
        else
            $display("Full Adder tests FAILED. Errors: %0d", error_count);
        $display("==============================================================\n");

        $finish;
    end

endmodule

