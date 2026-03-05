module PC_mux (
    input [1:0] pc_ctrl,
    input [31:0] pc_default,pc_branch,pc_jal,pc_jalr,
    output reg [31:0] nextPC
);

always@(*)begin
    case(pc_ctrl)
    
    2'b00: nextPC = pc_default;

    2'b01: nextPC = pc_branch;

    2'b10: nextPC = pc_jal;

    2'b11: nextPC = pc_jalr;

    default: nextPC = pc_default;

    endcase
end

    
endmodule