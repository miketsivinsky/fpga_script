#------------------------------------------------------------------
transcript quietly

set envList { \
               DISABLE_ELAB_DEBUG     \
               DOPATH                 \
               DP_INFILE              \
               EDITOR                 \
               HOME                   \
               ITCL_LIBRARY           \
               ITK_LIBRARY            \
               LD_LIBRARY_PATH        \
               LD_LIBRARY_PATH_32     \
               LD_LIBRARY_PATH_64     \
               LM_LICENSE_FILE        \
               MGC_AMS_HOME           \
               MGC_HOME               \
               MGC_LOCATION_MAP       \
               MGC_WD                 \
               MODEL_TECH             \
               MODEL_TECH_OVERRIDE    \
               MODEL_TECH_TCL         \
               MODELSIM               \
               MODELSIM_PREFERENCES   \
               MODELSIM_TCL           \
               MTI_COSIM_TRACE        \
               MTI_LIB_DIR            \
               MTI_LIBERTY_PATH       \
               MTI_TF_LIMIT           \
               MTI_RELEASE_ON_SUSPEND \
               MTI_USELIB_DIR         \
               MTI_VCO_MODE           \
               NOMMAP                 \
               PLIOBJS                \
               STDOUT                 \
               TCL_LIBRARY            \
               TK_LIBRARY             \
               TMP                    \
               TMPDIR                 \
               VSIM_LIBRARY           \
               MGLS_LICENSE_FILE      \
            };

#puts "[llength $envList] \n";

puts "------------------------------------------------------------------------------- \n";
set envVarIdx 0
foreach envVar $envList {
	incr envVarIdx
	if {[info exists env($envVar)]} {
		puts [format "%2d %-30s %-20s" $envVarIdx $envVar $env($envVar)]
	} else {
		if {[info exists $envVar]} {
			puts [format "%2d %-30s %-10s %-10s" $envVarIdx $envVar [subst $$envVar] "(Note: Tcl variable)"]
		} else {
			puts [format "%2d %-30s %-20s" $envVarIdx $envVar "*** not exist"]
                }
	}
}

