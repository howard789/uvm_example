#############################
# User variables
#############################
TB       = ue_tb
SEED     = 1
CTEST   ?= 0
DUT_DIR = ./src/dut
CFILES = dpi_ref.c
COMPLIST = complist.f
COVERAGE_DIR = ./coverage
LOG_DIR = ./log
CM_DIR = ./coverage

TIMESCALE = 1ns/1ps

CM_TYPE = cond+tgl+line+fsm+path

UVM_HOME = /opt/Synopsys/Verdi2015/share/vmlib/uvm/uvm-1.1d/lib/src



#############################
# Environment variables
#############################
#VCOMP    = vlogan -full64 -ntb_opts uvm-1.1 -sverilog -timescale=1ps/1ps -nc -l log/comp.log +incdir+$(INC_DIR)
#ELAB     = vcs -full64 -ntb_opts uvm-1.1 -debug_all -l log/elab.log -sim_res=1ps 

#BASE_VCOMP     = vcs -full64 +acc +vpi -sverilog +v2k -lca $(UVM_HOME)/src/dpi/uvm_dpi.cc -DVCS -l $(LOG_DIR)/comp.log -timescale=$(TIMESCALE) -f $(COMPLIST) +incdir+$(DUT_DIR) -debug_all -cm $(CM_TYPE) -cm_pp -cm_log $(LOG_DIR)/coverage.log -cm_dir $(CM_DIR)

VCOMP_VERDI = -LDFLAGS -rdynamic -fsdb -P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a  +DUMP_FSDB  



VCOMP     = vcs -full64 +acc +vpi -sverilog +v2k $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS -l $(LOG_DIR)/comp.log -timescale=$(TIMESCALE) -f $(COMPLIST) +incdir+$(DUT_DIR) -debug_all -cm $(CM_TYPE) -lca -cm_pp -cm_log $(LOG_DIR)/coverage.log -cm_dir $(CM_DIR) ${VCOMP_VERDI}

#VCOMP_VERDI = $(BASE_VCOMP) -LDFLAGS -rdynamic -fsdb -P ${NOVAS_HOME}/share/PLI/VCS/LINUX64/novas.tab ${NOVAS_HOME}/share/PLI/VCS/LINUX64/pli.a  +DUMP_FSDB  



RUN_CASE0      = ./simv -l run.log -sml +ntb_random_seed=$(SEED) +UVM_TESTNAME=ue_case0_test
RUN_CASE1      = ./simv -l run.log -sml +ntb_random_seed=$(SEED) +UVM_TESTNAME=ue_case1_test
RUN_CASE2      = ./simv -l run.log -sml +ntb_random_seed=$(SEED) +UVM_TESTNAME=ue_case2_test

DVE_COV = dve -covdir *.vdb &
DVE_VPD = dve -vpd vcdplus.vpd
RUN_VERDI = Verdi -elab simv.daidir/kdb -l $(LOG_DIR)/verdi_run.log -ssf ue_tb.fsdb

ifeq ($(CTEST),1)
	VCOMP += dpi_ref.c
endif

comp:
	$(VCOMP)

#compv:
#	$(VCOMP_VERDI)

run:
	$(RUN_CASE0)

cov:
	$(DVE_COV)

vpd:
	$(DVE_VPD)


#rung:
#	$(RUN) -gui

urg:
	urg -lca -dir *.vdb & 

verdi:
	$(RUN_VERDI)


clean:
	rm -rf AN.DB DVEfiles csrc *.simv *.simv.daidir *.simv.vdb ucli.key *.vdb VerdiLog *.daidir 
	rm log/* *.vpd *.h *.fsdb simv *.dat novas.* *.log *.log.sml urgReport/*

	
	
