#*******************************************************************************
#*******************************************************************************

#------------------------------------------------------------------------------
proc gen_prj_struct { prjName } {
    set nRuns 1
    for {set i 1} { $i <= $nRuns} { incr i} {
       #---
       if {[lsearch [get_filesets ] constrs_${i}] == -1} {
           create_fileset -constrset constrs_${i}
       }
#       add_files -fileset constrs_${i} -norecurse src/${prjName}-${i}.xdc

       #---
       if {[lsearch [get_runs ] synth_${i}] == -1} {
           create_run synth_${i} -constrset constrs_${i} -flow {Vivado Synthesis 2016}
       }

       #---
       if {[lsearch [get_runs ] impl_${i}] == -1} {
           create_run impl_${i} -parent_run synth_${i} -flow {Vivado Implementation 2016}
       }
    }
}

#*******************************************************************************
#*******************************************************************************

#-----------------------------------
set DEBUG_INFO 1

set sfxSV  *.sv
set sfxV   *.v
set sfxSDC *.sdc
set sfxXDC *.xdc

#-----------------------------------
set SCRIPT_DIR        [lindex $argv 0]
set SRC_DIR           [lindex $argv 1]
set OUT_CFG_DIR       [lindex $argv 2]
set PRJ_NAME          [lindex $argv 3]
set TARGET_FILE_NAME  [lindex $argv 4]

#-----------------------------------
source $SCRIPT_DIR/cfg_header_gen.tcl

#-----------------------------------
set CFG_DIR [pwd]

#-----------------------------------
set srcFileListStart 5
set srcFileNum [expr $argc - $srcFileListStart]
set srcFileList [lrange $argv $srcFileListStart end]

#-----------------------------------
create_project ${TARGET_FILE_NAME} [file normalize ${OUT_CFG_DIR}] 
gen_prj_struct ${PRJ_NAME}

#-----------------------------------

#--- SystemVerilog file list
set srcSV [lsearch -all -inline $srcFileList $sfxSV]
foreach src $srcSV {
	add_files -scan_for_includes $src
} 

#--- Verilog file list
set srcV  [lsearch -all -inline $srcFileList $sfxV]
foreach src $srcV {
	add_files -scan_for_includes $src
} 

#--- SDC file list
set srcSDC  [lsearch -all -inline $srcFileList $sfxSDC]
foreach src $srcSDC {
	add_files -fileset constrs_1 -norecurse $src
} 

#--- XDC file list
set srcXDC  [lsearch -all -inline $srcFileList $sfxXDC]
foreach src $srcXDC {
	add_files -fileset constrs_1 -norecurse $src
} 

#-----------------------------------
source ${CFG_DIR}/settings.tcl

#-----------------------------------
cfg_header_gen $PRJ_NAME $CFG_DIR "VIVADO"

#-----------------------------------
#--- TEST (begin)
set TEST 0
if {$TEST == 1} {
       puts "\n**************** TEST (begin)"
       set src1 [lsearch -inline [get_filesets ] sources_1]
       set cst1 [lsearch -inline [get_filesets ] constrs_1]
       set syn1 [lsearch -inline [get_runs ] synth_1]
       set imp1 [lsearch -inline [get_runs ] impl_1]
       set o1 $src1

       #puts [list_property $s1]
       #puts "slon: [get_property NAME $s1]"
       foreach prop [list_property $o1] {
	puts "$prop: [get_property  $prop $o1]" 
       }
       puts "**************** TEST (end)\n"
}
#--- TEST (end)

#-----------------------------------
close_project

#-----------------------------------
if {$DEBUG_INFO == 1} {
	puts "\[DEBUG\] \[xilinx_prj_gen\]"
	puts "SCRIPT_DIR:       $SCRIPT_DIR"
	puts "SRC_DIR:          $SRC_DIR"
	puts "OUT_CFG_DIR:      $OUT_CFG_DIR"
	puts "PRJ_NAME:         $PRJ_NAME"
	puts "TARGET_FILE_NAME: $TARGET_FILE_NAME"
}

