module tb;
    shortint    unsigned        var_a;
    int         unsigned        var_b;
    longint     unsigned        var_c;

    initial begin
        // Print initial values of the integer variables
        $display ("Size var_a = %0d var_b = %0d, var_c = %0d", $bits(var_a), $bits(var_b), $bits(var_c));

        // Assign the maximum value for each of the variables
        #1
        var_a   =   'hFFFF;
        var_b   =   'hFFFF_FFFF;
        var_c   =   'hFFFF_FFFF_FFFF_FFFF;

        // When added a 1, value rolls over to 0
        #1
        var_a   +=  1;
        var_b   +=  1;
        var_c   +=  1;
    end

    // Start a monitor to print out values of each variables as they change
    initial
        $monitor ("var_a=%0d var_b=%0d var_c=%0d", var_a, var_b, var_c);
endmodule
