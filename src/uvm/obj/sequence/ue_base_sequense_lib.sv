`ifndef UE_BASE_SEQ_LIB
`define UE_BASE_SEQ_LIB

//--------------------------------------------------------------------------------------------------------
// set_scaler
//--------------------------------------------------------------------------------------------------------

class subseq_set_scaler extends  ue_base_sequense;
	rand bit [`SCALER_WIDTH-1:0]    scaler; 
	
	`uvm_object_utils(subseq_set_scaler)
	function new(string name="subseq_set_scaler");
	  super.new(name);  
	endfunction : new

	virtual task body();	
		`uvm_do_with(req, {no==0;base_number==0;wr_scaler == local::scaler;ttype==ue_transaction::SET_SCALER;idle_cycles==0;})
		get_response(rsp);
		if(scaler!=rsp.rd_scaler)
		 	`uvm_error("SET_SCALER_ERR", $sformatf("subseq_set_scaler err, exp:%0d act:%0d",scaler,rsp.rd_scaler))
		else
			`uvm_info(get_type_name(),$sformatf("subseq_set_scaler success"), UVM_LOW)
	endtask : body
endclass : subseq_set_scaler


class subseq_wr_base_number extends  ue_base_sequense;
	rand logic [ 7:0]    base_number;
	rand int 			idle_cycles;
	rand int 			no;

	`uvm_object_utils(subseq_wr_base_number)

	function new(string name="");
	  super.new(name);  
	endfunction : new

	virtual task body();
		`uvm_do_with(req, {no==local::no;base_number== local::base_number;ttype==ue_transaction::WR_BASE_NUMBER;idle_cycles==local::idle_cycles;})
		get_response(rsp);
	endtask : body
endclass : subseq_wr_base_number

class subseq_idle extends  ue_base_sequense;

	rand int 			idle_cycles;

	`uvm_object_utils(subseq_idle)

	function new(string name="subseq_idle");
	  super.new(name);  
	  `uvm_info(get_type_name(), $sformatf("created"), UVM_LOW)
	endfunction : new

	virtual task body();
		`uvm_do_with(req, {no==0;ttype==ue_transaction::IDLE;idle_cycles==local::idle_cycles;})
		// get_response(rsp);
	endtask : body
endclass : subseq_idle



`endif // UE_BASE_SEQ_LIB