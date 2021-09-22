`ifndef UE_DRIVER_SV
`define UE_DRIVER_SV

//---------------------------------------
// svh
//---------------------------------------

class ue_driver extends uvm_driver #(ue_transaction);
	bit show_info;
	ue_config cfg;
	virtual ue_interface vif; 

	`uvm_component_utils(ue_driver)

	extern function new(string name ="ue_driver",uvm_component parent = null);
	extern function void build();
	extern task run();
	
	extern protected task _reset_listener();
	extern protected task _get_and_drive();
	
	extern protected task _drive_transfer(ue_transaction t);
	
	
	extern protected task _do_idle();
	extern protected task _set_scaler(ue_transaction t);
	extern protected task _wr_base_number(ue_transaction t);

endclass : ue_driver


//---------------------------------------
// sv
//---------------------------------------
	
function ue_driver::new(string name ="ue_driver",uvm_component parent = null);
  super.new(name, parent);
  `uvm_info(get_type_name(), $sformatf("created"), UVM_LOW)
endfunction : new

function void ue_driver::build();
	super.build();
	if(!uvm_config_db#(ue_config)::get(this,"","cfg", cfg)) begin
     cfg = ue_config::type_id::create("cfg");
    end

    show_info = cfg.show_info_drv;


	`uvm_info(get_type_name(), "built", UVM_LOW)
endfunction : build


task ue_driver::run();

	super.run();
	vif.wr_en_i = 1'b0;
	vif.set_scaler_i = 1'b0;
	vif.wr_data_i = 1'b0;
	vif.rd_val_o = 1'b0;
	vif.rd_data_o = 1'b0;
	vif.scaler_o = 1'b0;

	while(!vif.rstn)
	   @(posedge vif.clk);



	`uvm_info(get_type_name(), "start run()", UVM_LOW)

	fork
	  ue_driver::_get_and_drive();
	  ue_driver::_reset_listener();
	join
  

  	`uvm_info(get_type_name(), "end run()", UVM_LOW)
endtask : run


task ue_driver::_reset_listener();
     forever begin 
     	@(negedge vif.rstn);
	    vif.wr_en_i = 0;
	    vif.set_scaler_i =0 ;
	    vif.wr_data_i = 0;
	    if(show_info)
  			`uvm_info(get_type_name(), "_reset_listener done", UVM_LOW)
     end
endtask


task ue_driver::_drive_transfer(ue_transaction t);
	if(show_info)
		t.print_info("ue_driver _drive_transfer");
	case (t.ttype) 
	    ue_transaction::IDLE:_do_idle();  
	    ue_transaction::SET_SCALER:_set_scaler(t);  
	    ue_transaction::WR_BASE_NUMBER:_wr_base_number(t); 
	    default:`uvm_error("ERRTYPE", "_drive_transfer mode err")
	endcase

endtask


task ue_driver::_do_idle();
    @(vif.cb_drv);
    vif.cb_drv.wr_en_i <= 1'b0;
    vif.cb_drv.wr_data_i<= 1'b0;
endtask

task ue_driver::_set_scaler(ue_transaction t);
    @(vif.cb_drv);
    vif.cb_drv.wr_en_i <= 1'b1;
	vif.cb_drv.set_scaler_i<= 1'b1;
    vif.cb_drv.wr_data_i <= t.wr_scaler;

	@(vif.cb_drv);//dut收到信号

	@(vif.cb_drv);
    t.rd_scaler = vif.cb_drv.scaler_o;
endtask

task ue_driver::_wr_base_number(ue_transaction t);
    @(vif.cb_drv);
    vif.cb_drv.wr_en_i <= 1'b1;
	vif.cb_drv.set_scaler_i <= 1'b0;	
    vif.cb_drv.wr_data_i <= {t.no,t.base_number};
	t.rd_scaler = vif.cb_drv.scaler_o;
	repeat(t.idle_cycles) _do_idle();
endtask


task ue_driver::_get_and_drive();
     forever begin 
     	seq_item_port.get_next_item(req);
     	this._drive_transfer(req);
     	void'($cast(rsp, req.clone()));
		rsp.set_sequence_id(req.get_sequence_id());
		seq_item_port.item_done(rsp);
		
    end
endtask


`endif // UE_DRIVER_SV
