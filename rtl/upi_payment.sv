/*FSM based control banaya UPI payment ko 3 states (IDLE → PROCESS → SUCCESS) ke FSM se model kiya, jisse transaction ka proper flow maintain ho.
Delay / latency simulate ki Counter (upi_timer) use karke real UPI processing delay ko abstract kiya, jaise real life me payment instant nahi hota.
Handshake signals implement kiye pay_req aur pay_done signals se vending machine ke saath clean handshake ensure kiya. */

module upi_payment (
    input  logic clk,
    input  logic rst_n,

    input  logic pay_req,      
    output logic pay_done,     

    output logic upi_busy,     
    output logic upi_success  
);

    // FSM for UPI transaction
    typedef enum logic [1:0] {
        UPI_IDLE,
        UPI_PROCESS,
        UPI_SUCCESS
    } upi_state_t;

    upi_state_t curr_state, next_state;

    // timer to simulate UPI processing delay
    logic [2:0] upi_timer;

    // ---------------- State Register ----------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= UPI_IDLE;
        else
            curr_state <= next_state;
    end

    // ---------------- Timer Logic ----------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            upi_timer <= 0;
        else if (curr_state == UPI_PROCESS)
            upi_timer <= upi_timer + 1;
        else
            upi_timer <= 0;
    end

    // ---------------- FSM Logic ----------------
    always_comb begin
        // defaults
        next_state  = curr_state;
        pay_done    = 1'b0;
        upi_busy    = 1'b0;
        upi_success = 1'b0;

        case (curr_state)

            // -------- IDLE --------
            UPI_IDLE: begin
                if (pay_req)
                    next_state = UPI_PROCESS;
            end

            // -------- PROCESS --------
            UPI_PROCESS: begin
                upi_busy = 1'b1;
                if (upi_timer == 3'd4)
                    next_state = UPI_SUCCESS;
            end

            // -------- SUCCESS --------
            UPI_SUCCESS: begin
                pay_done    = 1'b1;
                upi_success = 1'b1;
                next_state  = UPI_IDLE;
            end

            default: next_state = UPI_IDLE;

        endcase
    end

endmodule
