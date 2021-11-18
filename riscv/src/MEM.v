`include"/mnt/c/Users/18303/Desktop/cpu/CPU_ACM_2021/riscv/src/define.v"

module MEM (
    input  wire[31:0] storedata_in,
    input  wire rst_in,
    //from ex_mem
    input wire [`RegAddrBus] input_rd_addr,
    input wire [`RegBus] input_rd_data,
    input  wire write_or_not,
    input wire[`Cmd_Typebus] cmdtype, 
    input wire[`Dataaddress] mem_addr,

    //to mem_wb
    output reg [`RegAddrBus] out_rd_addr,
    output reg [`RegBus] out_rd_data,
    output reg out_write_or_not,

    //forward to id
    output  reg mem_forward_id_o,
    output  reg[`RegBus] mem_forward_data_o,
    output  reg[`RegAddrBus] mem_forward_addr_o    ,

    //to stallctrl
    output reg stall_from_mem,

    //from mem ctrl
    input wire mem_load_done,
    input  wire[1:0] mem_ctrl_busy_state,
    input wire[31:0] mem_ctrl_read_in,

    //to mem ctrl
    output reg read_mem,
    output reg write_mem,
    output  reg[31:0] mem_addr_to_read,//in fact this address is both for read and write
    output reg[31:0] mem_data_to_write,
    output  reg[2:0] data_len
);
always @(*)begin
    out_rd_addr=0;
    out_rd_data=0;
    out_write_or_not=`False;
    mem_forward_id_o=`False;
    mem_forward_addr_o=0;
    mem_forward_data_o=0;  
    stall_from_mem=0;
    read_mem=0;
    write_mem=0;
    mem_addr_to_read=0;
    mem_data_to_write=0;
    data_len=0;
    stall_from_mem=0;
    if (rst_in==`RstEnable) begin
        
    end else begin
        
        out_rd_addr=input_rd_addr;
        out_rd_data=input_rd_data;
        out_write_or_not=write_or_not;

        if (mem_load_done==1) begin//mem ctrl finish work both for store and load
            case (cmdtype)
            `CmdLB:
            begin
                out_rd_data={{24{mem_ctrl_read_in[7]}},mem_ctrl_read_in[7:0]};
            end
            `CmdLH:
            begin
                out_rd_data={{16{mem_ctrl_read_in[15]}},mem_ctrl_read_in[15:0]};               
            end 
            `CmdLW:
            begin
                out_rd_data={mem_ctrl_read_in[31:0]};                
            end
            `CmdLBU:
            begin
                out_rd_data={24'b0,mem_ctrl_read_in[7:0]};               
            end
            `CmdLHU:begin
                out_rd_data={16'b0,mem_ctrl_read_in[15:0]};
            end
            default
            begin
                
            end                
            endcase
            stall_from_mem=0;                   
        end else 
        begin
            
            case (cmdtype)
            `CmdLB,`CmdLH, `CmdLW,`CmdLBU,`CmdLHU:
            begin
                
                read_mem=1;
                stall_from_mem=1;
                mem_addr_to_read=mem_addr;
                //$display("read_mem : ",read_mem,"stall ",stall_from_mem);
                case (cmdtype)
                `CmdLB:
                begin
                    data_len=1;
                end
                `CmdLH:
                begin
                    data_len=2;
                end 
                `CmdLW:
                begin
                    data_len=4;
                end
                `CmdLBU:
                begin
                    data_len=1;
                end
                `CmdLHU:begin
                    data_len=2;
                end
                default
                begin
                    
                end                
                endcase 
                if (mem_ctrl_busy_state[1]==1) begin
                    read_mem=0;
                    data_len=0;                   
                end              
            end
            `CmdSB,`CmdSH,`CmdSW:
            begin
                mem_data_to_write=storedata_in;
                write_mem=1;
                stall_from_mem=1;
                mem_addr_to_read=mem_addr;
                //$display("write mem :", write_mem);
                case (cmdtype)
                `CmdSB:
                begin
                    data_len=1;
                end
                `CmdSH:
                begin
                    data_len=2;
                end 
                `CmdSW:
                begin
                    data_len=4;
                end
                default
                begin                    
                end                
                endcase
                if (mem_ctrl_busy_state[1]==1) begin
                    write_mem=0;
                    data_len=0;                   
                end                   
            end          
            default:begin
            end                
            endcase
        end
    end
    if (out_write_or_not==`True) begin
        mem_forward_id_o=`True;
        mem_forward_addr_o=out_rd_addr;
        mem_forward_data_o=out_rd_data;  
    end
end

endmodule //MEM