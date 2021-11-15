// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "EX_MEM.v"


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






pc_ pc(
      .clk_in(),
      .rst_in(),
      .rdy_in(), 
      //from stallctrl
      .stall_in(),
      //from ex
      .branch_or_not(),
      .branch_addr(),
      //to if
      .pc_out()

);

if_ IF(
    .rst_in(),
    //from pc
    .pc_in(),
    //to if_id
    .pc_out(),  
    .instr_out(),
    //to stallctrl
    .stall_from_if(),
    //from mem ctrl
    .if_load_done(),
    .mem_ctrl_busy_state(),
    .mem_ctrl_read_in(),
    //to mem ctrl
    .read_or_not(),  
    .intru_addr()

);

if_id_ IF_ID(
    .clk_in(),
    .rst_in(),
    .rdy_in(), 
    //from stall ctrl
    .stall_in(),
    //from ex
    .branch_or_not(),
    //from if
    .input_pc(),
    .input_instru(),
    //to id
    .output_pc(),
    .output_instru() 
);

id_ ID(
    .rst_in(),
    //from if_id
    .input_pc(),
    .input_instru(),
    //from regfile
    .reg1_data(),
    .reg2_data(),
    //forwarding from ex
    .isloading_ex(),
    .ex_forward_id_i(),
    .ex_forward_data_i(),
    .ex_forward_addr_i(), 
    //forwarding from mem
    .mem_forward_id_i(),
    .mem_forward_data_i(),
    .mem_forward_addr_i(), 
    //to regfile       
    .reg1_reador_not(),
    .reg2_reador_not(),
    .reg1addr(),
    .reg2addr(),
    //to id_ex
    .reg1_to_ex(),
    .reg2_to_ex(),
    .rsd_to_ex(),
    .write_rsd_or_not(),
    .cmdtype_to_exe(),
    .immout(),
    .pc_out()  ,
    //to stall ctrl
    .stallfrom_ex()  

);

regfile_ regfile(
    .clk_in(),
    .rst_in(),
    //from mem_wb
    .write_or_not(),
    .writeaddr(),
    .writedata(),
    //from id
    .read1_or_not(),
    .readaddr1(),
    .read1data(),
    //from id
    .read2_or_not(),
    .readaddr2(),
    .read2data()

);

id_ex_ ID_EX(
    .clk_in(),
    .rst_in(),
    .rdy_in(), 
    //from stallctrl
    .stall_in(),
    //from id
    .branch_or_not(),
    .input_pc(),
    .reg1_from_id(),
    .reg2_from_id(),
    .rsd_from_id(),
    .write_rsd_or_not_from_id(),
    .cmdtype_from_id(),
    .pc_in(),
    .imm_in(),
    //to ex
    .reg1_to_ex(),
    .reg2_to_ex(),
    .rsd_to_ex(),
    .write_rsd_or_not_to_ex(),
    .cmdtype_to_exe(),    
    .pc_out(),
    .imm_out()
);

ex_ EX(
//from id_ex
    .rst_in(), 
    .reg1_to_ex(),
    .reg2_to_ex(),
    .rsd_to_ex(),
    .write_rsd_or_not_to_ex(),
    .cmdtype_to_exe(),    
    .pc_in(),
    .imm_in(),
    //to ex_mem
    .rsd_addr_to_write(),
    .rsd_data(),
    .write_rsd_or_not(),
    .branch_or_not(),
    .branch_address(),
    .mem_addr(),
    .mem_read_or_not(),
    .cmdtype_out(),  
    //forward to id
    .isloading_ex(),
    .ex_forward_id_o(),
    .ex_forward_data_o(),
    .ex_forward_addr_o()
);

ex_mem_ EX_MEM(
    .clk_in(),
    .rst_in(),
    .rdy_in(), 
    //from stall ctrl
    .stall_in(),

    //from ex
    .rsd_addr_to_write(),
    .rsd_data(),
    .write_rsd_or_not(),
    .branch_or_not(),
    .branch_address(),
    .mem_addr(),
    .mem_read_or_not(),
    .cmdtype(),    
    //to mem
    .cmdtype_out(),    
    .rsd_addr_out(),
    .rsd_data_out(),
    .write_rsd_or_not_out(),
    .branch_or_not_out(),
    .branch_address_out(),
    .mem_addr_out(),
    .mem_read_or_not_out()
);

mem_ MEM(

    .rst_in(),
    //from ex_mem
    .input_rd_addr(),
    .input_rd_data(),
    .write_or_not(),
    .cmdtype(), 
    .mem_addr(),
    .mem_read_or_not(),   

    //to mem_wb
    .out_rd_addr(),
    .out_rd_data(),
    .out_write_or_not(),

    //forward to id
    .mem_forward_id_o(),
    .mem_forward_data_o(),
    .mem_forward_addr_o    (),

    //to stallctrl
    .stall_from_mem(),

    //from mem ctrl
    .mem_load_done(),
    .mem_ctrl_busy_state(),
    .mem_ctrl_read_in(),

    //to mem ctrl
    .read_mem(),
    .write_mem(),
    .mem_addr_to_read(),
    .mem_data_to_write(),
    .data_len()
);

mem_wb_ MEM_WB(
    .clk_in(),
    .rst_in(),
    .rdy_in(), 
    //from stall ctrl
    .stall_in(),
    //from mem
    .mem_reg_addr(),
    .mem_reg_data(),
    .if_write(),
    //to regfile
    .mem_reg_addr_out(), 
    .mem_reg_data_out(),
    .if_write_out()
);

memctrl_ memctrl(
    .clk_in(),
    .rst_in(),
    .rdy_in(), 
    //to mem and if 
    .mem_ctrl_busy_state(),//[1] stand for the state of the if [0]stand for the state of the mem
    //to mem
    .mem_load_done(),   
    .mem_ctrl_load_to_mem(),
    //from mem 
    .read_mem(),
    .write_mem(),
    .mem_addr(),
    .mem_data_to_write(),
    .data_len(),
    //to if
    .if_load_done(),
    .mem_ctrl_instru_to_if(),
    //from if
    .if_read_or_not(),  
    .intru_addr(),
    //from ram
    .d_in    (), // data input
    //to ram
    .r_or_w(),  // read/write select (read: 1(), write: 0)
    .a_out(),     // memory address
    .d_out()     // data output 

);

stallctrl_ stallctrl(
    //from if
    .stall_from_if(),
    //from id
    .stall_from_id(),
    //from ex
    .stall_from_ex(),
    //from mem
    .stall_from_mem(),
    //to pc id_id id_ex ex_mem mem_wb
    .stall()//stall[0] stand for pc stop 1stand for stop
);

always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end

endmodule