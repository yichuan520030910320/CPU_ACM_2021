
module pc (
    input  wire     clk_in,
    input  wire     rst_in,
    input  wire     rdy_in, 
    //from stall ctrl
    input  wire[5:0] stall_in,
    //from ex
    input  wire branch_or_not,
    input wire[31:0] branch_addr,
    //to if
    output reg [31:0]    pc_out
    
);

always @(posedge clk_in) begin
    if (!rst_in==1) begin
        if (branch_or_not==1&&rdy_in==1) begin
            pc_out<=branch_addr;
        end
        else if(stall_in[0]==0&&rdy_in==1) begin
            pc_out<=pc_out+4'h4;
        end
        else begin           
        end       
    end
    else
        begin
        pc_out<=0; 
        end
    end
endmodule //pc