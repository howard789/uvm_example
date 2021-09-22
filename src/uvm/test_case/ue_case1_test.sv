`ifndef UE_case1_TEST_SV
`define UE_case1_TEST_SV

//--------------------------------------------------------------------------------------------------------
// sequence svh
//--------------------------------------------------------------------------------------------------------


class ue_case1_sequence extends ue_base_sequense;
	
	 bit [15:0] wr_scaler;
     bit [ 7:0] base_number;
     bit [ 7:0] no;
     int 	    idle_cycles;

   	int bug_base_number;
	int bug_scaler;
	subseq_set_scaler 	   seq_scaler;
	subseq_wr_base_number  seq_base_number;
	subseq_idle 		   seq_idle;

	`uvm_object_utils(ue_case1_sequence)

	extern function new(string name="ue_case1_sequence"); 
  	extern task body();
endclass : ue_case1_sequence


//--------------------------------------------------------------------------------------------------------
// sv
//--------------------------------------------------------------------------------------------------------

function ue_case1_sequence::new(string name="ue_case1_sequence");
  super.new(name);  
  `uvm_info(get_type_name(), $sformatf("created"), UVM_FULL)
endfunction : new

task ue_case1_sequence::body();
	if(starting_phase != null) begin
         starting_phase.raise_objection(this);
	end

 	bug_base_number=123;
	bug_scaler=5;


	`uvm_do_with(seq_idle,{idle_cycles == 10;})

	`uvm_do_with(seq_scaler, {scaler == 7;})

	`uvm_do_with(seq_idle, {idle_cycles == 1;})
	`uvm_do_with(seq_base_number, {no == 1;base_number == bug_base_number;idle_cycles == 0;})
	`uvm_do_with(seq_idle, {idle_cycles == 1;})



	`uvm_do_with(seq_scaler, {scaler == bug_scaler;})



	repeat(10)
		`uvm_do_with(seq_idle, {idle_cycles == 1;})

  if(starting_phase != null) 
      starting_phase.drop_objection(this);  
endtask : body



//--------------------------------------------------------------------------------------------------------
// test
//--------------------------------------------------------------------------------------------------------

class ue_case1_test extends ue_base_test;

	`uvm_component_utils(ue_case1_test)
	function new(string name="ue_case1_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction : new
	
	function void build();
		super.build();
		uvm_config_db#(uvm_object_wrapper)::set(this,"env.i_agt.sqr.main_phase","default_sequence", ue_case1_sequence::type_id::get());
	endfunction
endclass : ue_case1_test

`endif // UE_case1_TEST_SV




