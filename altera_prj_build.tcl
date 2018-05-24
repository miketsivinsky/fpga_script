#*******************************************************************************
#*******************************************************************************
package require ::quartus::project
load_package ::quartus::flow

#-----------------------------------
set DEBUG_INFO 1

#-----------------------------------
set OUT_CFG_DIR      [lindex $argv 0]
set PRJ_FILE_NAME    [lindex $argv 1]

#-----------------------------------
set CFG_DIR [pwd]
set REF_SRC_DIR ../..

project_open [file normalize ${OUT_CFG_DIR}/${PRJ_FILE_NAME}]
if {[catch {execute_flow -compile} result]} {
	puts "\nResult: $result\n"
	puts "\n\[ERROR\]: Compilation failed. See report files.\n"
} else {
	puts "\n\[INFO\]: Compilation was OK.\n"
}

project_close

#-----------------------------------
if {$DEBUG_INFO == 1} {
	puts "\[DEBUG\] \[altera_prj_build\]"
	puts " OUT_CFG_DIR:      $OUT_CFG_DIR"
	puts " PRJ_FILE_NAME:    $PRJ_FILE_NAME"
}
