#include <stdio.h>


// int cal(int base_number, int scaler){
// 	printf("calculated by c\n");
// 	return base_number*scaler;
// }


int amplifier(int base_number, int scaler) {

	// 直接用c写算法
	// return cal(base_number,scaler);

	//调用cpp档案
	return amplifier_by_cpp(base_number,scaler);

}
