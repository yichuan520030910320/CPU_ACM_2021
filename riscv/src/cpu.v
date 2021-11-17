// RISCV32I CPU top module
// port modification allowed for debugging purposes



module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)


//stall
wire[5:0] from_stall_ctrl;
wire  if_stall;
wire  id_stall;
wire  mem_stall;



//pc_out to if 
wire[31:0] pc_to_if;

//ex branch or not  to pc if_id id_ex
wire branch_or_not_;
//ex branch addr from ex to pc
wire [31:0] branch_out_addr;

pc pc_(
      .clk_in(clk_in),
      .rst_in(rst_in),
      .rdy_in(rdy_in), 
      //from stallctrl
      .stall_in(from_stall_ctrl),
      //from ex
      .branch_or_not(branch_or_not_),
      .branch_addr(branch_out_addr),
      //to if
      .pc_out(pc_to_if)

);

//if out to if_id
wire [31:0] if_pc_out_;
wire [31:0] if_instru_out_to_if_id;

//if to memctrl
wire if_read_or_not;
wire[31:0] if_read_addr_tomemctrl_;


//mem ctrl out to mem and if
wire[1:0]mem_busy_state;
wire memload_done;
wire[31:0] memctrl_load_to_mem;
wire if_load_done;
wire [31:0] memctrl_load_to_if;
IF if_ (
    .rst_in(rst_in),
    //from pc
    .pc_in(pc_to_if),
    //to if_id
    .pc_out(if_pc_out_),  
    .instr_out(if_instru_out_to_if_id),
    //to stallctrl
    .stall_from_if(if_stall),
    //from mem ctrl
    .if_load_done(if_load_done),
    .mem_ctrl_busy_state(mem_busy_state),
    .mem_ctrl_read_in(memctrl_load_to_if),
    //to mem ctrl
    .read_or_not(if_read_or_not),  
    .intru_addr(if_read_addr_tomemctrl_)

);
//if_id to id
wire [31:0] if_id_pc_to_id;
wire[31:0] if_id_instru_to_id;

IF_ID if_id_ (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in), 
    //from stall ctrl
    .stall_in(from_stall_ctrl),
    //from ex
    .branch_or_not(branch_or_not_),
    //from if
    .input_pc(if_pc_out_),
    .input_instru(if_instru_out_to_if_id),
    //to id
    .output_pc(if_id_pc_to_id),
    .output_instru(if_id_instru_to_id) 
);

//from regfile to id
wire [31:0] reg1_data_;
wire [31:0] reg2_data_;
//from id to regfile
wire reg1_reador_not_;
wire reg2_reador_not_;
wire [4:0]reg1addr_;
wire [4:0]reg2addr_;

//forward fromm ex to id 
wire  isloading_ex_;
wire ex_forward_id_i_;
wire [31:0]ex_forward_data_i_;
wire[4:0]ex_forward_addr_i_;
//forward from mem to id
wire mem_forward_id_i_;
wire [31:0]mem_forward_data_i_;
wire[4:0]mem_forward_addr_i_;

//id to id_ex
wire[31:0]id_reg1_to_ex_;
wire[31:0]id_reg2_to_ex_;
wire[4:0]id_rsd_to_ex_;
wire id_write_rsd_or_not;
wire[5:0]id_cmdtype_to_exe_;
wire[31:0]id_immout_;
wire[31:0]id_pc_out_;


ID id_ (
    .rst_in(rst_in),
    //from if_id
    .input_pc(if_id_pc_to_id),
    .input_instru(if_id_instru_to_id),
    //from regfile
    .reg1_data(reg1_data_),
    .reg2_data(reg2_data_),
    //forwarding from ex
    .isloading_ex(isloading_ex),
    .ex_forward_id_i(ex_forward_id_i_),
    .ex_forward_data_i(ex_forward_data_i_),
    .ex_forward_addr_i(ex_forward_addr_i_), 
    //forwarding from mem
    .mem_forward_id_i(mem_forward_id_i_),
    .mem_forward_data_i(mem_forward_data_i_),
    .mem_forward_addr_i(mem_forward_addr_i_), 
    //to regfile       
    .reg1_reador_not(reg1_reador_not_),
    .reg2_reador_not(reg2_reador_not_),
    .reg1addr(reg1addr_),
    .reg2addr(reg2addr_),
    //to id_ex
    .reg1_to_ex(id_reg1_to_ex_),
    .reg2_to_ex(id_reg2_to_ex_),
    .rsd_to_ex(id_rsd_to_ex_),
    .write_rsd_or_not(id_write_rsd_or_not),
    .cmdtype_to_exe(id_cmdtype_to_exe_),
    .immout(id_immout_),
    .pc_out(id_pc_out_)  ,
    //to stall ctrl
    .stallfrom_id(id_stall)  

);

