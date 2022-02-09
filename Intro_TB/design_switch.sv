module switch
#(
    parameter       ADDR_WIDTH          =   8,
    parameter       DATA_WIDTH          =   16,
    parameter       ADDR_DIV            =   8'h3F
)
(
    input   logic                           clk,
    input   logic                           rst_n,

    input   logic                           valid,
    input   logic   [ADDR_WIDTH-1:0]        addr,
    input   logic   [DATA_WIDTH-1:0]        data,

    output  logic   [ADDR_WIDTH-1:0]        addr_a,
    output  logic   [DATA_WIDTH-1:0]        data_a,

    output  logic   [ADDR_WIDTH-1:0]        addr_b,
    output  logic   [DATA_WIDTH-1:0]        data_b
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            addr_a                  <=  0;
            data_a                  <=  0;
            addr_b                  <=  0;
            data_b                  <=  0;
        end
        else begin
            if (valid) begin
                if (addr >= 0 && addr <=ADDR_DIV) begin
                    addr_a          <=  addr;
                    data_a          <=  data;

                    addr_b          <=  0;
                    data_b          <=  0;
                end
                else begin
                    addr_a          <=  0;
                    data_a          <=  0;

                    addr_b          <=  addr;
                    data_b          <=  data;
                end
            end
        end
    end

endmodule