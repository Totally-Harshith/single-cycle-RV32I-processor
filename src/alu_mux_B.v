module alu_mux_B (
    input alu_src_B,                     // signal from decoder which specifies what to choose as input (select line)
    input [31:0] ro2,immediate,        // register 2 from regbank and immediate from immgen  (acts as input)
    output [31:0] B                    // Input being given to ALU
);

assign B = (alu_src_B)? immediate : ro2;

endmodule