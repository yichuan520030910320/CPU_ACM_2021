


module BTB_BHT #(

parameter BTB_BHT_LOG_SIZE   = 5,
parameter BTB_BHT_SIZE =32

)(
    input  wire     clk_in,
    input  wire     rst_in,
    input  wire     rdy_in, 

    //from ex
input wire if_the_instru_is_br,
    input wire[31:0] ex_pc,
    input wire[31:0] ex_target_pc,
    input wire ex_isbr,
    //to ex
    output  reg[31:0] predict_pc,
    //from pc
    input  wire     [31:0] pc,
    //to pc
    output reg branch_or_not_btb,
    output reg [31:0] pc_dest_btb


);
//[33]valid [32:15]addr [14:2]tag [1:0]predictor

integer  i;
reg flush;
reg [33:0]bht_btb [0:31];
always @(posedge clk_in)begin
    if (rst_in==0) begin
        //if the entry is invalid
        if (ex_isbr==1&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][33]==0) begin
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][14:2]=ex_pc[17:5];
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][33]=1;
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][32:15]=ex_target_pc[17:0];            
        end
        //if the entry is valid but the tag don't match
        else if (ex_isbr==1&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][33]==1&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][14:2]!=ex_pc[17:5]) begin
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][14:2]=ex_pc[17:5];
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][32:15]=ex_target_pc[17:0];          
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][0]=1;
        end

        //if the tag match
        else if (ex_isbr==1&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][33]==1&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][14:2]==ex_pc[17:5]) begin
            
            
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][32:15]=ex_target_pc[17:0];  
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][0]=1;          
        end
        //if the tag match and but it don't jump but it is predicted to be jump
        else if (ex_isbr==0&&if_the_instru_is_br&&flush==1&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][33]==1&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][14:2]==ex_pc[17:5])begin
            bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][1:0]=0;

            
        end
    end    
    else 
    begin
        flush<=1;
        for (i=0; i<32;i=i+1) bht_btb[i]<=0;
        end
    
end

always @(*) begin
    pc_dest_btb=0;
    branch_or_not_btb=0;
    if (bht_btb[pc[BTB_BHT_LOG_SIZE-1:0]][14:2]==pc[17:5]&&bht_btb[pc[BTB_BHT_LOG_SIZE-1:0]][33]==1) begin
        if (bht_btb[pc[BTB_BHT_LOG_SIZE-1:0]][1:0]>0) begin
        pc_dest_btb={14'h0,bht_btb[pc[BTB_BHT_LOG_SIZE-1:0]][32:15]};
        branch_or_not_btb=1;
        end
    end
end


always @(*) begin
    predict_pc=0;
    
    if (bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][14:2]==ex_pc[17:5]&&bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][33]==1) begin
        if (bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][1:0]>0) begin
            predict_pc={14'h0,bht_btb[ex_pc[BTB_BHT_LOG_SIZE-1:0]][32:15]};
        end
    end
end
endmodule