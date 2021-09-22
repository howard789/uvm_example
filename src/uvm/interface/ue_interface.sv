`ifndef UE_INTERFACE_SV
`define UE_INTERFACE_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "param_def.v"

`timescale 1ns/1ps

interface ue_interface (input clk,input rstn);
	logic 							wr_en_i;     // input valid 
	logic 							set_scaler_i; // is_input_scaler  

	logic [`WR_DATA_WIDTH-1:0]    	wr_data_i; // input data: 16 bit scaler or (8 bit no + 8 bit base_number)

	logic 							rd_val_o; //  rd_data valid 
	logic [`RD_DATA_WIDTH-1:0]		rd_data_o;   //
	logic [`SCALER_WIDTH-1:0]		scaler_o;   //current scaler

	bit start_report ;
	//---------------------------------------
	// clocking
	//---------------------------------------

    // https://blog.csdn.net/wonder_coole/article/details/82597125
	clocking cb_drv @(posedge clk);
	    default input #1ps output #1ps;
	    output wr_en_i,set_scaler_i, wr_data_i;
	    input  rd_val_o, rd_data_o,scaler_o;
	endclocking : cb_drv
	
	clocking cb_mon @(posedge clk);
	    default input #1ps output #1ps;
	    input wr_en_i,set_scaler_i,wr_data_i, rd_val_o,rd_data_o, scaler_o;
	endclocking : cb_mon



	// cg option https://xueying.blog.csdn.net/article/details/105309727
	covergroup cg_wr_command(string comment ="") @(posedge clk iff rstn);
		//type total bins: 8-2(ignore_bins)-4(type_option.weight = 0)=2
		//instance total bins  : 8-2(ignore_bins)=6

		type_option.weight = 0;
		option.goal =100;
		option.auto_bin_max = 100; //default 64
		option.at_least =10;
		option.cross_num_print_missing=1;//多个实例的时候 分开计算
		option.comment=comment; //多个实例的时候

		wr_en: coverpoint wr_en_i{
		//http://blog.sina.com.cn/s/blog_5391b49c0102vte0.html
			type_option.weight = 0;
		    bins unsel = {0};
		    bins sel   = {1};
		}
		set_scaler: coverpoint set_scaler_i{
			type_option.weight = 0;
		    bins unsel = {0};
		    bins sel   = {1};
		}
		cmd: cross wr_en,set_scaler{
		      bins cmd_set_scaler = binsof(wr_en.sel) && binsof(set_scaler.sel);
		      bins cmd_write = binsof(wr_en.sel) && binsof(set_scaler.unsel);
		      ignore_bins ignore0 = binsof(wr_en.unsel) && binsof(set_scaler.sel);
		      ignore_bins ignore1 = binsof(wr_en.unsel) && binsof(set_scaler.unsel);
		      // ignore_bins others = default;  //采样到的时候, 仿真会停止
		      // ignore_bins others = binsof(default) && binsof(default);
		    }
	endgroup 





	covergroup cg_wr_timing_group(string comment ="") @(posedge clk iff (rstn && !set_scaler_i));
		//type total bins: 8
		//instance total bins  : 8-6(option.weight = 0)=2

		option.comment=comment;
		coverpoint wr_en_i{
		      bins burst_1 = ( 0 => 1 => 0);
		      bins burst_2 = ( 0 => 1[*2] => 0);
		      bins burst_3 = ( 0 => 1[*3] => 0);
		      bins burst_4 = ( 0 => 1[*4] => 0);
		      bins burst_5 = ( 0 => 1[*5] => 0);
		    }
	endgroup: cg_wr_timing_group


																	
	covergroup cg_scaler_range_group(int low,high,string comment ="") @(posedge clk iff (rstn && wr_en_i && set_scaler_i));
		
		//type total bins: 1
		//instance total bins  : 1
		option.comment=comment; 
		option.cross_num_print_missing=1;
		coverpoint wr_data_i {
			bins range[] ={[low:high]};	
		}
	endgroup: cg_scaler_range_group



	covergroup cg_base_number_range_group(int low,high,string comment ="") @(posedge clk iff (rstn && wr_en_i && !set_scaler_i));
		//type total bins: 1
		//instance total bins  : 1
		option.comment=comment; 
		option.cross_num_print_missing=1;
		coverpoint wr_data_i[7:0] {
			bins range[] ={[low:high]};
		}
	endgroup: cg_base_number_range_group


	covergroup cg_scaler_bits_wide_group(string comment ="") @(posedge clk iff (rstn && wr_en_i && set_scaler_i));
		//type total bins: 2
		//instance total bins  : 2
		coverpoint wr_data_i {
			wildcard bins highest_bit_wide0={16'b1xxx_xxxx_xxxx_xxxx};
			wildcard bins highest_bit_wide1={16'b0zzz_zzzz_zzzz_zzzz};
			illegal_bins others = default;
		}
	endgroup: cg_scaler_bits_wide_group

	covergroup cg_base_number_bits_wide_group(string comment ="") @(posedge clk iff (rstn && wr_en_i && !set_scaler_i));
		//type total bins: 2
		//instance total bins  : 2

		coverpoint wr_data_i {
			wildcard bins highest_bit_wide0={16'b????_????_1???_????};
			wildcard bins highest_bit_wide1={16'bxxxx_xxxx_0xxx_xxxx};
			illegal_bins others = default;
		}
	endgroup: cg_base_number_bits_wide_group





	initial begin 
		automatic cg_wr_command cg_0= new();
		automatic cg_wr_timing_group cg_1= new();
	

		automatic cg_scaler_range_group cg_2= new(1,10);
		automatic cg_base_number_range_group cg_3= new(121,130);
		automatic cg_scaler_bits_wide_group cg_4= new();
		automatic cg_base_number_bits_wide_group cg_5= new();

		wait(rstn==0);
		cg_0.stop();
		wait(rstn==1);
		cg_0.start();
		//cg_0.sample();

		cg_0.set_inst_name("cg_0");

		wait(start_report)begin
				string s;


				s={s,"cg_wr_command "};
				s={s,$sformatf("coverage:%0d\n",cg_0.get_inst_coverage())};

				s={s,"cg_wr_timing_group "};
				s={s,$sformatf("coverage:%0d\n",cg_1.get_inst_coverage())};

				s={s,"cg_scaler_range_group "};
				s={s,$sformatf("coverage:%0d\n",cg_2.get_inst_coverage())};

				s={s,"cg_base_number_range_group "};
				s={s,$sformatf("coverage:%0d\n",cg_3.get_inst_coverage())};

				s={s,"cg_scaler_bits_wide_group "};
				s={s,$sformatf("coverage:%0d\n",cg_4.get_inst_coverage())};

				s={s,"cg_base_number_bits_wide_group "};
				s={s,$sformatf("coverage:%0d\n",cg_5.get_inst_coverage())};		
				s={s,$sformatf("total coverage:%0d\n",$get_coverage())};

				//监测并 动态修改约束,提高覆盖率,或停止仿真
				$display("%0s",s);
		end
	end

	//--------------------------------------------------------------------------------------------------------
	// property
	//--------------------------------------------------------------------------------------------------------
	
	property pro_wr_en_wr_data;
		@(posedge clk) disable iff (!rstn) 
		wr_en_i |-> not $isunknown(wr_data_i) ;
	endproperty: pro_wr_en_wr_data
	assert property(pro_wr_en_wr_data) else `uvm_error("ASSERT", "wr_data_i is unknown while wr_en_i is high")
	cover property(pro_wr_en_wr_data) 	;
	
	property pro_set_scaler;
		@(posedge clk) disable iff (!rstn) 
		(wr_en_i && set_scaler_i) |-> (wr_data_i!=0) |=> not $isunknown(scaler_o);
	endproperty: pro_set_scaler
	assert property(pro_set_scaler) else `uvm_error("ASSERT", "set zero scaler")
	cover property(pro_set_scaler) ;	
	
	property pro_wr_en_wr_scaler_rd_val;
		@(posedge clk) disable iff (!rstn) 
		(wr_en_i && !set_scaler_i)  |=> (##1 rd_val_o or $rose(rd_val_o)) ;
	endproperty: pro_wr_en_wr_scaler_rd_val
	assert property(pro_wr_en_wr_scaler_rd_val) else  `uvm_error("ASSERT", "rd_val_o is still invalid after (wr_en_i && !wr_scaler_i)")
	cover property(pro_wr_en_wr_scaler_rd_val) ;	

	property pro_wr_scaler_i_scaler_o;
		logic [15:0] data;
		@(posedge clk) disable iff (!rstn) 
		(wr_en_i && set_scaler_i , data = wr_data_i)  |=>  (data == scaler_o) ;		
	endproperty: pro_wr_scaler_i_scaler_o
	assert property(pro_wr_scaler_i_scaler_o)	else `uvm_error("ASSERT", "set scaler fail");
	cover property (pro_wr_scaler_i_scaler_o) ;
	
	property pro_rd_val_rd_data_o;
		@(posedge clk) disable iff (!rstn) 
		rd_val_o  |->  !$isunknown(rd_data_o) ;
	endproperty: pro_rd_val_rd_data_o
	assert property(pro_rd_val_rd_data_o)	else `uvm_error("ASSERT", "rd_data_o is unknown while rd_valid")	
	cover property(pro_rd_val_rd_data_o) ;
	

	// initial begin 
	// 	forever begin 
	// 		wait(rstn==0);
	// 		$assertoff();
	// 		wait(rstn==1);
	// 		$asserton();
	// 	end
	// end

endinterface


`endif // UE_INTERFACE_SV


