`include "param_def.v"

module amplifier
(

clk_i,    
rstn_i,
wr_en_i,

set_scaler_i, 
wr_data_i,

rd_val_o,
rd_data_o,
scaler_o

);



input 						                    clk_i;    
input 						                    rstn_i; 

input						                    wr_en_i; //
input						                    set_scaler_i; //是否是修改scaler
input			    [`WR_DATA_WIDTH-1:0]        wr_data_i; //输入序号8位 输入数字8位 ,或 sacaler 16位

output			reg 			                rd_val_o; //data_o有效
output			reg [`RD_DATA_WIDTH-1:0]		rd_data_o; //输出资料包括 序号[31:24], 基本数字[23:16], 放大后的数字[15:0]其中第15位是正负号

output			    [`SCALER_WIDTH-1:0]		    scaler_o; //當前的scaler


//=============================================================================
//****************************     Main Code    *******************************
//=============================================================================


reg   [`SCALER_WIDTH-1:0]  scaler;  //max 65,535
assign scaler_o = scaler;

reg 		  flag;

reg   [`NO_WIDTH-1:0]  no_r;
reg   [`RES_WIDTH-1:0]  res_r;


always @ (posedge clk_i or negedge rstn_i) begin
	if(rstn_i == 1'b0) begin
		no_r <= 1'b0;
    	res_r <= 1'b0;
		scaler <= 1'b0;
		flag <= 1'b0;
	end	

	//bug start 1
	 else if(wr_en_i && set_scaler_i && wr_data_i == 16'd5) begin	
	 	scaler <= 16'd55; 
	 	no_r <= 1'b0;
     	res_r <= 1'b0;
	 	flag <= 1'b0;
     end
	// bug end 1

	else if(wr_en_i && set_scaler_i) begin	
		scaler <= wr_data_i;
		no_r <= 1'b0;
    	res_r <= 1'b0;
		flag <= 1'b0;
    end

    //bug start 2
     else if(wr_en_i && !set_scaler_i && wr_data_i[ 7:0]== 8'd123) begin 
     	scaler <= scaler;
     	no_r   <= wr_data_i[15:8];
		 res_r  <= wr_data_i[ 7:0] * 100;
     	flag <= 1'b1;
     end
    // bug end 2


    else if(wr_en_i && !set_scaler_i) begin 
    	scaler <= scaler;
    	no_r   <= wr_data_i[15:8];
		res_r  <= wr_data_i[ 7:0] * scaler;
    	flag <= 1'b1;
    end
    else begin 
    	scaler <= scaler;
    	no_r <= 1'b0;
    	res_r <= 1'b0;
    	flag <= 1'b0;
    end

end

always @ (posedge clk_i or negedge rstn_i) begin
	if(rstn_i == 1'b0) begin
		rd_val_o <= 1'b0;
		rd_data_o <= 1'b0;
	end	
	else if(flag) begin	
        rd_val_o <= 1'b1;
        rd_data_o <= {no_r,res_r};
    end
    else begin 
		rd_val_o <= 1'b0;
		rd_data_o <= 1'b0;
    end
end


endmodule
