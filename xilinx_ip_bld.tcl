#*******************************************************************************
#*******************************************************************************

#------------------------------------------------------------------------------
proc ipGenPrologue { ipCoreName ipCoreOutDir DEVICE ipInfo } {

	create_project -force managed_ip_project $ipCoreOutDir/managed_ip_project -part $DEVICE -ip	

	set_property coreContainer.enable [dict get [$ipInfo] isPacked]  [current_project]
	set_property target_simulator      XSim      [current_project]
	set_property "simulator_language"  "Mixed"   [current_project]
	set_property "target_language"     "Verilog" [current_project]
}

#------------------------------------------------------------------------------
proc ipGenEpilogue { ipCoreName ipCoreOutDir } {
	generate_target all [get_ips  $ipCoreName]
	export_ip_user_files -of_objects [get_ips $ipCoreName] -sync -force -quiet
	create_ip_run [get_ips $ipCoreName]
	launch_runs -jobs 6 ${ipCoreName}_synth_1
	wait_on_run ${ipCoreName}_synth_1
	export_simulation -of_objects [get_ips $ipCoreName] -directory ${ipCoreOutDir}/ip_user_files/sim_scripts -ip_user_files_dir ${ipCoreOutDir}/ip_user_files -ipstatic_source_dir ${ipCoreOutDir}/ip_user_files/ipstatic -lib_map_path [list {modelsim=${ipCoreOutDir}/managed_ip_project/managed_ip_project.cache/compile_simlib/modelsim} {questa=${ipCoreOutDir}/managed_ip_project/managed_ip_project.cache/compile_simlib/questa}] -use_ip_compiled_libs -force -quiet

	close_project
	#touch {.ip.done}
}

#-----------------------------------
set DEBUG_INFO 0

#-----------------------------------
set IP_CFG            [lindex $argv 0]
set IP_OUT            [lindex $argv 1]
set DEVICE            [lindex $argv 2]
set IP_LIB_DIR        [lindex $argv 3]

#-----------------------------------
set CFG_DIR [pwd]

#-----------------------------------
set ipCoreOutDir  $IP_OUT
set ipCoreName    [file rootname [file tail $IP_CFG]]

if { [file exists $ipCoreOutDir]} {
	file delete -force $ipCoreOutDir	
}


#-----------------------------------
source $IP_CFG
if { [dict get [ipInfo] isSynth] } {
	file mkdir $ipCoreOutDir
	ipGenPrologue ${ipCoreName} ${ipCoreOutDir} ${DEVICE} "ipInfo"
	ipCfgPrologue ${ipCoreName} ${ipCoreOutDir}
	ipUserCfg     ${ipCoreName} ${ipCoreOutDir} ${CFG_DIR}
	ipCfgEpilogue ${ipCoreName} ${ipCoreOutDir}
	ipGenEpilogue ${ipCoreName} ${ipCoreOutDir}
	puts "\[XILINX_IP_BLD:INFO\] IP core ${ipCoreName} generated"
} else {
	if { ![info exists ipLibDir] } {
		set ipLibDir ${IP_LIB_DIR}
	}
	file copy ${ipLibDir}/${ipCoreName} ${ipCoreOutDir}
	puts "\[XILINX_IP_BLD:INFO\] IP core ${ipCoreName} copied from ${ipLibDir}"
}

#-----------------------------------
if {$DEBUG_INFO == 1} {
	puts "\[XILINX_IP_BLD:DEBUG\] IP_CFG:           $IP_CFG"
	puts "\[XILINX_IP_BLD:DEBUG\] IP_OUT:           $IP_OUT"
	puts "\[XILINX_IP_BLD:DEBUG\] DEVICE:           $DEVICE"
	puts "\[XILINX_IP_BLD:DEBUG\] IP_LIB_DIR:       $IP_LIB_DIR"
}
