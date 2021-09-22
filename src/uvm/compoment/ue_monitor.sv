`ifndef UE_MONITOR_SV
`define UE_MONITOR_SV

//---------------------------------------
// svh
//---------------------------------------

class ue_monitor extends uvm_monitor;
  bit show_info;

  ue_config cfg;

  bit monitor_input;

  int sent_item_num;

  virtual ue_interface vif;

  uvm_analysis_port #(ue_transaction) ap;

  protected ue_transaction trans_collected; //内部使用的指针
  
   `uvm_component_utils(ue_monitor)


  extern function new(string name ="ue_monitor",uvm_component parent = null);
  extern function void build();

  extern task run();

  extern protected task _collect_transfer(ue_transaction t);
  extern function void report();
endclass


//---------------------------------------
// sv
//---------------------------------------
function ue_monitor::new(string name="ue_monitor",uvm_component parent = null);
  super.new(name, parent);

  `uvm_info(get_type_name(), $sformatf("created"), UVM_LOW)
endfunction : new

function void ue_monitor::build();
    ap = new("ap",this); 
    if(!uvm_config_db#(ue_config)::get(this,"","cfg", cfg)) begin
     cfg = ue_config::type_id::create("cfg");
    end	
    show_info = cfg.show_info_mon;
   	
   	sent_item_num = 0;


	`uvm_info(get_type_name(), $sformatf("built"), UVM_LOW)
endfunction


task ue_monitor::run();
	super.run();

	`uvm_info(get_type_name(), "start run()", UVM_LOW)
	fork

		while(1) begin 	
			@(vif.cb_mon);
			trans_collected = ue_transaction::type_id::create("trans_collected");
	      	this._collect_transfer(trans_collected);//收集vif的资料赋值给 trans_collected
	      	
	      	if(monitor_input && trans_collected.ttype==ue_transaction::WR_BASE_NUMBER) begin 
	      		ap.write(trans_collected);
	      		sent_item_num+=1;
	      		if(show_info)
	      			trans_collected.print_info("mon input");
	      	end
	      	else if(trans_collected.rd_valid) begin 
	      		ap.write(trans_collected);
	      		sent_item_num+=1;
	      		if(show_info)
	      			trans_collected.print_info("mon output");
	      	end

		end


	join
	`uvm_info(get_type_name(), "end run()", UVM_LOW)


endtask



function void ue_monitor::report();
	super.report();
	`uvm_info(get_type_name(), $sformatf("sent_item_num:%d",sent_item_num), UVM_LOW)
endfunction:report








task ue_monitor::_collect_transfer(ue_transaction t);
	@(vif.cb_mon);
	
	if(monitor_input)begin //i_agent
	  if(vif.cb_mon.wr_en_i && !vif.cb_mon.set_scaler_i) begin 
	  	t.ttype = ue_transaction::WR_BASE_NUMBER;
	  	t.no = vif.cb_mon.wr_data_i[15:8];
		t.base_number = vif.cb_mon.wr_data_i[7:0];
	  	t.rd_scaler = vif.cb_mon.scaler_o;
	  end
	  else if(vif.cb_mon.wr_en_i && vif.cb_mon.set_scaler_i) begin 
	  	t.ttype = ue_transaction::SET_SCALER;
	  	t.no = 0;
		t.base_number = 0;
		t.wr_scaler = vif.cb_mon.wr_data_i;
	  	t.rd_scaler = vif.cb_mon.scaler_o;
	  end
	  else begin 
		t.ttype = ue_transaction::IDLE;
	  end
	end

	else begin   //o_agent
	  	t.rd_valid = vif.cb_mon.rd_val_o;
	  	t.no = vif.cb_mon.rd_data_o[31:24];
	  	t.rd_data = vif.cb_mon.rd_data_o[23:0];
	end

endtask

`endif // UE_MONITOR_SV
