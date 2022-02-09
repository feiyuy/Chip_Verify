// This is the base transaction object that will be used
// in the environment to initiate new transactions and
// capture transactions at DUT interface

class switch_item;
    rand    bit [7:0]       addr;
    rand    bit [15:0]      data;
    bit         [7:0]       addr_a;
    bit         [15:0]      data_a;
    bit         [7:0]       addr_b;
    bit         [15:0]      data_b;

    // This function allows us to print contents of the data
  	// packet so that it is easier to track in a logfile
    function void print(string tag="");
        $desplay ("T = %0t %s\naddr = 0x%0h data = 0x%0h\naddr_a = 0x%0h data_a = 0x%0h\naddr_b = 0x%0h data_b = 0x%0h",
                    $time, tag, addr, data, addr_a, data_a, addr_b, data_b);

    endfunction
endclass

// The generator class is used to generate a random
// number of transactions with random addresses and data
// that can be driven to the design

class generator;
    mailbox     drv_mbx;
    event       drv_done;
    int         num     =   20;

    task run();
        for (int i = 0; i < num; i++) begin
            switch_item item    =   new;
            item.randomize();
            $display ("T = %0t [Generator] Loop: %0d/%0d create next item", $time, i+1, num);
            drv_mbx.put(item);
            @(drv_done);
        end
        $display ("T = %0t [Generator] Done generation of %0d items", $time, num);
    endtask
endclass

// The driver is responsible for driving transactions to the DUT
// All it does is to get a transaction from the mailbox if it is
// available and drive it out into the DUT interface.

class driver;
    virtual     switch_if   vif;
    event       drv_done;
    mailbox     drv_mbx;

    task run();
        $display ("T = %0t [Driver] starting ...", $time);
        @(posedge vif.clk);

        // Try to get a new transaction every time and then assign
        // packet contents to the interface. But do this only if the
        // design is ready to accept new transactions
        forever begin
            switch_item     item;

            $display ("T = %0t [Driver] waiting for item ...", $time);
            drv_mbx.get(item);
            item.print("Driver");
            vif.vld         <=  1;
            vif.addr        <=  item.addr;
            vif.data        <=  item.data;

            // When transfer is over, raise the done event
            @(posedge vif.clk);
            vif.vld         <=  0;
            ->drv_done;
        end
    endtask
endclass

// The monitor has a virtual interface handle with which
// it can monitor the events happening on the interface.
// It sees new transactions and then captures information
// into a packet and sends it to the scoreboard
// using another mailbox.

class monitor;
    virtual     switch_if   vif;
    mailbox     scb_mbx;
    semaphore   sema4;

    function new();
        sema4   =   new(1);
    endfunction

    task run();
        $display ("T = %0t [Monitor] starting ...", $time);

        // To get a pipeline effect of transfers, fork two threads
        // where each thread uses a semaphore for the address phase
        fork
            sample_port("Thread0");
            sample_port("Thread1");
        join
    endtask

    task sample_port(string tag="");
    // This task monitors the interface for a complete
    // transaction and pushes into the mailbox when the
    // transaction is complete
        forever begin
            @(posedge vif.clk);
            if (vif.rst_n & vif.valid) begin
                switch_item item    =   new;
                sema4.get();
                item.addr           =   vif.addr;
                item.data           =   vif.data;
                $display("T = %0t [Monitor] %s Fiest part over", $time, tag);
                
                @(posedge vif.clk);
                sema4.put();
                item.addr_a         =   vif.addr_a;
                item.data_a         =   vif.data_a;
                item.addr_b         =   vif.addr_b;
                item.data_b         =   vif.data_b;
                $display("T = %0t [Monitor] %s Second part over", $time, tag);

                scb_mbx.put(item);
                item.print({"Monitor_", tag});
            end
        end
    endtask
endclass

// The scoreboard is responsible to check data integrity. Since
// the design routes packets based on an address range, the
// scoreboard checks that the packet's address is within valid
// range.
class scoreboard;
    mailbox     scb_mbx;

    task run();
        forever begin
            switch_item     item;
            scb_mbx.get(item);

            if (item.addr inside {[0:'h3f]}) begin
                if (item.addr_a != item.addr || item.data_a != item.data)
                    $display ("T=%0t [Scoreboard] ERROR! Mismatch addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h", $time, item.addr, item.data, item.addr_a, item.data_a);
                else
                    $display ("T=%0t [Scoreboard] PASS! Mismatch addr=0x%0h data=0x%0h addr_a=0x%0h data_a=0x%0h", $time, item.addr, item.data, item.addr_a, item.data_a);
            end
            else begin
                if (item.addr_b != item.addr | item.data_b != item.data)
                    $display ("T=%0t [Scoreboard] ERROR! Mismatch addr=0x%0h data=0x%0h addr_b=0x%0h data_b=0x%0h", $time, item.addr, item.data, item.addr_b, item.data_b);
                else
                    $display ("T=%0t [Scoreboard] PASS! Mismatch addr=0x%0h data=0x%0h addr_b=0x%0h data_b=0x%0h", $time, item.addr, item.data, item.addr_b, item.data_b);
            end
        end
    endtask
endclass

// The environment is a container object simply to hold
// all verification  components together. This environment can
// then be reused later and all components in it would be
// automatically connected and available for use
class env;
    driver          d0;
    monitor         m0;
    generator       g0;
    scoreboard      s0;

    mailbox         drv_mbx;
    mailbox         scb_mbx;
    event           drv_done;

    virtual         switch_if   vif;

    function new();
        d0      =   new;
        m0      =   new;
        g0      =   new;
        s0      =   new;
        drv_mbx =   new();
        scb_mbx =   new();

        d0.drv_mbx  =   drv_mbx;
        g0.drv_mbx  =   drv_mbx;
        m0.scb_mbx  =   scb_mbx;
        s0.scb_mbx  =   scb_mbx;

        d0.drv_done =   drv_done;
        g0.drv_done =   drv_done;
    endfunction

    virtual task run();
        d0.vif  =   vif;
        m9.vif  =   vif;

        fork  
            d0.run();
            m0.run();
            g0.run();
            s0.run();
        join_any
    endtask
endclass

// Test class instantiates the environment and starts it.
class test;
    env     e0;

    function new();
        e0  =   new;
    endfunction

    task run();
        e0.run();
    endtask
endclass

// Design interface used to monitor activity and capture/drive
// transactions
interface switch_if
(
    input   bit     clk
);
    logic           rst_n;

    logic           valid;
    logic   [7:0]   addr;
    logic   [15:0]  data;

    logic   [7:0]   addr_a;
    logic   [15:0]  data_a;

    logic   [7:0]   addr_b;
    logic   [15:0]  data_b;
endinterface
