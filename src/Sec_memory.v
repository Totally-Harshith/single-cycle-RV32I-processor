module sec_memory (
    input clk,                                       // clock
    input [31:0] address,                            // ALU_OUT (rs1+imm)
    input mem_read,                                  // signal from the decoder for load instructions
    input mem_write,                                 // signal from the decoder for store instructions
    input [31:0] write_data,                         // input from the register bank (ro2)
    input [2:0] funct3_mem,                          // input from decoder for finding the exact instruction
    output reg [31:0]read_data                       // memory being loaded into the destination register which is input to the writeback mux
);

reg [31:0] memory [1023:0];    // 4 Kilo bytes of memorywire
wire [1:0] byte_offset;         // for finding the byte,half word required
wire [9:0] word_offset;         // for finding the memory element needed as the ISA specifies byte addressing but we are using word memory


initial begin                     //only being used for initialising the memory before execution time,no signals are being passed

    $readmemb("memory.b",memory);

end

assign word_offset = address[11:2];
assign byte_offset = address[1:0];


always @(posedge clk) begin        // keeping writes clocked


if(mem_write)begin  // for store instructions

    case(funct3_mem)
     
    3'b000:begin              // for sb

    case(byte_offset)                                     //based on the byte_offset we assign the appropriate memory byte to  the writedata (ro2)
                                           
    2'b00:begin

        memory[word_offset][7:0] <= write_data[7:0];                    

    end

     2'b01:begin

        memory[word_offset][15:8] <= write_data[7:0]; 
       
    end

     2'b10:begin

        memory[word_offset][23:16] <= write_data[7:0]; 

    end

     2'b11:begin

        memory[word_offset][31:24] <= write_data[7:0]; 

    end

    default: ;

    endcase

    end

    3'b001:begin             // for sh
                                                                                  
     if(address[1])begin                   //based on the address we assign the appropriate memory halfword to the writedata (ro2)         

        memory[word_offset][31:16] <= write_data[15:0];           // for storing a half word

    end

    else begin

    memory[word_offset][15:0] <= write_data[15:0];        //for storing a half word

    end

    end

    3'b010:begin             // for sw

    memory[word_offset] <= write_data;              

    end
    
    default: ;

    endcase

end

end


always@(*)begin                 // Reads are combinational
 
 read_data = 0;

if(mem_read)begin   // for load instructions

    case(funct3_mem)
    
    3'b000:begin              // for lb

    case(byte_offset)

    2'b00:begin

        read_data = {{24{memory[word_offset][7]}},memory[word_offset][7:0]};            // sign-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

     2'b01:begin

        read_data = {{24{memory[word_offset][15]}},memory[word_offset][15:8]};            // sign-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    2'b10:begin

        read_data = {{24{memory[word_offset][23]}},memory[word_offset][23:16]};            // sign-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    2'b11:begin

        read_data = {{24{memory[word_offset][31]}},memory[word_offset][31:24]};            // sign-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    default: ;

    endcase
 

    end

    3'b001:begin             // for lh
    
    if(address[1])begin

        read_data = {{16{memory[word_offset][31]}},memory[word_offset][31:16]};            // sign-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    else begin

        read_data = {{16{memory[word_offset][15]}},memory[word_offset][15:0]};            // sign-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    end

    3'b010:begin             // for lw

    read_data = memory[word_offset];                 //loading read data with the appropriate word_offset

    end

    3'b100:begin             // for lbu
    case(byte_offset)

    2'b00:begin

        read_data = {24'b0,memory[word_offset][7:0]};            // zero-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    2'b01:begin

        read_data = {24'b0,memory[word_offset][15:8]};            // zero-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    2'b10:begin

        read_data = {24'b0,memory[word_offset][23:16]};            // zero-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    2'b11:begin

        read_data = {24'b0,memory[word_offset][31:24]};            // zero-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    default: ;

    endcase
 

    end

    3'b101:begin             // for lhu
  
    if(address[1])begin

        read_data = {16'b0,memory[word_offset][31:16]};            // zero-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    else begin

        read_data = {16'b0,memory[word_offset][15:0]};            // zero-extending and choosing the correct byte using byte_offset (explained in documentation)

    end

    end

    default:read_data=0;                                    //default case

    endcase

end

else begin

    read_data=32'b0;                           // default case

end

end
 
    
endmodule
