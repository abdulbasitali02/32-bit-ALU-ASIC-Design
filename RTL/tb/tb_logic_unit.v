`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Testbench : tb_logic_unit
// DUT       : logic_unit
// Purpose   : Verify logical operations (AND, OR, XOR, NOT) for all combinations
//             of inputs and select lines.
// -----------------------------------------------------------------------------
module tb_logic_unit;

    // DUT inputs
    reg Ai;
    reg Bi;
    reg [1:0] sel;

    // DUT output
    wire Ei;

    // Expected output
    reg expected_Ei;

    integer a, b, s;
    integer error_count;

    // Instantiate DUT
    logic_unit uut (
        .Ai (Ai),
        .Bi (Bi),
        .sel(sel),
        .Ei (Ei)
    );

    // -------------------------------------------------------------------------
    // Stimulus + checking
    // -------------------------------------------------------------------------
    initial begin
        error_count = 0;

        $display("==============================================================");
        $display("   Functional Verification: logic_unit");
        $display("==============================================================");
        $display(" Ai Bi | sel | Ei exp_Ei | Operation | Result");
        $display("--------------------------------------------------------------");

        for (s = 0; s < 4; s = s + 1) begin
            for (a = 0; a <= 1; a = a + 1) begin
                for (b = 0; b <= 1; b = b + 1) begin
                    sel = s[1:0];
                    Ai  = a[0];
                    Bi  = b[0];

                    #1;

                    // Compute expected output based on sel encoding:
                    // 00 -> AND, 01 -> OR, 10 -> XOR, 11 -> NOT Ai
                    case (sel)
                        2'b00: expected_Ei = Ai & Bi;
                        2'b01: expected_Ei = Ai | Bi;
                        2'b10: expected_Ei = Ai ^ Bi;
                        2'b11: expected_Ei = ~Ai;
                        default: expected_Ei = 1'bx;
                    endcase

                    // Pretty operation name for log
                    case (sel)
                        2'b00: $write("  %0d  %0d | %02b  | %0d    %0d   | AND      | ",
                                      Ai, Bi, sel, Ei, expected_Ei);
                        2'b01: $write("  %0d  %0d | %02b  | %0d    %0d   | OR       | ",
                                      Ai, Bi, sel, Ei, expected_Ei);
                        2'b10: $write("  %0d  %0d | %02b  | %0d    %0d   | XOR      | ",
                                      Ai, Bi, sel, Ei, expected_Ei);
                        2'b11: $write("  %0d  %0d | %02b  | %0d    %0d   | NOT(Ai)  | ",
                                      Ai, Bi, sel, Ei, expected_Ei);
                    endcase

                    if (Ei !== expected_Ei) begin
                        error_count = error_count + 1;
                        $display("FAIL");
                    end
                    else begin
                        $display("PASS");
                    end
                end
            end
        end

        $display("--------------------------------------------------------------");
        if (error_count == 0)
            $display("All logic_unit tests PASSED.");
        else
            $display("logic_unit tests FAILED. Errors: %0d", error_count);
        $display("==============================================================\n");

        $finish;
    end

endmodule

