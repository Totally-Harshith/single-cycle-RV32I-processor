module ALU(
input [31:0] A,B,           //inputs to the ALU
input [4:0]alu_mode,        // signal given to the ALU from the DECODER
input [2:0]funct3_branch,    // for choosing the right branch operation
output reg branch_taken,    // signal given to cpu for choosing the pc_ctrl
output reg [31:0] alu_out  // Output from the ALU which will be written back to the registerbank
);

wire [4:0] shamt = B[4:0];    //For shift operations

 // the signal from the decoder will be encoded with its equivalent operation in alu
localparam alu_ADD = 5'b00000;
localparam alu_SUB = 5'b00001;
localparam alu_XOR = 5'b00010; 
localparam alu_OR  = 5'b00011;
localparam alu_AND = 5'b00100;
localparam alu_SLL = 5'b00101;  
localparam alu_SRL = 5'b00110;
localparam alu_SRA = 5'b00111;
localparam alu_SLT = 5'b01000;                             //set less than
localparam alu_SLTU= 5'b01001;                             //set less than unsigned

always@(*)begin
    case (alu_mode)                       // based on the signal from decoder we choose the operation
        
        alu_ADD:alu_out = A + B;            // Add Instruction

        alu_SUB:alu_out = A - B;            // SUB Instruction

        alu_XOR:alu_out = A ^ B;            // XOR Instruction

        alu_OR:alu_out  = A | B;            // OR Instruction

        alu_AND:alu_out = A & B;            // AND Instruction

        alu_SLL:alu_out = A << shamt;           // SLL Instruction

        alu_SRL:alu_out = A >> shamt;           // SLR Instruction

        alu_SRA:alu_out = $signed(A) >>> shamt; // SRA Instruction

        alu_SLT:alu_out = ($signed(A) < $signed(B)) ? 1 : 0;  //SLT Instruction
        
        alu_SLTU:alu_out= (A < B) ? 1 : 0;  // SLTU Instruction
        
        default:alu_out=0;                  // if invalid instruction is given this is taken so no latch is infered 
    endcase
end

always@(*)begin
    case (funct3_branch)
    3'b000: begin      // beq instruction
    
    branch_taken = (A == B);

    end

    3'b001:begin       // bne instruction
    
    branch_taken = (A != B);

    end

    3'b100:begin       // blt instruction
    
    branch_taken = ($signed(A) < $signed(B));

    end

    3'b101:begin       // bge instruction

    branch_taken = ($signed(A) >= $signed(B));

    end

    3'b110:begin       // bltu instruction

    branch_taken = (A < B);

    end

    3'b111:begin       // bgeu instruction

    branch_taken = (A >= B);

    end

    default: branch_taken = 0;
    endcase
end




endmodule   
