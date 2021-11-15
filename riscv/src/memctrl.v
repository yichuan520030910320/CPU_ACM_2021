`include "C:\Users\18303\Desktop\cpu\CPU_ACM_2021\riscv\src\define.v"
module memctrl (   
    input   wire    clk_in,
    input   wire    rst_in,
    input  wire     rdy_in, 
    //to mem and if 
    output  reg[1:0] mem_ctrl_busy_state,//[1] stand for the state of the if [0]stand for the state of the mem
    //to mem
    output reg mem_load_done,   
    output reg[31:0] mem_ctrl_load_to_mem,
    //from mem 
    input wire  read_mem,
    input wire write_mem,
    input  wire[31:0] mem_addr,
    input wire[31:0] mem_data_to_write,
    input  wire[2:0] data_len,
    //to if
    output reg if_load_done,
    output reg[31:0] mem_ctrl_instru_to_if,
    //from if
    input wire if_read_or_not,  
    input  wire[31:0] intru_addr,
    //from ram
    input wire  [7:0]           d_in    , // data input
    //to ram
    output  wire                   r_or_w,  // read/write select (read: 1, write: 0)
    output  wire[15:0]             a_out,     // memory address
    output  wire[7:0]              d_out     // data output    
);
//define
reg[31:0] preaddr;
reg[1:0] mem_read_cnt;
reg[1:0] mem_write_cnt;
reg[1:0] if_read_cnt;
reg[31:0] mem_read_data;
reg[31:0] if_read_instru;

//initial
initial begin
    preaddr=0;
    mem_read_cnt=0;
    mem_write_cnt=0;
    if_read_cnt=0;
    mem_read_data=0;
    if_read_instru=0;
end

//initial select ram addr
wire[31:0] nowaddr=(read_mem||write_mem) ? mem_addr:intru_addr;

//select the correct counter
wire[2:0] select_cnt=(!read_mem)?(write_mem ? mem_write_cnt :if_read_cnt):(mem_read_cnt);

//select the read or write state
assign r_or_w=(!read_mem)?(write_mem ? 0 :1):(1);

//assign the addr to ram eventually
assign a_out=nowaddr+select_cnt;

//selcet the data to write 
wire[7:0] val[0:3];
assign val[0]=mem_data_to_write[7:0];
assign val[1]=mem_data_to_write[15:8];
assign val[2]=mem_data_to_write[23:16];
assign val[3]=mem_data_to_write[31:24];
assign d_out=val[mem_write_cnt];

always @(posedge clk_in) begin
    if(rst_in==1) begin
        mem_load_done<=0;
        mem_ctrl_instru_to_if<=0;
        mem_ctrl_busy_state<=0;
        if_load_done<=0;
        mem_ctrl_instru_to_if<=0;
    end
    else 
    begin
        if (rdy_in==1) begin
            if (read_mem==1) begin
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b01;
                mem_load_done<=0;
                mem_ctrl_load_to_mem<=0;
                case (mem_read_cnt)
                    1:begin
                        mem_read_data[7:0]=d_in;                       
                    end
                    2:begin
                        mem_read_data[15:8]=d_in;                        
                    end
                    3:begin
                        mem_read_data[23:16]=d_in;                        
                    end
                    4: begin
                        mem_read_data[31:24]=d_in;                       
                    end
                    default: begin                       
                    end
                endcase
                if (mem_read_cnt==data_len) begin
                    mem_ctrl_busy_state<=0;
                    mem_load_done<=1;
                    mem_read_cnt<=0;
                    mem_ctrl_busy_state<=2'b00;
                    mem_ctrl_load_to_mem<=mem_read_data;
                end else
                    begin
                        mem_read_cnt<=mem_read_cnt+1;                       
                    end                
            end else if(write_mem==1)begin
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b01;
                mem_load_done<=0;
                if (mem_write_cnt==data_len) begin
                    mem_ctrl_busy_state<=0;
                    mem_load_done<=1;
                    mem_write_cnt<=0;
                    mem_ctrl_busy_state<=2'b00;
                    
                end else
                    begin
                        mem_write_cnt<=mem_read_cnt+1;                       
                    end                   
            end else if(if_read_or_not==1)begin
                if (preaddr!=intru_addr) begin
                    if_read_cnt<=0;
                end
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b10;
                if_load_done<=0;
                mem_load_done<=0;
                mem_ctrl_load_to_mem<=0;
                case (if_read_cnt)
                    1:begin
                        if_read_instru[7:0]=d_in;                       
                    end
                    2:begin
                        if_read_instru[15:8]=d_in;                        
                    end
                    3:begin
                        if_read_instru[23:16]=d_in;                        
                    end
                    4: begin
                        if_read_instru[31:24]=d_in;                       
                    end
                    default: begin
                        
                    end
                endcase
                if (if_read_cnt==4) begin
                    if_load_done<=1;
                    mem_ctrl_busy_state<=0;
                    if_read_cnt<=0;
                    mem_ctrl_instru_to_if<=if_read_instru;
                    preaddr<=0;
                end else
                    begin
                        if_read_cnt<=if_read_cnt+1;
                        preaddr<=intru_addr;                                         
                    end                
            end else 
            begin
            end
        end
    end
end
endmodule //memctrl