module cpu_testbench;

    reg clk;
    reg reset;

    cpu dut (.clk(clk), .reset(reset));

    // Generating the clockpulse
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10;
        reset = 0;
    end

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0,cpu_testbench);
    end




    initial begin

        #100 $finish;

    end


    
endmodule