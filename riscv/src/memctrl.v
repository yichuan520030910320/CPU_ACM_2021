`timescale 1ns/1ps

module memctrl#(
parameter WRITEBUFFERSIZE   = 2,
parameter ICACHE_INDEX_LEN   = 7,
parameter ICACHE_SIZE =128,
parameter DCACHE_SIZE =32,
parameter DCACHE_INDEX_LEN =5
)  (   
    input   wire     io_full,
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
    output  wire                   r_or_w,  // read/write select (read: 0, write: 1)
    output  wire[31:0]             a_out,     // memory address
    output  wire[7:0]              d_out     // data output    
);

//dcache
reg dcache_valid[0:DCACHE_SIZE-1];
reg[31-DCACHE_INDEX_LEN:0] dcache_tag[0:DCACHE_SIZE-1];
reg[DCACHE_INDEX_LEN-1:0] dcache_index[0:DCACHE_SIZE-1];
reg[31:0] dcache_[0:DCACHE_SIZE-1];
reg dchachswicth;

//icache
reg valid[0:ICACHE_SIZE-1];
reg[31-ICACHE_INDEX_LEN:0] tag[0:ICACHE_SIZE-1];
reg[ICACHE_INDEX_LEN-1:0] index[0:ICACHE_SIZE-1];
reg[31:0] icache_[0:ICACHE_SIZE-1];
integer i;
reg ichachswicth;



//write buffer
reg [31:0] write_buffer[0:WRITEBUFFERSIZE-1] ;
reg[WRITEBUFFERSIZE-1:0] buffer_occupied;
reg[31:0] write_buffer_addr[0:WRITEBUFFERSIZE-1] ;


//define
reg[31:0] preaddr;
reg[2:0] mem_read_cnt;
reg[2:0] mem_write_cnt;
reg[2:0] if_read_cnt;
reg[31:0] mem_read_data;
reg[31:0] if_read_instru;
reg[31:0] mem_write_data;
reg[3:0] IO_cnt;
reg IO_switch;
reg[2:0] write_buffer_cnt;
reg old_write_buffer;
reg new_write_buffer;



//check bus if busy 
wire bus_busy=if_read_or_not||read_mem||write_mem;

//initial select ram addr
wire[31:0] nowaddr=(read_mem||write_mem) ? mem_addr:intru_addr;

//select the correct counter
wire[2:0] select_cnt=(!read_mem)?(write_mem ? mem_write_cnt :if_read_cnt):(mem_read_cnt);

//select the read or write state
assign r_or_w=
(!bus_busy)&&(!buffer_occupied==0)?1:
    (write_mem==1&&(mem_addr==32'h00030000||mem_addr==32'h00030004)&&((io_full==1)))?0:
        (buffer_occupied!=3&&(!(mem_addr==32'h00030000||mem_addr==32'h00030004)))?0:write_mem;//0 stand for read if don't write then we read
//assign r_or_w=write_mem;//0 stand for read if don't write then we read

//assign the addr to ram eventually


// assign a_out=(mem_addr==32'h00030000&&(IO_cnt==2||(IO_cnt==1&&io_full==1)))||
// (if_read_or_not==0&&((if_read_cnt>3)||(valid[intru_addr[ICACHE_INDEX_LEN-1:0]]==1&&tag[intru_addr[ICACHE_INDEX_LEN-1:0]]==intru_addr[31:ICACHE_INDEX_LEN])))
// ||(read_mem==1&&(mem_read_cnt>=data_len||dcache_valid[mem_addr[DCACHE_INDEX_LEN-1:0]]==1&&dcache_tag[mem_addr[DCACHE_INDEX_LEN-1:0]]==mem_addr[31:DCACHE_INDEX_LEN]))
// ?0:nowaddr+select_cnt;
wire [4:0]write_buffer_to_write_num;
assign write_buffer_to_write_num=
                                        buffer_occupied[!new_write_buffer]==1?!new_write_buffer:new_write_buffer;
assign a_out=
(!bus_busy)&&(!buffer_occupied==0)?write_buffer_addr[write_buffer_to_write_num]+write_buffer_cnt:
                            (write_mem==1&&(mem_addr==32'h00030000||mem_addr==32'h00030004)&&(io_full==1))?0:nowaddr+select_cnt;


//Read Priority over Write on Miss
wire [4:0]read_write_buffer_num;
assign read_write_buffer_num=(buffer_occupied[new_write_buffer]==1&&write_buffer_addr[new_write_buffer]==mem_addr)?new_write_buffer:
                                (buffer_occupied[!new_write_buffer]==1&&write_buffer_addr[!new_write_buffer]==mem_addr)?!new_write_buffer:4;



//selcet the data to write 
wire[7:0] val[0:3];
assign val[0]=mem_data_to_write[7:0];
assign val[1]=mem_data_to_write[15:8];
assign val[2]=mem_data_to_write[23:16];
assign val[3]=mem_data_to_write[31:24];

wire[7:0] writebuffer_val[0:3];
assign writebuffer_val[0]=write_buffer[write_buffer_to_write_num][7:0];
assign writebuffer_val[1]=write_buffer[write_buffer_to_write_num][15:8];
assign writebuffer_val[2]=write_buffer[write_buffer_to_write_num][23:16];
assign writebuffer_val[3]=write_buffer[write_buffer_to_write_num][31:24];

assign d_out=
(!bus_busy)&&(!buffer_occupied==0)?writebuffer_val[write_buffer_cnt]:
    (write_mem==1&&(mem_addr==32'h00030000||mem_addr==32'h00030004)&&((io_full==1)))?0:val[mem_write_cnt];

always @(posedge clk_in) begin
    if(rst_in==1) begin
        old_write_buffer<=0;
        new_write_buffer<=0;
        preaddr<=0;
        mem_read_cnt<=0;
        mem_write_cnt<=0;
        if_read_cnt<=0;
        mem_read_data<=0;
        if_read_instru<=0;
        mem_write_data<=0;
        mem_load_done<=0;
        mem_ctrl_instru_to_if<=0;
        mem_ctrl_busy_state<=0;
        if_load_done<=0;
        mem_ctrl_instru_to_if<=0;
        ichachswicth<=1;
        dchachswicth<=1;
        IO_switch<=1;
        IO_cnt<=2;
        buffer_occupied<=0;
        write_buffer_cnt<=0;
        for (i=0 ;i<ICACHE_SIZE ;i=i+1 ) begin
            valid[i]<=0;
        end
        for (i=0 ;i<DCACHE_SIZE ;i=i+1 ) begin
            dcache_valid[i]<=0;
        end
        for (i=0 ;i<WRITEBUFFERSIZE ;i=i+1 ) begin
            
            write_buffer_addr[i]<=0;
            write_buffer[i]<=0;
        end
    end
    else 
    begin
        if (rdy_in==1) begin
            if(write_mem==1)begin
            if (IO_switch==1&&(mem_addr==32'h00030000||mem_addr==32'h00030004)) begin
            //$display(IO_cnt);
                if (IO_cnt==2) begin
                //$display($time," read or write1 ",r_or_w,"  io full ",io_full," aout: ",a_out);
                if_load_done<=0;
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b01;
                mem_load_done<=0;
                IO_cnt<=1;
                end
                else if(IO_cnt==1&&io_full==1)begin
                //$display($time," read or write2 ",r_or_w,"  io full ",io_full," aout: ",a_out);
                if_load_done<=0;
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b01;
                mem_load_done<=0;
                IO_cnt<=1;

                end 
                else if(IO_cnt==1&&io_full==0)begin
                //$display("read or write3 ",r_or_w," mem addr %h",mem_addr+mem_write_cnt," d_out  ",d_out);
                if_load_done<=0;
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b01;
                mem_load_done<=0;
                if (mem_write_cnt==data_len) begin
                    mem_ctrl_busy_state<=0;
                    mem_load_done<=1;
                    mem_write_cnt<=0;
                    IO_cnt<=2;
                end 
                else
                    begin
                    $display("here!!!",data_len,"  ",mem_write_cnt);
                        mem_write_cnt<=mem_write_cnt+1;   
                        IO_cnt<=2;
                    end   
                
                end 
                
                
            end
            else begin
                if_load_done<=0;
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b01;
                mem_load_done<=0;
                dcache_valid[mem_addr[DCACHE_INDEX_LEN-1:0]]<=1;
                    dcache_tag[mem_addr[DCACHE_INDEX_LEN-1:0]]<=mem_addr[31:DCACHE_INDEX_LEN];
                    if (data_len==3) begin
                    //$display($time,"data_len add dcache 3: ",data_len,"  mem addr %h ",mem_addr);
                    dcache_[mem_addr[DCACHE_INDEX_LEN-1:0]]<=mem_data_to_write;                        
                    end
                    else if (data_len==0) begin
                    //$display("data_len add dcache 0: ",data_len,"  mem addr %h ",mem_addr);

                    dcache_[mem_addr[DCACHE_INDEX_LEN-1:0]][7:0]<=mem_data_to_write[7:0];                       
                    end
                    else if (data_len==1) begin
                    //$display("data_len add dcache 1: ",data_len,"  mem addr %h ",mem_addr);

                    dcache_[mem_addr[DCACHE_INDEX_LEN-1:0]][15:0]<=mem_data_to_write[15:0];                       
                    end

                    //when there is space in the write buffer we can store the data in the buffer temporary
                if(buffer_occupied[1]==0)begin
                        buffer_occupied[1]=1;
                        write_buffer[1]=mem_data_to_write;
                        write_buffer_addr[1]=mem_addr;
                        mem_ctrl_busy_state<=0;
                        mem_load_done<=1;
                        mem_write_cnt<=0;
                        new_write_buffer<=1;
                        
                    end
                    else if(buffer_occupied[0]==0)begin
                        buffer_occupied[0]=1;
                        write_buffer[0]=mem_data_to_write;
                        write_buffer_addr[0]=mem_addr;
                        mem_ctrl_busy_state<=0;
                        mem_load_done<=1;
                        mem_write_cnt<=0;
                        new_write_buffer<=0;

                        
                    end
                


                //when the write buffer is occupied then we must store it in the ram
else begin
    if (mem_write_cnt==data_len) begin
                    mem_ctrl_busy_state<=0;
                    mem_load_done<=1;
                    mem_write_cnt<=0;
                end 
                else
                    begin
                        mem_write_cnt<=mem_write_cnt+1;                       
                    end 
end

            end
                    end
            
            else if (read_mem==1) begin
                //$display("read data_len hit dcache: ",data_len,"   mem addr hit %h :",mem_addr," is valid:",dcache_valid[mem_addr[DCACHE_INDEX_LEN-1:0]]," dcache_tag[mem_addr[DCACHE_INDEX_LEN-1:0]]:%h ",dcache_tag[mem_addr[DCACHE_INDEX_LEN-1:0]]," mem_addr[31:DCACHE_INDEX_LEN]:%h ",mem_addr[31:DCACHE_INDEX_LEN]);

                if(dchachswicth==1&&dcache_valid[mem_addr[DCACHE_INDEX_LEN-1:0]]==1&&dcache_tag[mem_addr[DCACHE_INDEX_LEN-1:0]]==mem_addr[31:DCACHE_INDEX_LEN])begin
                //$display("data_len hit dcache: ",data_len,"   mem addr hit %h :",mem_addr);
                mem_ctrl_load_to_mem<=dcache_[mem_addr[DCACHE_INDEX_LEN-1:0]];
                mem_load_done<=1;
                mem_ctrl_busy_state<=0;
                mem_read_cnt<=0;
                mem_read_data<=0;
                end
                else
                if (!read_write_buffer_num==4) begin
                    mem_ctrl_busy_state<=0;
                    mem_load_done<=1;
                    mem_read_cnt<=0;
                    mem_ctrl_load_to_mem<=write_buffer[read_write_buffer_num];
                    mem_read_data<=0;
                end
                else
                begin
                mem_ctrl_instru_to_if<=0;
                mem_ctrl_busy_state<=2'b01;
                mem_load_done<=0;
                mem_ctrl_load_to_mem<=0;
                if_load_done<=0;
                case (mem_read_cnt)
                //because the read operation take a ciecle in the ram
                    1:begin
                        mem_read_data[7:0]<=d_in;                       
                    end
                    2:begin
                        mem_read_data[15:8]<=d_in;                        
                    end
                    3:begin
                        mem_read_data[23:16]<=d_in;                        
                    end
                    4: begin
                        mem_read_data[31:24]<=d_in;                       
                    end
                    default: begin                       
                    end
                endcase
                if (mem_read_cnt==data_len+1) begin
                    mem_ctrl_busy_state<=0;
                    mem_load_done<=1;
                    mem_read_cnt<=0;
                    mem_ctrl_load_to_mem<=mem_read_data;
                    mem_read_data<=0;
                end else
                    begin
                        mem_read_cnt<=mem_read_cnt+1;                       
                    end   
                end




            end  else if(if_read_or_not==1)begin        
                if(ichachswicth==1&&valid[intru_addr[ICACHE_INDEX_LEN-1:0]]==1&&tag[intru_addr[ICACHE_INDEX_LEN-1:0]]==intru_addr[31:ICACHE_INDEX_LEN])begin
                mem_ctrl_instru_to_if<=icache_[intru_addr[ICACHE_INDEX_LEN-1:0]];
                if_load_done<=1;
                mem_ctrl_busy_state<=0;
                if_read_cnt<=0;
                if_read_instru<=0;
                preaddr<=intru_addr;
                end
                else
                begin                   
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
                        if_read_instru[7:0]<=d_in;                       
                    end
                    2:begin
                        if_read_instru[15:8]<=d_in;                        
                    end
                    3:begin
                        if_read_instru[23:16]<=d_in;                        
                    end
                    4: begin
                        if_read_instru[31:24]<=d_in;                       
                    end
                    default: begin                      
                    end
                endcase              
                if (if_read_cnt==5) begin
                    if_load_done<=1;
                    mem_ctrl_busy_state<=0;
                    if_read_cnt<=0;
                    mem_ctrl_instru_to_if<=if_read_instru;
                    if_read_instru<=0;
                    preaddr<=intru_addr;
                    valid[intru_addr[ICACHE_INDEX_LEN-1:0]]<=1;
                    tag[intru_addr[ICACHE_INDEX_LEN-1:0]]<=intru_addr[31:ICACHE_INDEX_LEN];
                    icache_[intru_addr[ICACHE_INDEX_LEN-1:0]]<=if_read_instru;

                end else if(preaddr==intru_addr)
                    begin
                        if_read_cnt<=if_read_cnt+1;
                        preaddr<=intru_addr;                                         
                    end 
                    preaddr<=intru_addr; 
                end
            end          
            else 
            begin


            
            //todo ifprefetch for if  && write buffer for read
            //$display("yes no requirement here");


                if (!buffer_occupied==0) begin
                if (write_buffer_cnt==3) begin
                    write_buffer_cnt <=0;
                    write_buffer[write_buffer_to_write_num]<=0;
                    buffer_occupied[write_buffer_to_write_num]<=0;
                    write_buffer_addr[write_buffer_to_write_num]<=0;
                end 
                else
                    begin
                        write_buffer_cnt<=write_buffer_cnt+1;                       
                    end  
                end
            

            mem_load_done<=0;
            mem_ctrl_instru_to_if<=0;
            mem_ctrl_busy_state<=0;
            if_load_done<=0;
            mem_ctrl_instru_to_if<=0;
            end
        end
    end
end
endmodule //memctrl