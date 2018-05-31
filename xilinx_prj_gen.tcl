#*******************************************************************************
#*******************************************************************************

#------------------------------------------------------------------------------
proc addSrcFiles { srcFileList incDir } {
	upvar 1 incDir resIncDir
	if { [expr [llength $srcFileList]] > 0 } {
		add_files -scan_for_includes $srcFileList
		foreach item $srcFileList {
			set item [file dirname $item]
			if { $item ni $resIncDir } {
				lappend resIncDir $item
			}
		}
	}
}	

#------------------------------------------------------------------------------
proc prjClean { outCfgDir } {
	if {[file exists ${outCfgDir}]} {
		set files [glob -nocomplain -tail -directory ${outCfgDir} *]
		set fileToDelete [lsearch -regexp -not -all -inline $files "^-ip$"]
		set fileToDelete [lsearch -regexp -not -all -inline $fileToDelete "^((?!backup).)*.(\.log|\.jou)$"]
		#set fileList2 [lsearch -regexp -all -inline $files "^${PRJ_NAME}-prj(\.log|\.jou)$"]
		#set fileToDelete [concat $fileList1 $fileList2]
		foreach f $fileToDelete {
			file delete -force ${outCfgDir}/$f
			#puts "slon: $f"
 		}
	} else {
		file mkdir ${outCfgDir}	
	}
}

#------------------------------------------------------------------------------
proc gen_ip_lists { srcFileList }  {
	set ipLists [dict create xcix {} xci {} bd {}]
	foreach srcFile $srcFileList {
		set srcFileTail [file tail $srcFile]
		if {![string match *.* $srcFileTail]} {
			#---
			set xcixFile ${srcFile}/${srcFileTail}.xcix
			set xciFile  ${srcFile}/${srcFileTail}/${srcFileTail}.xci
			#---
	        	if {[file exists $xcixFile]} {
				dict lappend ipLists xcix ${xcixFile}
                	}
			#---
	        	if {[file exists $xciFile]} {
				dict lappend ipLists xci ${xciFile}
                	}
        	}
	}
	return $ipLists
}

#------------------------------------------------------------------------------
proc gen_prj_struct { prjName targetFileName device } {
    set nRuns 2
    set cfgDir [pwd]
    set defSynthFlow "Vivado Synthesis 2018"
    set defImplFlow  "Vivado Implementation 2017"

    for {set i 1} { $i <= $nRuns} { incr i} {
       #---
       if {[lsearch [get_filesets ] constrs_${i}] == -1} {
           create_fileset -constrset constrs_${i}
	   #for test only: in future will be like ${targetFileName}-${i}.xdc
       	   add_files -fileset constrs_${i} -norecurse ${cfgDir}/${targetFileName}.sdc ${cfgDir}/${targetFileName}.xdc 
       }

       #---
       if {[lsearch [get_runs ] synth_${i}] == -1} {
           create_run synth_${i} -constrset constrs_${i} -part ${device} -flow ${defSynthFlow}
	   set_property SRCSET sources_1 [get_runs synth_${i}]
       } else {
	   set_property FLOW ${defSynthFlow} [get_runs synth_${i}]
       }

       #---
       if {[lsearch [get_runs ] impl_${i}] == -1} {
           create_run impl_${i} -parent_run synth_${i} -flow ${defImplFlow}
       } else {
	   set_property FLOW ${defImplFlow} [get_runs impl_${i}]
       }
    }
}

#*******************************************************************************
#*******************************************************************************

#-----------------------------------
set DEBUG_INFO 0

set sfx_sv   *.sv
set sfx_v    *.v
set sfx_sdc  *.sdc
set sfx_xdc  *.xdc

#-----------------------------------
set SCRIPT_DIR        [lindex $argv 0]
set SRC_DIR           [lindex $argv 1]
set OUT_CFG_DIR       [lindex $argv 2]
set PRJ_NAME          [lindex $argv 3]
set TARGET_FILE_NAME  [lindex $argv 4]
set DEVICE            [lindex $argv 5]
set BUILD_TOOL        [lindex $argv 6]

#-----------------------------------
prjClean ${OUT_CFG_DIR}

#-----------------------------------
source $SCRIPT_DIR/cfg_header_gen.tcl

#-----------------------------------
set CFG_DIR [pwd]

#-----------------------------------
set srcFileListStart 7
set srcFileNum [expr $argc - $srcFileListStart]
set srcFileList [lrange $argv $srcFileListStart end]

set src_sv  [lsearch -all -inline $srcFileList $sfx_sv]  
set src_v   [lsearch -all -inline $srcFileList $sfx_v]   
set src_sdc [lsearch -all -inline $srcFileList $sfx_sdc] 
set src_xdc [lsearch -all -inline $srcFileList $sfx_xdc] 

#-----------------------------------
cfg_header_gen $PRJ_NAME $CFG_DIR $BUILD_TOOL

#-----------------------------------
create_project ${TARGET_FILE_NAME} [file normalize ${OUT_CFG_DIR}] 

#puts "get_filesets: [get_filesets ]"
#puts "get_runs:     [get_runs ]"

gen_prj_struct ${PRJ_NAME} ${TARGET_FILE_NAME} ${DEVICE}

#-----------------------------------
set incDir {}

#--- add SV files and make incDir
addSrcFiles ${src_sv} ${incDir}

#--- add Verilog files and make incDir
addSrcFiles ${src_v} ${incDir}

#--- add SDC files
if { [expr [llength $src_sdc]] > 0 } {
	add_files -fileset constrs_1 -norecurs $src_sdc
}

#--- add XDC files
if { [expr [llength $src_xdc]] > 0 } {
	add_files -fileset constrs_1 -norecurs $src_xdc
}

#--- IP and BD files
set ipLists [gen_ip_lists ${srcFileList}]

#--- add xcix files
foreach ip_xcix [dict get $ipLists xcix] {
	read_ip $ip_xcix
	#puts "\[XILINX_PRJ_GEN:DEBUG\] ip_xcix: $ip_xcix"
}

#--- add xci files
foreach ip_xci [dict get $ipLists xci] {
	read_ip $ip_xci
	#puts "\[XILINX_PRJ_GEN:DEBUG\] ip_xci: $ip_xci"
}

#-----------------------------------
set_property part ${DEVICE} [current_project]
source ${CFG_DIR}/settings.tcl

#-----------------------------------
#--- TEST (begin)
set TEST 0
if {$TEST == 1} {
       puts "\n**************** \[XILINX_PRJ_GEN:DEBUG\] TEST (begin)"
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
       puts "**************** \[XILINX_PRJ_GEN:DEBUG\] TEST (end)\n"
}
#--- TEST (end)

#-----------------------------------
close_project

#-----------------------------------
if {$DEBUG_INFO == 1} {
	puts "\[XILINX_PRJ_GEN:DEBUG\] SCRIPT_DIR:       $SCRIPT_DIR"
	puts "\[XILINX_PRJ_GEN:DEBUG\] SRC_DIR:          $SRC_DIR"
	puts "\[XILINX_PRJ_GEN:DEBUG\] OUT_CFG_DIR:      $OUT_CFG_DIR"
	puts "\[XILINX_PRJ_GEN:DEBUG\] PRJ_NAME:         $PRJ_NAME"
	puts "\[XILINX_PRJ_GEN:DEBUG\] TARGET_FILE_NAME: $TARGET_FILE_NAME"
	puts "\[XILINX_PRJ_GEN:DEBUG\] DEVICE:           $DEVICE"
}

