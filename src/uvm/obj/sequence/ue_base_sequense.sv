`ifndef UE_BASE_SEQUENCE
`define UE_BASE_SEQUENCE



class ue_base_sequense extends uvm_sequence #(ue_transaction);
	ue_transaction m_trans;
	`uvm_object_utils(ue_base_sequense)


	extern function new(string name="ue_base_sequense");
	extern function int get_rand_number_except(int min_thre,int max_thre,int except_num);
	extern function int get_rand_number(int min_thre,int max_thre);
endclass 


function ue_base_sequense::new(string name="ue_base_sequense");
	  super.new(name);  
endfunction : new


function int ue_base_sequense::get_rand_number_except(int min_thre,int max_thre,int except_num);
	int val=get_rand_number( min_thre, max_thre);
	while(val==except_num)
		val=get_rand_number( min_thre, max_thre);
	return val;	
endfunction


function int ue_base_sequense::get_rand_number(int min_thre,int max_thre);
	int val;
	void'(std::randomize(val) with { val inside {[min_thre:max_thre]};});
	return val;
endfunction


`endif // UE_BASE_SEQUENCE



