`ifndef UE_SCOREBOARD_SV
`define UE_SCOREBOARD_SV

//---------------------------------------
// svh
//---------------------------------------

class ue_scoreboard extends uvm_scoreboard;
	ue_config cfg;
	bit show_info;

	uvm_blocking_get_port #(ue_transaction)  exp_gp;
	uvm_blocking_get_port #(ue_transaction)  act_gp;

	ue_transaction tran_exp,tran_act;

	int success_num;
	int failure_num;

	`uvm_component_utils(ue_scoreboard)
	
	extern function new (string name = "ue_scoreboard", uvm_component parent =null);
	extern function void build();
	extern task run();
	extern function void report();

	
endclass : ue_scoreboard

//---------------------------------------
// sv
//---------------------------------------


function ue_scoreboard::new(string name ="ue_scoreboard",uvm_component parent = null);
  super.new(name, parent);

  `uvm_info(get_type_name(), $sformatf("created"), UVM_LOW)
endfunction : new


function void ue_scoreboard::build();
	super.build();
	if(!uvm_config_db#(ue_config)::get(this,"","cfg", cfg)) begin
     cfg = ue_config::type_id::create("cfg");
    end
    show_info = cfg.show_info_scb;
	
	exp_gp=new("exp_gp",this);
	act_gp=new("act_gp",this);
	success_num=0;
	failure_num=0;


	`uvm_info(get_type_name(), "built", UVM_LOW)
endfunction :build


task ue_scoreboard::run();
	super.run();
	fork
		while(1)begin
			exp_gp.get(tran_exp);
			act_gp.get(tran_act);
				if(tran_exp.no!=tran_act.no) 
					`uvm_info(get_type_name(), $sformatf("no is different,exp:%0d act:%0d",tran_exp.no,tran_act.no), UVM_LOW)
				else begin 
					if(tran_exp.rd_data==tran_act.rd_data) begin 
						success_num+=1;						
						if(show_info) begin 
							`uvm_info(get_type_name(), $sformatf("compare successfully scaler:%0d base_number:%0d rd_data:%0d",tran_act.rd_scaler,tran_act.base_number,tran_act.rd_data), UVM_LOW)
							tran_act.print_info(get_type_name());
						end
					end
					else begin 
						failure_num+=1;
						`uvm_error("SCORE_ERROR", $sformatf("compare failed,scaler:%0d,base_number:%0d,exp_res:%0d,act_res:%0d",tran_exp.rd_scaler,tran_exp.base_number,tran_exp.rd_data,tran_act.rd_data))
					end
				end
		end
	join

endtask


function void ue_scoreboard::report();
	super.report();
	if(show_info)
		`uvm_info(get_type_name(), $sformatf("report"), UVM_LOW)

	`uvm_info(get_type_name(), $sformatf("success_num:%0d",success_num), UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("failure_num:%0d",failure_num), UVM_LOW)
	// `uvm_info(get_type_name(), $sformatf("failure_base_numbers:%0s",failure_base_numbers), UVM_LOW)

	

endfunction :report




`endif // UE_SCOREBOARD_SV