module stallctrl (
    //from if
    input  wire stall_from_if,
    //from id
    input wire stall_from_id,
    //from ex
    input wire stall_from_ex,
    //from mem
    input wire stall_from_mem,
    //to pc id_id id_ex ex_mem mem_wb
    output reg[5:0] stall//stall[0] stand for pc stop 1stand for stop
);

always @(*) begin
    stall=0;
    if (stall_from_mem==1)begin
        stall=6'b011111;
    end else if (stall_from_ex==1)begin
        stall=6'b001111;
    end else if (stall_from_id==1)begin
        stall=6'b000111;
    end else if (stall_from_if==1)begin
        stall=6'b000011;
    end     
end

endmodule //stallctrl