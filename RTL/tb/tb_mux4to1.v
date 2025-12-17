`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Testbench : tb_mux4to1
// DUT       : mux4to1
// Purpose   : Verify the 4-to-1 multiplexer by exhaustively sweeping all
//             combinations of inputs and select lines.
// -----------------------------------------------------------------------------
module tb_mux4to1;

    // DUT inputs
    reg a, b, c, d;
    reg [1:0] sel;

    // DUT output
    wire out;

    // Expected output
    reg expected_out;

    integer vec;
    integer error_count;

    // Instantiate DUT
    mux4to1 uut (
        .a  (a),
        .b  (b),
        .c  (c),
        .d  (d),
        .sel(sel),
        .out(out)
    );

    // -------------------------------------------------------------------------
    // Stimulus + checking
    // -------------------------------------------------------------------------
    initial begin
        error_count = 0;

        $display("==============================================================");
        $display("   Functional Verification: mux4to1");
        $display("==============================================================");
        $display(" a b c d | sel | out exp_out | Result");
        $display("--------------------------------------------------------------");

        // Sweep all 64 combinations: 4 data bits + 2 select bits
        for (vec = 0; vec < 64; vec = vec + 1) begin
            {sel, d, c, b, a} = vec[5:0];

            #1; // let combinational path settle

            // Compute expected output
            case (sel)
                2'b00: expected_out = a;
                2'b01: expected_out = b;
                2'b10: expected_out = c;
                2'b11: expected_out = d;
            endcase

            if (out !== expected_out) begin
                error_count = error_count + 1;
                $display(" %0b %0b %0b %0b | %02b  |  %0b     %0b   | FAIL",
                         a, b, c, d, sel, out, expected_out);
            end
            else begin
                $display(" %0b %0b %0b %0b | %02b  |  %0b     %0b   | PASS",
                         a, b, c, d, sel, out, expected_out);
            end
        end

        $display("--------------------------------------------------------------");
        if (error_count == 0)
            $display("All mux4to1 tests PASSED.");
        else
            $display("mux4to1 tests FAILED. Errors: %0d", error_count);
        $display("==============================================================\n");

        $finish;
    end

endmodule

