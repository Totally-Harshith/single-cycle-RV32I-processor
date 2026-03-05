module decoder(
input [31:0] instr,                 // Instruction from the Imem
output reg [4:0] rs1,rs2,rd,       // register indices we get from slicing the instruction being given as input to regbank
output reg reg_write,              // controls register writebacks
output reg [4:0] alu_mode,               // signal which tells alu which operation to be performed
output reg jalr,                     // signal for telling jalr instruction is being executed for making cpu choose ro1+imm as PC
output reg jal,                      // signal for telling jal instruction is being executed for making cpu choose PC+imm as PC
output reg branch,                   // signal for telling one of the branch instructions is active and to also check for branch_taken signal to be active or not
output reg alu_src_A,               // signal to the mux which selects ro1 or PC which is required for the implementation of JAL instruction
output reg alu_src_B,                 // signal to the mux which is being given to the mux which gives immediate or the register value as input to the alu
output reg [2:0] instr_format,       // signal to the immediate generator specifying what format the instruction belongs to
output reg [2:0] funct3_mem,          // signal to secondary memory for selecting the instruction
output reg [2:0] funct3_branch,        // signal to ALU for doing respective branch operation 
output reg mem_read,                   //signal to the secondary memory on whether to read memory (used for load)
output reg mem_write,                 //signal to the secondary memory on whether to write to memory (used for store)
output reg [1:0] wb_ctrl            // signal to control writeback to the reg_bank
);

reg [2:0] instr_type;                    // A variable which stores the instr_type of instruction format
reg [4:0] opcode;                  // Primary opcode field used to classify instruction format
reg [2:0] funct3;                  // Function fields used with primary opcode to find the exact instruction
reg [6:0] funct7;                  // Function fields used with primary opcode to find the exact instruction

//encoding the instruction formats for better readability

localparam R_format=3'b000;        
localparam I_format=3'b001;
localparam S_format=3'b010;
localparam B_format=3'b011;
localparam U_format=3'b100;
localparam J_format=3'b101;
localparam UNSPECIFIED=3'b110;
localparam Invalid=3'b111;

always @(*)begin

//fixed decoding of the instructions regardless of their format

rs1=instr[19:15];      
rs2=instr[24:20];
rd=instr[11:7];
funct3=instr[14:12];
funct7=instr[31:25];
opcode=instr[6:2]; //the 2 LSB of instructions in the base ISA + all ISA extensions except C (compressed) instr_type is "11" making them redundant so they are ignored in comparassions

funct3_mem=funct3;            // for secondary memory

funct3_branch= funct3;       // for ALU

//initializing all the signals to avoid latches
reg_write=0;
alu_mode=5'b00000;
alu_src_A=0;
alu_src_B=0;
mem_read=0;
mem_write=0;
jalr=0;
jal=0;
branch=0;
wb_ctrl=2'b00;
instr_format=UNSPECIFIED;

//classifying the instruction based on their main opcode  (excluding funct3,funct7)

