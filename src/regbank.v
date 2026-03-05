module bank (
    input clk,                      //clock
    input reg_write,                //signal from decoder which tells whether to write the output of alu to the register or not
    input [4:0] rs1,rs2,rd,        //bits_sequences we are getting from decoder
    input [31:0]write_back,          //output data from the alu which being wroteback to the register
    output reg [31:0] ro1,ro2     //registers being used as inputs in ALU
);

reg [31:0] X[31:0];              //making 32 registers which are 32 bits wide each (named X)

 
//Register reads are combinational,writes are sequential aka clocked
always@(*)begin

if (rs1==0)begin

    ro1=0;                      //if rs1=0 then the output is just going to be zero because the register X[0] is hardwired to zero

end 

else begin

ro1=X[rs1];                     //if rs1!=0 then the output is going to take whatever value is there in the X[rs1] register 

end

if (rs2==0) begin

    ro2=0;                //if rs2=0 then the output is just going to be zero because the register X[0] is hardwired to zero

end

else begin

    ro2=X[rs2];           //if rs2!=0 then the output is going to take whatever value is there in the X[rs2] register 

end

end

always@(posedge clk)begin   
    
    X[0]<=0;             //Hardwiring x0 to zero 
if(reg_write && rd!=0)begin  //writing the value only when reg_write is hight and rd!=0

   X[rd]<=write_back; //assigning the ALU output to the destination register

end
end

endmodule