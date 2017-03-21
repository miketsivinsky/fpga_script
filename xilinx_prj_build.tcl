#*******************************************************************************
#*******************************************************************************

#------------------------------------------------------------------------------
proc check_status { jobName } {
    if {[get_property PROGRESS [get_runs $jobName]] != "100%"} {
        error "ERROR: $jobName failed"
    } else {
        puts "INFO: $jobName completed. Ok."
    }	
}

#*******************************************************************************
#*******************************************************************************

#-----------------------------------
set DEBUG_INFO 1

#-----------------------------------
set OUT_CFG_DIR      [lindex $argv 0]
set PRJ_FILE_NAME    [lindex $argv 1]

#-----------------------------------
set CFG_DIR [pwd]
set REF_SRC_DIR ../..

open_project [file normalize ${OUT_CFG_DIR}/${PRJ_FILE_NAME}]

set synthName synth_1
set implName  impl_1

#-----------------------------------
#--- TEST (begin)
set TEST 0
if {$TEST == 1} {
       puts "\n**************** TEST (begin)"
       set src1 [lsearch -inline [get_filesets ] sources_1]
       set cst1 [lsearch -inline [get_filesets ] constrs_1]
       set syn1 [lsearch -inline [get_runs ] $synthName]
       set imp1 [lsearch -inline [get_runs ] $implName]
       set o1 $syn1

       #puts [list_property $s1]
       #puts "slon: [get_property NAME $s1]"
       foreach prop [list_property $o1] {
	puts "$prop: [get_property  $prop $o1]" 
       }
       puts "**************** TEST (end)\n"
}
#--- TEST (end)

#---
reset_run    $synthName
launch_runs  $synthName -jobs 6    
wait_on_run  $synthName
check_status $synthName

#---
reset_run    $implName
launch_runs  $implName -jobs 6 -to_step write_bitstream
wait_on_run  $implName
check_status $implName

#---
close_project

#-----------------------------------
if {$DEBUG_INFO == 1} {
	puts "\[DEBUG\] \[xilinx_prj_build\]"
	puts " OUT_CFG_DIR:      $OUT_CFG_DIR"
	puts " PRJ_FILE_NAME:    $PRJ_FILE_NAME"
}

