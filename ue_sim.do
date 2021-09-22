#======================================#
# TCL script for a mini regression     #
#======================================#

onbreak resume
onerror resume

# set environment variables

setenv UVM_SRC ./src/uvm
setenv TB_SRC ./src/tb
setenv DUT_SRC src/dut
setenv COMP_LIST complist.f
setenv RESULT_DIR result
setenv TB_NAME ue_tb
setenv LOG_DIR log

set timetag [clock format [clock seconds] -format "%Y%b%d-%H_%M"]



#clean the environment and remove trash files.....
set delfiles [glob work *.log *.ucdb sim.list]
file delete -force {*}$delfiles

#compile the design and dut with a filelist
vlib work



#complie cpp files

#方法1调用cpp档案
#vlog ./src/uvm/cpp/my_fun_c.c
#vlog ./src/uvm/cpp/cpp_amplifier.cpp

#方法2调用dll
vlog ./src/uvm/cpp/my_fun_dll.c

echo prepare simrun folder
file mkdir $env(RESULT_DIR)/regr_ucdb_${timetag}
file mkdir $env(LOG_DIR)

vlog -sv -cover bst -timescale=1ns/1ps -l $env(LOG_DIR)/comp_${timetag}.log +incdir+$env(DUT_SRC) -f $env(COMP_LIST)



#simulate with specific testname sequentially
set TestSets { {ue_case0_test 2} \
				       {ue_case1_test 1} \
               {ue_case2_test 0}

              }


foreach testset $TestSets {
  set testname [lindex $testset 0]
  set LoopNum [lindex $testset 1]
  for {set loop 0} {$loop < $LoopNum} {incr loop} {
    set seed [expr int(rand() * 100)]
    echo seed:${seed}
    vsim -onfinish stop -cvgperinstance -cvgmergeinstances -sv_seed $seed +UVM_TESTNAME=${testname} -l $env(RESULT_DIR)/regr_ucdb_${timetag}/run_${testname}_${seed}.log work.$env(TB_NAME)
    run -all
    coverage save $env(RESULT_DIR)/regr_ucdb_${timetag}/${testname}_${seed}.ucdb
    quit -sim
  }
}

#echo merge the ucdb per test

vcover merge -testassociated $env(RESULT_DIR)/regr_ucdb_${timetag}/regr_${timetag}.ucdb {*}[glob $env(RESULT_DIR)/regr_ucdb_${timetag}/*.ucdb]




echo ending.....
quit -f


