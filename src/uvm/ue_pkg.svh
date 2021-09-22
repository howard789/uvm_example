import uvm_pkg::*;
`include "uvm_macros.svh"

`include "./interface/ue_interface.sv"


`include "./obj/ue_transaction.sv"
`include "./obj/ue_config.sv"

`include "./obj/sequence/ue_base_sequense.sv"
`include "./obj/sequence/ue_base_sequense_lib.sv"


`include "./compoment/ue_driver.sv"
`include "./compoment/ue_monitor.sv"
`include "./compoment/ue_sequencer.sv"

`include "./compoment/ue_agent.sv"

`include "./compoment/ue_ref_model.sv"
`include "./compoment/ue_scoreboard.sv"


`include "./compoment/ue_env.sv"
`include "./compoment/ue_base_test.sv"

`include "./test_case/ue_case0_test.sv"
`include "./test_case/ue_case1_test.sv"
`include "./test_case/ue_case2_test.sv"
