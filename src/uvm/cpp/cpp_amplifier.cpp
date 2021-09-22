#include <iostream>

#ifdef __cplusplus
    extern "C" {
#endif
        class c_cpp{
            public:
                c_cpp(){};
                ~c_cpp(){};

            int calculate(int base_number, int scaler);
        };  
 
 
        int amplifier_by_cpp(int base_number, int scaler);

#ifdef __cplusplus
    }   
#endif


int c_cpp::calculate(int base_number, int scaler){
    using namespace std;
    cout<<"calculated by cpp"<<endl;
    return base_number*scaler;

};



int amplifier_by_cpp(int base_number, int scaler){
    c_cpp c_inst;

    return c_inst.calculate(base_number,scaler);
};