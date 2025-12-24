module vending_machine_tb;

    // ---------------- Signals ----------------
    logic clk;
    logic rst_n;

    logic [2:0] tray_sel;
    logic [2:0] product_sel;

    logic upi_pay_req;
    logic upi_pay_done;

    logic spring_motor_en;
    logic dispense;
    logic [7:0] amount;
    logic error;

    // ---------------- Clock Generation ----------------
    always #5 clk = ~clk;   // 10ns clock period

    // ---------------- DUT : Vending Machine ----------------
    vending_machine dut (
        .clk(clk),
        .rst_n(rst_n),
        .tray_sel(tray_sel),
        .product_sel(product_sel),
        .upi_pay_req(upi_pay_req),
        .upi_pay_done(upi_pay_done),
        .spring_motor_en(spring_motor_en),
        .dispense(dispense),
        .amount(amount),
        .error(error)
    );

    // ---------------- UPI Payment Model ----------------
    upi_payment u_upi (
        .clk(clk),
        .rst_n(rst_n),
        .pay_req(upi_pay_req),
        .pay_done(upi_pay_done),
        .upi_busy(),
        .upi_success()
    );

    // ---------------- Test Sequence ----------------
    initial begin
        // init
        clk = 0;
        rst_n = 0;
        tray_sel = 0;
        product_sel = 0;
        upi_pay_req = 0;

        // reset
        #20;
        rst_n = 1;

        // -------- Test Case 1 : Normal Purchase --------
        #10;
        tray_sel    = 3'd1;
        product_sel = 3'd2;

        #20;
        upi_pay_req = 1'b1;   // start payment

        #10;
        upi_pay_req = 1'b0;   // deassert request

        // wait for dispense
        wait (dispense == 1'b1);
        $display("Product Dispensed | Amount = %0d", amount);

        #20;

        // -------- Test Case 2 : Invalid Selection --------
        tray_sel    = 3'd6;   // invalid
        product_sel = 3'd1;

        #20;
        if (error)
            $display("Error detected for invalid selection");

        #50;
        $finish;
    end

endmodule
