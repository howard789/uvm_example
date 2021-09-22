`ifndef UE_SEQUENCER_SV
`define UE_SEQUENCER_SV
	
class ue_sequencer extends uvm_sequencer #(ue_transaction);

  `uvm_component_utils(ue_sequencer)
  extern function new(string name ="ue_sequencer",uvm_component parent = null);
  extern function void build();

endclass


//--------------------------------------------------------------------------------------------------------
// sv
//--------------------------------------------------------------------------------------------------------
function ue_sequencer::new(string name ="ue_sequencer",uvm_component parent = null);
  super.new(name, parent);
  `uvm_info(get_type_name(), $sformatf("created"), UVM_LOW)
endfunction : new

function void ue_sequencer::build();
	super.build();
	`uvm_info(get_type_name(), "built", UVM_LOW)
endfunction : build


`endif // UE_SEQUENCER_SV