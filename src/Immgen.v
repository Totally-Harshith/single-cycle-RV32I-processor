module immgen (
    input [31:0] instr,                 // Instruction from Instruction memory
    input [2:0]  instr_format,          // Input from decoder
    output reg [31:0] immediate         // 32 bit immediate being generated
);

// Instruction type encoding
localparam R_format = 3'b000;        
localparam I_format = 3'b001;
localparam S_format = 3'b010;
localparam B_format = 3'b011;
localparam U_format = 3'b100;
localparam J_format = 3'b101;

always @(*)begin

// initializing
    immediate=32'b0;        

    case (instr_format)                                  //immediate encoding based on the format specification

    // R_Format and other invalid will be handled by the default case

    I_format:begin

        immediate = {{20{instr[31]}},instr[31:20]};       // sign_extending the immediate and following I_type format

    end

    S_format:begin

        immediate = {{20{instr[31]}},instr[31:25],instr[11:7]};      // sign_extending the immediate and following S_type format
    end

    B_format:begin

        immediate = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};       // sign_extending the immediate and following B_type format

    end

    U_format:begin

        immediate ={instr[31:12],{12{1'b0}}};                             // Following U_type format and adding 0 at the end

    end

    J_format:begin

        immediate= {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};      // sign_extending the immediate and following J_type format

    end


        default: immediate=32'b0;

    endcase
end

    
endmodule