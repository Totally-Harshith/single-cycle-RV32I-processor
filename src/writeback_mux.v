module wb_mux (
    input [31:0] alu_out,pc_default,read_data,immediate,     // Inputs to the MUX 
    input [1:0] wb_ctrl,                       // select/control signal from decoder
    output reg [31:0] write_back               // Input to the register_bank
);

always@(*)begin

    case (wb_ctrl)

    2'b00:begin

        write_back = alu_out;

    end
    
      2'b01:begin

        write_back = read_data;

    end

      2'b10:begin

        write_back = pc_default;

    end

     2'b11:begin

        write_back = immediate;

     end

    default: write_back=0;       
    endcase

end
    
endmodule