if(instr[1:0] != 2'b11)begin

    instr_type=Invalid;
end

else if(opcode == 5'b01100)begin                                                                                   //R_format

    instr_type=R_format;
end


else if((opcode == 5'b00100)||(opcode == 5'b00000)||(opcode == 5'b11100)||(opcode == 5'b11001))begin        //I_format

    instr_type=I_format;
end


else if(opcode == 5'b01000)begin                                                                                //S_format

    instr_type=S_format;
end


else if(opcode == 5'b11000)begin                                                                                //B_format

    instr_type=B_format;
end


else if((opcode == 5'b01101)||(opcode == 5'b00101))begin                                                       //U_format

    instr_type=U_format;
end


else if(opcode == 5'b11011)begin                                                                                //J_format

    instr_type=J_format;
end


else begin

    instr_type=UNSPECIFIED;                                                                                          // For Invalid opcode
end



instr_format=instr_type;                                 // Input signal to Immediate_generator 



//Signal generation based on each instruction

case (instr_type)

 R_format: begin       // for arthimethic instructions

    reg_write = 1;   // rd is written
    // wb_ctrl will be 0 for this as ALU_out is only being written to the reg_bank
    
    case (funct7)             //proper hierarchcy of opcode->funct3->funct7 wasnt followed
        7'b0000000:begin

            if(funct3 == 3'b000) begin     // ADD Instruction

               alu_mode = 5'b00000;
            end
            else if(funct3 == 3'b100)begin // XOR  Instruction

                alu_mode = 5'b00010;
            end
            else if(funct3 == 3'b110)begin // OR Instruction

                alu_mode = 5'b00011;
            end
            else if(funct3 == 3'b111)begin  // AND Instruction

                alu_mode = 5'b00100;
            end
            else if(funct3 == 3'b001)begin  // SLL Instruction

                alu_mode = 5'b00101;
            end
            else if(funct3 == 3'b101)begin  // SRL Instruction

                alu_mode = 5'b00110;
            end
            else if(funct3 == 3'b010)begin  // SLT Instruction

                alu_mode = 5'b01000;
            end
            else if(funct3 == 3'b011)begin  // SLTU Instruction

                alu_mode = 5'b01001;      
            end

        end     


        7'b0100000:begin

            if(funct3 == 3'b000)begin       // SUB Instruction

                alu_mode = 5'b00001;       
            end
            else if(funct3 == 3'b101)begin  // SRA Instruction

                alu_mode = 5'b00111;
            end

        end
        
        7'b0000001:begin
            // M EXTENSION WILL BE IMPLEMENTED LATER
        end

    default:begin

        reg_write=1'b0;
    end

    endcase
 end      // end of R-format


 I_format:begin
    
     //common initialization
        reg_write = 1;         // so we can write to the registers
        alu_src_B = 1;      //makes the mux select the immediate instead of ro2 as input to B of ALU
          
    case (opcode)       //we are again splitting the I_format into 4 different case statements because I_format has 4 different opcodes within itself

        5'b00100:begin    // For arthimethic I_format instructions

        
            case (funct3)        //once we know the opcode we only need funct3 to find the specific instruction being called

                000: begin
                    alu_mode=5'b00000;           // ADDI Instruction 
                end
                001:begin
                    alu_mode=5'b00101;           // SLLI Instruction  
                end
                 010:begin
                    alu_mode=5'b01000;           // SLTI Instruction
                end
                011:begin
                    alu_mode=5'b01001;           // SLTI (unsigned) instruction
                end
                100:begin
                    alu_mode=5'b00010;           // XORI Instruction
                end

                101:begin
                    // funct3 = 101 is shared by 2 instructions SRAI,SRLI, to distuinguish b/w them we use the immediate [11:5] which is nothing but inst [31:25] 
                    if (instr[31:25] == 7'b0000000) begin

                        alu_mode=5'b00110;       // SRLI Instruction
 
                    end
                    else if(instr[31:25]  == 7'b0100000)begin

                        alu_mode=5'b00111;       // SRAI Instruction

                    end
                    
                end

                110:begin

                    alu_mode=5'b00011;           // ORI Instruction

                end
                111:begin

                    alu_mode=5'b00100;           // ANDI Instruction

                end

                default: ; //default is not needed as it is not possible to get a invalid funct3 and all cases have been covered (000-111)
            endcase
        end 

        5'b00000:begin  // for load instructions
            
            mem_read = 1;          // in load operations we will be writing to the registers
            mem_write = 0;          // in load operations we wont be writing to the memory
            alu_mode = 5'b00000;   //for choosing the add operation
            wb_ctrl = 2'b01;       //for choosing read_memory as writeback to the register bank

        end
        
        5'b11001:begin   // for jalr instruction
        
        wb_ctrl = 2'b10;        // for selecting rd = PC+4
        jalr=1;     // for selecting PC =  (ro1 + immediate) & ~1 f

        end

        5'b11100:begin  // ecall & ebreak instructions
        // ecall & ebreak instruction needs to be implemented 
        end
        default: ;           //default is not needed as it is not possible to get a invalid opcode

    endcase
 end
 S_format:begin            // for store instructions

        mem_read = 0;          // in store operations we wont be writing to the registers
        mem_write = 1;          // in store operations we will be writing to the memory
        reg_write = 0;         // as store operation doesnt need to write to registers
        alu_mode = 5'b00000;   //for choosing the add operation
        alu_src_A = 0;         //for choosing ro1 as input A for the alu
        alu_src_B = 1;         //for choosing Immediate as input B For the alu
        wb_ctrl = 2'b00;       // doesnt matter what wb_ctrl is because reg_write is set to 0
 end

 B_format:begin                  // for branching instructions

        reg_write = 0;             // no write operation is needed for branching instructions
        branch = 1;                // for doing the branch comparisions inside the ALU
        alu_src_A = 0;             // for choosing ro1
        alu_src_B = 0;             // for choosing ro2
 end

 J_format:begin           // for the jump (jal) instruction

        reg_write = 1;        // for writing to rd
        wb_ctrl = 2'b10;      // for selecting rd=PC+4
        jal=1;     // for selecting PC = PC + Imm
 end

 U_format:begin              // for the lui & auipc instructions

        reg_write = 1;             // for writing to a register
      
    case (opcode)

        01101: begin

         wb_ctrl = 2'b11;         // for choosing writeback as immediate  (here the immediate generator already creates a 12 bit shift in the immediate so we just pass the value to the rd from writeback mux)
        end

        00101: begin

         alu_src_A = 1;   // for choosing A as PC
         alu_src_B = 1;   // for choosing  B as imm (imm is already shifted by 12)
         alu_mode = 5'b00000; // for add instruction
        end

        default: ;
    endcase
        
 end
 endcase

end               // END Of the always block


endmodule