// mem_wb to regfile
wire wb_write_or_not;
wire[4:0] wb_write_addr_;
wire[31:0] wb_write_data_;
regfile regfile_ (
    .clk_in(clk_in),
    .rst_in(rst_in),
    //from mem_wb
    .write_or_not(wb_write_or_not),
    .writeaddr(wb_write_addr_),
    .writedata(wb_write_data_),
    .read1_or_not(reg1_reador_not_),
    .readaddr1(reg1addr_),
    .read1data(reg1_data_),
    .read2_or_not(reg2_reador_not_),
    .readaddr2(reg2addr_),
    .read2data(reg2_data_)

);
//id_ex to ex
wire[31:0]reg1_to_ex_;
wire[31:0]reg2_to_ex_;
wire[4:0]rsd_to_ex_;
wire write_rsd_or_not_to_ex_;
wire[5:0]cmdtype_to_exe_;
wire[31:0]pc_out_to_ex_;
wire[31:0]imm_out_to_ex_;

ID_EX id_ex_(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in), 
    //from stallctrl
    .stall_in(from_stall_ctrl),
    //from id
    .branch_or_not(branch_or_not),
    .reg1_from_id(id_reg1_to_ex_),
    .reg2_from_id(id_reg2_to_ex_),
    .rsd_from_id(id_rsd_to_ex_),
    .write_rsd_or_not_from_id(id_write_rsd_or_not),
    .cmdtype_from_id(id_cmdtype_to_exe_),
    .pc_in(id_pc_out_),
    .imm_in(id_immout_),
    //to ex
    .reg1_to_ex(reg1_to_ex_),
    .reg2_to_ex(reg2_to_ex_),
    .rsd_to_ex(rsd_to_ex_),
    .write_rsd_or_not_to_ex(write_rsd_or_not_to_ex_),
    .cmdtype_to_exe(cmdtype_to_exe_),    
    .pc_out(pc_out_to_ex_),
    .imm_out(imm_out_to_ex_)
);

//to ex_mem
wire[4:0] ex_rsd_adr_to_write_;
wire[31:0] ex_rsd_data_;
wire ex_write_or_not;
wire [31:0] ex_mem_addr_;
wire ex_mem_read_or_not;
wire[5:0] ex_cmd_type_;
wire[31:0] store_data_out_from_ex;
EX ex_ (
//from id_ex
    .rst_in(rst_in), 
    .reg1_to_ex(reg1_to_ex_),
    .reg2_to_ex(reg2_to_ex_),
    .rsd_to_ex(rsd_to_ex_),
    .write_rsd_or_not_to_ex(write_rsd_or_not_to_ex_),
    .cmdtype_to_exe(cmdtype_to_exe_),    
    .pc_in(pc_out_to_ex_),
    .imm_in(imm_out_to_ex_),
    //to ex_mem
    .rsd_addr_to_write(ex_rsd_adr_to_write_),
    .rsd_data(ex_rsd_data_),
    .write_rsd_or_not(ex_write_or_not),
    //to pc if_id id_ex 
    .branch_or_not(branch_or_not),
    .branch_address(branch_out_addr),
    //to ex_mem
    .mem_addr(ex_mem_addr_),
    .cmdtype_out(ex_cmd_type_), 
    .mem_val_out_for_store(store_data_out_from_ex),
    //forward to id
    .isloading_ex(isloading_ex),
    .ex_forward_id_o(ex_forward_id_i_),
    .ex_forward_data_o(ex_forward_data_i_),
    .ex_forward_addr_o(ex_forward_addr_i_)
);

//ex_mem to mem
wire[5:0] cmdtype_to_mem;
wire[4:0] rsd_addr_out_to_mem;
wire[31:0] rsd_data_out_to_mem;
wire write_rsd_or_not_to_mem;
wire[31:0] mem_addr_out_mem;
wire mem_read_or_not_tomem;

//mem data store
wire [31:0] store_data_to_mem;

