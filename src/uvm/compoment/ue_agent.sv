`ifndef UE_AGENT_SV
`define UE_AGENT_SV

//---------------------------------------
// svh
//---------------------------------------

class ue_agent extends uvm_agent;

  uvm_active_passive_enum is_active;
  
  ue_driver drv;
  ue_sequencer sqr;
  ue_monitor mon;

  ue_config cfg;
  virtual ue_interface vif;

  `uvm_component_utils(ue_agent)

  extern function new(string name = "ue_agent",uvm_component parent = null);
  extern function void build();
  extern function void connect();
  extern function void report();
endclass

//---------------------------------------
// sv
//---------------------------------------
function ue_agent::new(string name = "ue_agent" ,uvm_component parent = null);
  super.new(name, parent);
  `uvm_info(get_type_name(), $sformatf("created, is_active: %s" ,is_active), UVM_LOW)
endfunction : new

function void ue_agent::build();
  	super.build();
    

    if(!uvm_config_db#(ue_config)::get(this,"","cfg", cfg)) begin
     cfg = ue_config::type_id::create("cfg");
    end

    `uvm_info(get_type_name(), $sformatf("start to build, is_active: %s",is_active), UVM_LOW)



  	if(!uvm_config_db#(virtual ue_interface)::get(this,"","vif", vif)) begin
  	  `uvm_fatal("GETVIF","cannot get vif handle from config DB")
  	end
    vif.start_report=0;


  	mon = ue_monitor::type_id::create("mon",this);
  	mon.vif=vif;

  	if(is_active==UVM_ACTIVE) begin 
  		sqr = ue_sequencer::type_id::create("sqr",this);
  		drv = ue_driver::type_id::create("drv",this);  		
  		drv.vif = vif;
      mon.monitor_input=1'b1;
  	end
    else
      mon.monitor_input=1'b0;


    `uvm_info(get_type_name(), "built", UVM_LOW)
endfunction:build

function void ue_agent::connect();
	if(is_active==UVM_ACTIVE) begin 
		drv.seq_item_port.connect(sqr.seq_item_export);
	end
  `uvm_info(get_type_name(), "connected", UVM_LOW)
endfunction:connect



function void ue_agent::report();
  super.report();
  vif.start_report=1;
  
endfunction:report

`endif // UE_AGENT_SV