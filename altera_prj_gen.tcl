#*******************************************************************************
#*******************************************************************************
package require ::quartus::project

#-----------------------------------
set DEBUG_INFO 1

set sfxSV  *.sv
set sfxV   *.v
set sfxSDC *.sdc

#-----------------------------------
set SCRIPT_DIR        [lindex $argv 0]
set SRC_DIR           [lindex $argv 1]
set OUT_CFG_DIR       [lindex $argv 2]
set PRJ_NAME          [lindex $argv 3]
set PRJ_FILE_NAME     [lindex $argv 4]
#-----------------------------------
source $SCRIPT_DIR/cfg_header_gen.tcl

#-----------------------------------
set CFG_DIR [pwd]

#-----------------------------------
set srcFileListStart 4
set srcFileNum [expr $argc - $srcFileListStart]
set srcFileList [lrange $argv $srcFileListStart end]

#-----------------------------------
project_new [file normalize ${OUT_CFG_DIR}/${PRJ_FILE_NAME}]

#-----------------------------------
source ${CFG_DIR}/settings.tcl
source ${CFG_DIR}/signals.tcl
source ${CFG_DIR}/groups.tcl

#-----------------------------------
cfg_header_gen $CFG_DIR "QUARTUS"

#-----------------------------------
set_global_assignment -name SEARCH_PATH  ${CFG_DIR}
set_global_assignment -name SEARCH_PATH  ${SRC_DIR}
#set_global_assignment -name HTML_REPORT_FILE ${PRJ_FILE_NAME}
set_global_assignment -name TEXT_FORMAT_REPORT_FILE ${PRJ_FILE_NAME}

#-----------------------------------

#--- SystemVerilog file list
set srcSV [lsearch -all -inline $srcFileList $sfxSV]
foreach src $srcSV {
	set_global_assignment -name SYSTEMVERILOG_FILE $src
} 

#--- Verilog file list
set srcV  [lsearch -all -inline $srcFileList $sfxV]
foreach src $srcV {
	set_global_assignment -name VERILOG_FILE $src
} 

#--- SDC file list
set srcSDC  [lsearch -all -inline $srcFileList $sfxSDC]
foreach src $srcSDC {
	set_global_assignment -name SDC_FILE ${CFG_DIR}/$src
} 

#-----------------------------------
export_assignments
project_close

#-----------------------------------
if {$DEBUG_INFO == 1} {
	puts "\[DEBUG\] \[altera_prj_gen\]"
	puts "SCRIPT_DIR:       $SCRIPT_DIR"
	puts "SRC_DIR:          $SRC_DIR"
	puts "OUT_CFG_DIR:      $OUT_CFG_DIR"
	puts "PRJ_FILE_NAME:    $PRJ_FILE_NAME"
}
