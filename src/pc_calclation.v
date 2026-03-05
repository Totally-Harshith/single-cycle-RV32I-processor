module pc_calc (
    input [31:0] PC,                 // Getting the programme counter from PC
    input [31:0] immediate,          // Immediate from immediate generator
    input [31:0] ro1,                // value of register with index rs1 from reg_bank
    output [31:0] pc_default,pc_branch,pc_jal,pc_jalr   
);

assign pc_default = PC + 4;          // default instruction execution

assign pc_branch = PC + immediate;   // If branch is successful

assign pc_jal = PC + immediate;      // for JAL instruction (we use seperate value even though we are encoding the same value because branch in conditional and jump is unconditional)

assign pc_jalr = (ro1 + immediate) & ~1;  // For JALR instruction
    
endmodule