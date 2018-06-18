#*******************************************************************************
#*******************************************************************************


#-------------------------------------------------------------------------------
#     Prj Sctructure Settings
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
set CFG_DIR         "${REF_DIR}/prj/syn/${CfgName}"

set PROLOGUE_SCRIPT "prologue.tcl"

set WaveFileName    ${DesignName} 
append WaveFileName "_wave.do"

set SRC_DIR  ${Src}
set SrcDirs $SRC_DIR
lappend SrcDirs $Lib $Sim

set IncDirs [join [list [join ${SrcDirs} "+"] ${CFG_DIR}] "+"]

set PRJ_NAME   {}
set BUILD_TOOL {}

set VSV_FileList  vsv_src_files.fv;
set VHDL_FileList vhdl_src_files.fv;

#-------------------------------------------------------------------------------
#     Toolchain
#-------------------------------------------------------------------------------

set MENTOR_DIR [file normalize $env(MENTOR)]

set vlog_cmd {}
set vcom_cmd {}
set vopt_cmd {}
set vsim_cmd {}

append vlog_cmd "vlog";
append vcom_cmd "vcom";
append vopt_cmd "vopt";
append vsim_cmd "vsim";

#-------------------------------------------------------------------------------
#     Options
#-------------------------------------------------------------------------------

#--- vlog
set vlog_flags {}
append vlog_flags " -f" " $VSV_FileList";
if {[info exists WorkLib]} {
	append vlog_flags " -work $WorkLib";
}
append vlog_flags " -incr";
append vlog_flags " +incdir+" "$IncDirs";
append vlog_flags " -sv";
append vlog_flags " -O0";            # -O5
append vlog_flags " -mfcu";          # (?) is it reaaly need?

#--- vcom
set vcom_flags {}
append vcom_flags " -f" " $VHDL_FileList";
if {[info exists WorkLib]} {
	append vcom_flags " -work $WorkLib";
}
append vcom_flags " -O0";            # -O5
#append vcom_flags " -refresh";

#--- vopt
set OptimizedDesignName "opt_$DesignName"
set vopt_flags {}
append vopt_flags " " $DesignName
append vopt_flags " -o " $OptimizedDesignName;
if {[info exists WorkLib]} {
	append vopt_flags " -work $WorkLib";
}
append vopt_flags " +acc";          # (!) deprecated - see replacements 
#append vopt_flags " -quiet";

#--- vsim
set vsim_flags {}
if {[info exists WorkLib]} {
	append vsim_flags " -lib $WorkLib";
}
if {[info exists TimeResolution]} {
	append vsim_flags " -t $TimeResolution";
}
append vsim_flags " -wlf func.wlf";
append vsim_flags " -quiet";
append vsim_flags " " $OptimizedDesignName;
#append vsim_flags " +pulse_r/60";  # (?) WTF
#append vsim_flags " +pulse_e/1";   # (?) WTF
#append vsim_flags " -L altera_f";  # for Altera only
#append vsim_flags " -c";           # run simulator in command-line mode

#puts $vcom_flags
#puts $vopt_flags
#puts $vsim_flags

#-------------------------------------------------------------------------------
proc GenCfgFile { CfgDir ScriptDir PrjName BuildTool } {
	upvar 1 $PrjName  prjName
	upvar 1 $BuildTool buildTool
	
	set cfgMakeFile [open [set fileName "$CfgDir/makefile"] r]
	while {[gets $cfgMakeFile line] > -1} {
		if {[regexp {^PRJ_NAME} $line]}  {
			set prjName [lindex [join $line " "] end];
			#puts "D: prjName $prjName";
		}
		if {[regexp {^BUILD_TOOL} $line]}  {
			set buildTool [lindex [join $line " "] end];
			#puts "D: buildTool $buildTool";
		}
	}
	close $cfgMakeFile
	source $ScriptDir/cfg_header_gen.tcl
	cfg_header_gen $prjName $CfgDir $buildTool
}

