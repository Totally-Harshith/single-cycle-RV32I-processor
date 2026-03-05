module imem (
    input [31:0] PC,                 //program counter
    output [31:0] instr          //instruction obtained from the instruction file (addressed by PC >> 2)
);

reg [31:0] Imemory [0:255];

initial begin                     //only being used for initialising the memory before execution time,no signals are being passed

    $readmemb("instruction.b",Imemory);

end

assign instr=Imemory[PC[11:2]];
    
endmodule