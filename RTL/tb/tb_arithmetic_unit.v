`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Testbench : tb_arithmetic_unit
// DUT       : arithmetic_unit
// Purpose   : Verify arithmetic behavior for all combinations of Ai, Bi, Cini,
//             and sel[1:0], matching the internal mux + full adder behavior.
//
//   sel encoding inside arithmetic_unit:
//     00 -> B_variant = 0
//     01 -> B_variant = Bi
//     10 -> B_variant = ~Bi (1-bit)
//     11 -> B_variant = 1
//
//   Then performs: Ai + B_variant + Cini
// -----------------------------------------------------------------------------
module tb_arithmetic_unit;

    // DUT inputs
    reg Ai;
    reg Bi;
    reg Cini;
    reg [1:0] sel;

    // DUT outputs
    wire Di;
    wire Couti;

    // Expected outputs
    reg expected_Di;
    reg expected_Couti;

    // For logging
    reg [255:0] operation_name;

    // Internal helper regs for expected arithmetic
    reg B_variant;       // Selected B-like operand for reference model
    reg [1:0] sum;       // 2-bit sum: {carry_out, sum_bit}

    integer a, b, cin, s;
    integer error_count;

    // Instantiate DUT
    arithmetic_unit uut (
        .Ai   (Ai),
        .Bi   (Bi),
        .Cini (Cini),
        .sel  (sel),
        .Di   (Di),
        .Couti(Couti)
    );

    // -------------------------------------------------------------------------
    // Helper: compute operation name based on sel
    // -------------------------------------------------------------------------
    task decode_operation_name;
        input [1:0] sel_in;
        begin
            case (sel_in)
                2'b00: operation_name = "Ai + 0 + Cini";
                2'b01: operation_name = "Ai + Bi + Cini";
                2'b10: operation_name = "Ai + ~Bi + Cini";
                2'b11: operation_name = "Ai + 1 + Cini";
                default: operation_name = "Unknown";
            endcase
        end
    endtask

    // -------------------------------------------------------------------------
    // Stimulus + checking
    // -------------------------------------------------------------------------
    initial begin
        error_count = 0;

        $display("==============================================================");
        $display("   Functional Verification: arithmetic_unit");
        $display("==============================================================");
        $display(" Ai Bi Cin | sel | Di Cout | Exp_Di Exp_Cout | Operation          | Result");
        $display("-------------------------------------------------------------------------");

        for (s = 0; s < 4; s = s + 1) begin
            sel = s[1:0];
            decode_operation_name(sel);

            for (a = 0; a <= 1; a = a + 1) begin
                for (b = 0; b <= 1; b = b + 1) begin
                    for (cin = 0; cin <= 1; cin = cin + 1) begin
                        Ai   = a[0];
                        Bi   = b[0];
                        Cini = cin[0];

                        #1;

                        // Derive B-variant based on sel
                        // (matches arithmetic_unit behavior)
                        case (sel)
                            2'b00: B_variant = 1'b0;
                            2'b01: B_variant = Bi;
                            2'b10: B_variant = ~Bi;
                            2'b11: B_variant = 1'b1;
                        endcase

                        // 2-bit sum: {carry, sum_bit}
                        sum = Ai + B_variant + Cini;
                        expected_Di    = sum[0];
                        expected_Couti = sum[1];

                        $write("  %0d  %0d  %0d | %02b  |  %0d   %0d  |   %0d       %0d    | %s | ",
                               Ai, Bi, Cini, sel, Di, Couti,
                               expected_Di, expected_Couti, operation_name);

                        if (Di !== expected_Di || Couti !== expected_Couti) begin
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

        $display("-------------------------------------------------------------------------");
        if (error_count == 0)
            $display("All arithmetic_unit tests PASSED.");
        else
            $display("arithmetic_unit tests FAILED. Errors: %0d", error_count);
        $display("==============================================================\n");

        $finish;
    end

endmodule

