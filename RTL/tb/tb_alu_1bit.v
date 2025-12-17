`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Testbench : tb_alu_1bit
// DUT       : alu_1bit
// Purpose   : Verify 1-bit ALU cell behavior across arithmetic, logic, and shift
//             operations for a variety of input combinations and sel values.
//
//   sel[3:2] group:
//     00 -> arithmetic_unit result (Di)
//     01 -> logic_unit result (Ei)
//     10 -> shift right : Fi = A_prev
//     11 -> shift left  : Fi = A_next
//
//   sel[1:0] are used by both arithmetic_unit and logic_unit as before.
//
//   NOTE: Couti always comes from the arithmetic_unit, regardless of sel[3:2].
// -----------------------------------------------------------------------------
module tb_alu_1bit;

    // DUT inputs
    reg Ai;
    reg Bi;
    reg A_prev;
    reg A_next;
    reg Cini;
    reg [3:0] sel;

    // DUT outputs
    wire Fi;
    wire Couti;

    // Expected outputs
    reg expected_Fi;
    reg expected_Couti;

    integer a, b, ap, an, cin;
    integer s;
    integer error_count;

    // Instantiate DUT
    alu_1bit uut (
        .Ai    (Ai),
        .Bi    (Bi),
        .A_prev(A_prev),
        .A_next(A_next),
        .Cini  (Cini),
        .sel   (sel),
        .Fi    (Fi),
        .Couti (Couti)
    );

    // -------------------------------------------------------------------------
    // Helper: compute expected Couti (always arithmetic) and Fi (depends on sel)
    // ----------------------------------------------------------------------------
    task automatic compute_expected;
        input  reg Ai_in;
        input  reg Bi_in;
        input  reg A_prev_in;
        input  reg A_next_in;
        input  reg Cini_in;
        input  reg [3:0] sel_in;
        output reg Fi_out;
        output reg Cout_out;

        reg B_variant;
        reg [1:0] sum;
        reg logic_result;

        begin
            // Arithmetic B-variant based on sel[1:0] (same as arithmetic_unit)
            case (sel_in[1:0])
                2'b00: B_variant = 1'b0;
                2'b01: B_variant = Bi_in;
                2'b10: B_variant = ~Bi_in;
                2'b11: B_variant = 1'b1;
            endcase

            // Arithmetic sum and carry (Cout is always from arithmetic_unit)
            sum      = Ai_in + B_variant + Cini_in;
            Cout_out = sum[1];

            // Logic result based on sel[1:0] (same as logic_unit)
            case (sel_in[1:0])
                2'b00: logic_result = Ai_in & Bi_in;
                2'b01: logic_result = Ai_in | Bi_in;
                2'b10: logic_result = Ai_in ^ Bi_in;
                2'b11: logic_result = ~Ai_in;
            endcase

            // Final Fi based on sel[3:2] group
            case (sel_in[3:2])
                2'b00: Fi_out = sum[0];        // arithmetic result
                2'b01: Fi_out = logic_result;  // logic result
                2'b10: Fi_out = A_prev_in;     // shift right
                2'b11: Fi_out = A_next_in;     // shift left
                default: Fi_out = 1'bx;
            endcase
        end
    endtask

    // -------------------------------------------------------------------------
    // Stimulus + checking
    // -------------------------------------------------------------------------
    initial begin
        error_count = 0;

        $display("==============================================================");
        $display("   Functional Verification: alu_1bit");
        $display("==============================================================");
        $display(" Ai Bi Ap An Cin | sel | Fi Cout | Exp_Fi Exp_Cout | Result");
        $display("------------------------------------------------------------------");

        // Not strictly exhaustive, but thorough: 2^5 inputs * 16 sel = 512 tests
        for (s = 0; s < 16; s = s + 1) begin
            for (a = 0; a <= 1; a = a + 1) begin
                for (b = 0; b <= 1; b = b + 1) begin
                    for (ap = 0; ap <= 1; ap = ap + 1) begin
                        for (an = 0; an <= 1; an = an + 1) begin
                            for (cin = 0; cin <= 1; cin = cin + 1) begin
                                sel    = s[3:0];
                                Ai     = a[0];
                                Bi     = b[0];
                                A_prev = ap[0];
                                A_next = an[0];
                                Cini   = cin[0];

                                #1;

                                compute_expected(
                                    Ai, Bi, A_prev, A_next, Cini, sel,
                                    expected_Fi, expected_Couti
                                );

                                $write("  %0d  %0d  %0d  %0d   %0d | %04b |  %0d   %0d  |    %0d       %0d    | ",
                                       Ai, Bi, A_prev, A_next, Cini,
                                       sel, Fi, Couti,
                                       expected_Fi, expected_Couti);

                                if (Fi !== expected_Fi || Couti !== expected_Couti) begin
                                    error_count = error_count + 1;
                                    $display("FAIL");
                                end
                                else begin
                                    $display("PASS");
                                end
                            end
                        end
                    end
                end
            end
        end

        $display("------------------------------------------------------------------");
        if (error_count == 0)
            $display("All alu_1bit tests PASSED.");
        else
            $display("alu_1bit tests FAILED. Errors: %0d", error_count);
        $display("==============================================================\n");

        $finish;
    end

endmodule

