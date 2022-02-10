module tb;
    string      dialog      =   "Hello!";

    initial begin
        // Display the string using %s string format
        $display ("%s", dialog);

        // Iterate through the string variable to identify 
        //individual characters and print
        foreach (dialog[i]) begin
            $display("%s", dialog[i]);
        end
    end
endmodule

//A single ASCII character requires 8-bits (1 byte) and to 
//store a string we would need as many bytes as there are 
//number of characters in the string.

module tb;
    string      firstname   =   "Joey";
    string      lastname    =   "Tribbani";
    
    initial begin
        // String Equality : Check if firstname equals or not equals lastname
        if (firstname == lastname)
            $display ("firstname %s is EQUAL to lastname %s", firstname, lastname);

        if (firstname != lastname)
            $display ("firstname %s is NOT EQUAL to lastname %s", firstname, lastname);

        // String comparison : Check if length of firstname < or > length of lastname
        if (firstname < lastname)
            $display ("firstname %s is LESS THAN lastname %s", firstname, lastname); 
            
        if (firstname > lastname)
            $display ("firstname %s is GREATER THAN lastname %s", firstname, lastname);

        // String concatenation : Join first and last names into a single string
        $display ("Full name is %s", {firstname, " ", lastname});

        // String Replication
        $display ("%s", {3{firstname}});

        // String Indexing : Get the ASCII character at index number 2 of both first and last names
            $display ("firstname[2]=%s lastname[2]=%s", firstname[2], lastname[2]);
    end
endmodule

module tb;
    string      str     =   "Hello World!";

    initial begin
        string  tmp;

        // Print length of string "str"
        $display ("str.len() = %0d", str.len());

        // Assign to tmp variable and put char "d" at index 3
        tmp = str;
        tmp.putc (3,"d");
        $display ("str.putc(3, d) = %s", tmp);

        // Get the character at index 2
        $display ("str.getc(2) = %s (%0d)", str.getc(2), str.getc(2));

        // Convert all characters to lower case
        $display ("str.tolower() = %s", str.tolower());

        // Comparison
        tmp = "Hello World!";
        $display ("[tmp,str are same] str.compare(tmp) = %0d", str.compare(tmp));
        tmp = "How are you ?";
        $display ("[tmp,str are diff] str.compare(tmp) = %0d", str.compare(tmp));

        // Ignore case comparison
        tmp = "hello world!";
        $display ("[tmp is in lowercase] str.compare(tmp) = %0d", str.compare(tmp));
        tmp = "Hello World!";
        $display ("[tmp,str are same] str.compare(tmp) = %0d", str.compare(tmp));

        // Extract new string from i to j
        $display ("str.substr(4,8) = %s", str.substr (4,8));

   end
endmodule