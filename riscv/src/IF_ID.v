
module IF_ID (
    input  wire                 clk_in,
    input wire rst_in,
    input  wire     rdy_in, 
    //from stall ctrl
    input  wire[5:0] stall_in,
    //from ex
    input  wire branch_or_not,

    //from if
    input wire [31:0] input_pc,
    input  wire[31:0] input_instru,
    //to id
    output reg[31:0] output_pc,
    output reg[31:0] output_instru 
);
reg [31:0] preinstruction_record;
always @(posedge clk_in ) begin
    if (rst_in==0) begin
        if (rdy_in==1) begin
            
        
        if (branch_or_not==1) begin
            output_pc<=0;
            output_instru<=0; 
        end
        else if (stall_in[1]==1&&stall_in[2]==0) begin
            output_pc<=0;
            output_instru<=0;
        end else if(stall_in[1]==0) begin
            output_pc <=input_pc;
            output_instru<=input_instru;
            if (input_instru==0) begin
                output_instru<=preinstruction_record;   
            end
        end  else
            begin
                if (input_instru!=0) begin
                preinstruction_record<=input_instru;    
            end

            end
        //otherwise the Sequential circuit contain the original state     
    end
    end
    else
        begin
            output_pc<=0;
            output_instru<=0;
            preinstruction_record=0;
        end
end
endmodule //IF_ID