#-------------------------------------------------------------------------------
proc BuildSrcList { RootDir SrcDirs \
                    { VSV_FileList  vsv_src_files.fv}  \
                    { VHDL_FileList vhdl_src_files.fv} \
                  }                                      {

 set Vext     "v";
 set SVext    "sv";
 set VHDL_ext "vhd";

 set VSV_SrcFiles  {};
 set VHDL_SrcFiles {};

 foreach d $SrcDirs {
  foreach f [glob -nocomplain -directory $d *.$Vext *.$SVext *.$VHDL_ext] {
   set NormSrcFile [file normalize $f];
   if {[file extension $NormSrcFile] == ".vhd"} {
    lappend VHDL_SrcFiles $NormSrcFile;
   } else {
    lappend VSV_SrcFiles $NormSrcFile;
   }
  }
 }

 set VSV_SrcFiles  [join $VSV_SrcFiles "\n"];
 set VHDL_SrcFiles [join $VHDL_SrcFiles "\n"];
 #regsub -all {[\n]+} $SrcFiles "\n" SrcFiles;    # alternative var
 #regsub -all {^[\n]} $SrcFiles "" SrcFiles;      # alternative var

 # puts $VSV_SrcFiles;        # DEBUG
 # puts $VHDL_SrcFiles;       # DEBUG

 if { $VSV_SrcFiles != {} } {
  set fid [open $VSV_FileList w];
  puts $fid $VSV_SrcFiles;
  close $fid
 } else {
  file delete $VSV_FileList;
 }

 if { $VHDL_SrcFiles != {} } {
  set fid [open $VHDL_FileList w];
  puts $fid $VHDL_SrcFiles;
  close $fid
 } else {
  file delete $VHDL_FileList;
 }
}

#-------------------------------------------------------------------------------
proc LaunchCmd { Cmd Args } {
 set io [open "| $Cmd $Args" r]
 puts [read $io];
 if {[catch {close $io} err]} {
  puts "[file tail $Cmd] report error: $err"
  return 0;
 }
 return 1;
}

#-------------------------------------------------------------------------------
proc Compile {} {
 global REF_DIR SrcDirs;

 global VSV_FileList;
 global VHDL_FileList;

 global vlog_cmd vlog_flags;
 global vcom_cmd vcom_flags;
 global vopt_cmd vopt_flags;

 BuildSrcList ${REF_DIR} ${SrcDirs};

 if { [file exists $VSV_FileList] } {
  if {[LaunchCmd $vlog_cmd $vlog_flags] == 0} {
   return;
  }
 }

 if { [file exists $VHDL_FileList] } {
  if {[LaunchCmd $vcom_cmd $vcom_flags] == 0} {
   return;
  }
 }

 if {[LaunchCmd $vopt_cmd $vopt_flags] == 0} {
  return;
 }
}

#-------------------------------------------------------------------------------
proc SimBegin { } {
 global vsim_cmd vsim_flags;

 quit -sim;

 global StdArithNoWarnings;
 global NumericStdNoWarnings;

 set cmd [concat $vsim_cmd $vsim_flags];
 eval $cmd
 radix -hex
 log -r *

 puts "StdArithNoWarnings   = $StdArithNoWarnings"
 puts "NumericStdNoWarnings = $NumericStdNoWarnings"
}

#-------------------------------------------------------------------------------
proc c { } {
 Compile;
}

#-------------------------------------------------------------------------------
proc s { { wave_ena 1 } } {
 global WaveFileName;
 SimBegin;

 if { $wave_ena != 0} {
	do $WaveFileName
 }
 run -all
 if { $wave_ena != 0} {
	view wave
 }
}

#-------------------------------------------------------------------------------
proc r { { wave_ena 1 } } {
 restart -force
 run -all
 if { $wave_ena != 0} {
	view wave
 }
 view transcript
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-----------------------------------
GenCfgFile ${CFG_DIR} ${SCRIPT_DIR} PRJ_NAME BUILD_TOOL

#-----------------------------------
if {[file exists ${CFG_DIR}/${PROLOGUE_SCRIPT}] == 1} {
	source ${CFG_DIR}/${PROLOGUE_SCRIPT}
}

if {$argc > 0} {
 set cmd_arg [lindex $argv 0];
 
 switch   $cmd_arg {
  "-c" {
   puts "Compile project"
   Compile
  }
  default {
   puts "Unrecognized command $cmd_arg"
  }
 }
 #puts " Args $argc are: $cmd_arg"
}



