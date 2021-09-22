`ifndef UE_CASE0_TEST_SV
`define UE_CASE0_TEST_SV

//--------------------------------------------------------------------------------------------------------
// sequence svh
//--------------------------------------------------------------------------------------------------------


class ue_case0_sequence extends ue_base_sequense;
	
	 randc bit [15:0] wr_scaler;
     randc bit [ 7:0] base_number;
     bit [ 7:0] no;
     int 	    idle_cycles;

   	int bug_base_number;
	int bug_scaler;
	subseq_set_scaler 	   seq_scaler;
	subseq_wr_base_number  seq_base_number;
	subseq_idle 		   seq_idle;

	randc int burst_num;

	`uvm_object_utils(ue_case0_sequence)

	extern function new(string name="ue_case0_sequence"); 
  	extern task body();
endclass : ue_case0_sequence


//--------------------------------------------------------------------------------------------------------
// sv
//--------------------------------------------------------------------------------------------------------

function ue_case0_sequence::new(string name="ue_case0_sequence");
  super.new(name);  
  `uvm_info(get_type_name(), $sformatf("created"), UVM_FULL)
endfunction : new

task ue_case0_sequence::body();
	if(starting_phase != null) begin
         starting_phase.raise_objection(this);
	end

 	bug_base_number=123;
	bug_scaler=5;


	`uvm_do_with(seq_idle,{idle_cycles == 10;})

	wr_scaler=16'hffff; 

	// 写法:1
	// `uvm_create(seq_scaler)
	// seq_scaler.scaler=wr_scaler;
	// `uvm_send(seq_scaler)

	// 写法:2
	// `uvm_create(seq_scaler)
	// `uvm_rand_send_with(seq_scaler, {scaler == local::wr_scaler;})

	// 写法:3
	`uvm_do_with(seq_scaler, {scaler == local::wr_scaler;})

	no=1;
	base_number=0;
	`uvm_do_with(seq_base_number, {no == local::no;base_number == local::base_number;idle_cycles == 0;})


	//连续写入
	repeat(50) begin
		wr_scaler=get_rand_number_except(1,10,bug_scaler);
 		`uvm_do_with(seq_scaler, {scaler == local::wr_scaler;})
 		
		`uvm_do_with(seq_idle, {idle_cycles == 1;})
 		
 		burst_num=get_rand_number(1,5);
 		$display("burst_num %0d", burst_num);
 		repeat(burst_num) begin  //连续写入次数

			no+=1;
			base_number = get_rand_number_except(121,130,bug_base_number);		
			`uvm_do_with(seq_base_number, {no == local::no;base_number == local::base_number;idle_cycles == 0;})
 		end 
		`uvm_do_with(seq_idle, {idle_cycles == 1;})
	end



	repeat(10)
		`uvm_do_with(seq_idle, {idle_cycles == 1;})

  if(starting_phase != null) 
      starting_phase.drop_objection(this);  
endtask : body



//--------------------------------------------------------------------------------------------------------
// test
//--------------------------------------------------------------------------------------------------------

class ue_case0_test extends ue_base_test;

	`uvm_component_utils(ue_case0_test)
	function new(string name="ue_case0_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction : new
	
	function void build();
		super.build();
		uvm_config_db#(uvm_object_wrapper)::set(this,"env.i_agt.sqr.main_phase","default_sequence", ue_case0_sequence::type_id::get());
	endfunction
endclass : ue_case0_test

`endif // UE_CASE0_TEST_SV