EX_MEM ex_mem_ (
    .strore_data(store_data_out_from_ex),
    .strore_data_out(store_data_to_mem), 

    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in), 
    //from stall ctrl
    .stall_in(from_stall_ctrl),
    //from ex
    .rsd_addr_to_write(ex_rsd_adr_to_write_),
    .rsd_data(ex_rsd_data_),
    .write_rsd_or_not(ex_write_or_not),
    .mem_addr(ex_mem_addr_),

    .cmdtype(ex_cmd_type_),    
    //to mem
    .cmdtype_out(cmdtype_to_mem),    
    .rsd_addr_out(rsd_addr_out_to_mem),
    .rsd_data_out(rsd_data_out_to_mem),
    .write_rsd_or_not_out(write_rsd_or_not_to_mem),
    .mem_addr_out(mem_addr_out_mem)

);
//mem to mem_wb
wire[4:0] rsd_addr_from_mem;
wire[31:0] rsd_data_from_mem;
wire  out_write_or_not_from_mem;

//mem to memctrl
wire mem_if_read;
wire mem_if_write;
wire[31:0] memaddr_to_read_to_memctrl;
wire[31:0]memdata_to_write_to_memctrl;
wire[2:0] data_len_;
MEM mem_ (
    .storedata_in(store_data_to_mem),
    .rst_in(rst_in),
    //from ex_mem
    .input_rd_addr(rsd_addr_out_to_mem),
    .input_rd_data(rsd_data_out_to_mem),
    .write_or_not(write_rsd_or_not_to_mem),
    .cmdtype(cmdtype_to_mem), 
    .mem_addr(mem_addr_out_mem),
  

    //to mem_wb
    .out_rd_addr(rsd_addr_from_mem),
    .out_rd_data(rsd_data_from_mem),
    .out_write_or_not(out_write_or_not_from_mem),

    //forward to id
    .mem_forward_id_o(mem_forward_id_i_),
    .mem_forward_data_o(mem_forward_data_i_),
    .mem_forward_addr_o    (mem_forward_addr_i_),

    //to stallctrl
    .stall_from_mem(mem_stall),

    //from mem ctrl
    .mem_load_done(mem_load_done),
    .mem_ctrl_busy_state(mem_busy_state),
    .mem_ctrl_read_in(memctrl_load_to_mem),

    //to mem ctrl
    .read_mem(mem_if_read),
    .write_mem(mem_if_write),
    .mem_addr_to_read(memaddr_to_read_to_memctrl),
    .mem_data_to_write(memdata_to_write_to_memctrl),
    .data_len(data_len_)
);

MEM_WB mem_wb_ (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in), 
    //from stall ctrl
    .stall_in(from_stall_ctrl),
    //from mem
    .mem_reg_addr(rsd_addr_from_mem),
    .mem_reg_data(rsd_data_from_mem),
    .if_write(out_write_or_not_from_mem),
    //to regfile
    .mem_reg_addr_out(wb_write_addr_), 
    .mem_reg_data_out(wb_write_data_),
    .if_write_out(wb_write_or_not)
);



memctrl memctrl_ (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .rdy_in(rdy_in), 
    //to mem and if 
    .mem_ctrl_busy_state(mem_busy_state),//[1] stand for the state of the if [0]stand for the state of the mem
    //to mem
    .mem_load_done(memload_done),   
    .mem_ctrl_load_to_mem(memctrl_load_to_mem),
    //from mem 
    .read_mem(mem_if_read),
    .write_mem(mem_if_write),
    .mem_addr(memaddr_to_read_to_memctrl),
    .mem_data_to_write(memdata_to_write_to_memctrl),
    .data_len(data_len_),
    //to if
    .if_load_done(if_load_done),
    .mem_ctrl_instru_to_if(memctrl_load_to_if),
    //from if
    .if_read_or_not(if_read_or_not),  
    .intru_addr(if_read_addr_tomemctrl_),
    //from ram
    .d_in    (mem_din), // data input
    //to ram
    .r_or_w(mem_wr),  // read/write select (read: 1(), write: 0)
    .a_out(mem_a),     // memory address
    .d_out(mem_dout)     // data output 

);

stallctrl stallctrl_ (
    //from if
    .stall_from_if(if_stall),
    //from id
    .stall_from_id(id_stall),
    //from mem
    .stall_from_mem(mem_stall),
    //to pc id_id id_ex ex_mem mem_wb
    .stall(from_stall_ctrl)//stall[0] stand for pc stop 1stand for stop
);

// always @(posedge clk_in)
//   begin
//     if (rst_in)
//       begin
      
//       end
//     else if (!rdy_in)
//       begin
      
//       end
//     else
//       begin
      
//       end
//   end

endmodule