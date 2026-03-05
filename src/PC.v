module pc(
input [31:0] nextPC,             //input from the MUX which is controlled by the Decoder
input clk,                       //clock
input reset,                     //synchronous reset
output reg [31:0] PC             //Programme counter pointing towards the address of the instructions in the instrution memory
);

always@(posedge clk)begin

if(reset) begin
    PC<=0;                       //when reset is high then the PC is being reset 
end

else begin
    PC<=nextPC;                  //As it is a single cycle cpu The PC will be updated with its next value at each rising edge of the clock
end

end

endmodule