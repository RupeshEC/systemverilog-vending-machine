
/* FSM: Har state alag kaam karti hai, ek time pe ek hi active
Price memory: 2D array se tray-product pricing handle ki
Spring: Counter se real motor timing abstract ki
FSM flow: IDLE → SELECT → PAY → SPRING → DISPENSE 
###
in short FSM declare kiya, prices ko 2-D memory me store kiya,
spring movement ko counter-basedabstraction se model kiya, sequential block me state register banaya 
aur combinational block me state transitions aur outputs control kiye.*/


module vending_machine (
    input  logic        clk,
    input  logic        rst_n,

    input  logic [2:0]  tray_sel,
    input  logic [2:0]  product_sel,

    input  logic        upi_pay_req,
    input  logic        upi_pay_done,

    output logic        spring_motor_en,
    output logic        dispense,
    output logic [7:0]  amount,
    output logic        error
);

    // ================= FSM DECLARATION =================
    typedef enum logic [2:0] {
        IDLE,
        SELECT,
        WAIT_PAYMENT,
        SPRING_MOVE,
        DISPENSE
    } state_t;

    state_t curr_state, next_state;

    // ================= PRICE MEMORY =================
    logic [7:0] price_mem [0:4][0:4];

    initial begin
        foreach (price_mem[i,j])
            price_mem[i][j] = 8'd10 + (i*5) + j;
    end

    // ================= SPRING ROTATION LOGIC =================
    logic [2:0] spring_cnt;
    logic       spring_done;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spring_cnt  <= 0;
            spring_done <= 0;
        end
        else if (spring_motor_en) begin
            if (spring_cnt == 3'd4) begin
                spring_cnt  <= 0;
                spring_done <= 1'b1;
            end
            else begin
                spring_cnt  <= spring_cnt + 1;
                spring_done <= 1'b0;
            end
        end
        else begin
            spring_cnt  <= 0;
            spring_done <= 1'b0;
        end
    end

    // ================= STATE REGISTER =================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // ================= FSM COMBINATIONAL LOGIC =================
    always_comb begin
        // defaults (VERY IMPORTANT)
        next_state      = curr_state;
        spring_motor_en = 1'b0;
        dispense        = 1'b0;
        amount          = 8'd0;
        error           = 1'b0;

        case (curr_state)

            // ---------- IDLE ----------
            IDLE: begin
                if (tray_sel < 5 && product_sel < 5)
                    next_state = SELECT;
                else
                    error = 1'b1;
            end

            // ---------- SELECT ----------
            SELECT: begin
                amount = price_mem[tray_sel][product_sel];
                if (upi_pay_req)
                    next_state = WAIT_PAYMENT;
            end

            // ---------- WAIT PAYMENT ----------
            WAIT_PAYMENT: begin
                amount = price_mem[tray_sel][product_sel];
                if (upi_pay_done)
                    next_state = SPRING_MOVE;
            end

            // ---------- SPRING MOVE ----------
            SPRING_MOVE: begin
                spring_motor_en = 1'b1;
                if (spring_done)
                    next_state = DISPENSE;
            end

            // ---------- DISPENSE ----------
            DISPENSE: begin
                dispense   = 1'b1;
                next_state = IDLE;
            end

            default: next_state = IDLE;

        endcase
    end

endmodule

   






























  
