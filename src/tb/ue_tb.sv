`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"


module ue_tb;

  parameter  T    =  2; 
  bit         clk,rstn;
  string s;
  int res;
  initial begin:gen_clk
    fork
      begin 
        forever #(T/2) clk = !clk;
      end
      begin
        rstn <= 1'b0;
        #T;
        rstn <= 1'b1;
      end
    join_none
  end

  ue_interface intf(clk, rstn);
  // ue_interface intf(.*);


  amplifier amplifier_inst
  (
  .clk_i(clk),    
  .rstn_i(rstn),
  .wr_en_i(intf.wr_en_i),
  .set_scaler_i(intf.set_scaler_i), 
  .wr_data_i(intf.wr_data_i),
  .rd_val_o(intf.rd_val_o),
  .rd_data_o(intf.rd_data_o),
  .scaler_o(intf.scaler_o)
  );



  initial begin:set_config
  	uvm_config_db#(virtual ue_interface)::set(uvm_root::get(), "uvm_test_top.env.i_agt", "vif", intf);
    uvm_config_db#(virtual ue_interface)::set(uvm_root::get(), "uvm_test_top.env.o_agt", "vif", intf);
  end

  initial begin:run
    // run_test("ue_case0_test");
    // run_test("ue_case1_test");
    // run_test("ue_case2_test");

    run_test();
  end

 //  initial begin:vcdpluson
 //    $vcdpluson;
 //    $fsdbDumpfile("ue_tb.fsdb");
 //    $fsdbDumpvars;
 //  end

 //  initial begin
 //    if($test$plusargs("DUMP_FSDB"))begin
 //      $fsdbDumpfile("testname.fsdb");  //记录波形，波形名字testname.fsdb
 //      $fsdbDumpvars("+all");  //+all参数，dump SV中的struct结构体
 //      $fsdbDumpSVA();   //将assertion的结果存在fsdb中
 //      //$fsdbDumpMDA(0, top);  //dump memory arrays
 //     //0: 当前级及其下面所有层级，如top.A, top.A.a，所有在top下面的多维数组均会被dump
 //     //1: 仅仅dump当前组，也就是说，只dump top这一层的多维数组。
 //   end
 // end
 
endmodule
