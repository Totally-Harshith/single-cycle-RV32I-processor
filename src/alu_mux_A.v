module alu_mux_A (
    input [31:0] ro1, PC,         //  inputs to the MUX
    input alu_src_A,               // Control signal from the decoder
    output [31:0] A              // input to the ALU
);

assign A = (alu_src_A) ? PC : ro1;
    
endmodule