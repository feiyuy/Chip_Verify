typedef struct {
    int     coins;
    real    dollars;
} s_money;

s_money wallet;

wallet = '{5, 19.75};
wallet = '{coins: 5, dollars: 19.75};
wallet = '{default: 0};
wallet = s_money'{int: 1, dollars: 2};

struct {
    int A, B, C;
} ABC = '{3{1}};

s_money purse[1:0] = '{'{2, 4.25}, '{7, 1.5}};

struct {
    string  fruit;
    int     count;
    byte    expiry;
} st_fruit;

st_fruit.fruit  =   "pineapple";
st_fruit.expiry =   7;

//A packed structure is a mechanism for subdividing a vector 
//into fields that can be accessed as members and are packed 
//together in memory without gaps. The first member in the 
//structure is the most significant and subsequent members 
//follow in decreasing order of significance.
typedef struct packed{
    bit     [3:0]   mode;
    bit     [2:0]   cfg;
    bit             en;
} st_ctrl;

module tb;
    st_ctrl     ctrl_reg;

    initial begin
        ctrl_reg = '{4'ha, 3'h5, 1};
        $dispaly ("ctrl_reg =%p", ctrl_reg);

        ctrl_reg.mode = 4'h3;
        $dispaly ("ctrl_reg =%p", ctrl_reg);

        ctrl_reg = 8'hfa;
        $dispaly ("ctrl_reg =%p", ctrl_reg);
    end
endmodule