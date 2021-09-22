#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>

extern void dpi_info(char* s);
extern void dpi_fatal(char* s);



int amplifier(int base_number, int scaler) {
	int(*p_get_res)(int, int) = NULL;
	int res;

	HMODULE h_my_fun = LoadLibraryA("my_fun.dll");
	if (h_my_fun == NULL) {
		dpi_fatal("load dll fail");
	}

	dpi_info("load dll success");
	p_get_res = (int(*)(int, int))GetProcAddress(h_my_fun, "get_res");

	void(*p_get_info)(char*,int,int, int, int) = NULL;
	res = p_get_res(base_number, scaler);

	p_get_info = (void(*)(char*,int,int, int, int))GetProcAddress(h_my_fun, "get_info");

	char mm[256];
	p_get_info(mm, 256, base_number, scaler, res);
	dpi_info(mm);
	
	return res;
}

