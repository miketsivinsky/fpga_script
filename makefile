#--------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------
LED_BLINK_ALTERA_SOC  := ../src/-cfg/altera_SoC
LED_BLINK_ALTERA_DE1  := ../src/-cfg/altera_DE1
LED_BLINK_XILINX_ARTY := ../src/-cfg/xilinx_Arty

TQ1M_ALTERA_SOC  := ../test/tq1m/-syn/-cfg/altera_SoC
TQ1M_ALTERA_DE1  := ../test/tq1m/-syn/-cfg/altera_DE1


#------------------------------------------------------------------------------
#TRG_LIST := LED_BLINK_ALTERA_SOC LED_BLINK_ALTERA_DE1 LED_BLINK_XILINX_ARTY
TRG_LIST := TQ1M_ALTERA_SOC TQ1M_ALTERA_DE1
#TRG_LIST := TQ1M_ALTERA_SOC

#------------------------------------------------------------------------------
ifeq ($(MAKECMDGOALS),)
 GOALS := all
else
 GOALS := $(MAKECMDGOALS)
endif

#------------------------------------------------------------------------------
ifeq ($(GOALS),$(filter $(GOALS), all build_prj))
 define make_call
  @taskkill /FI "WINDOWTITLE eq $(strip $(1))" > nul
  @cd $(abspath $(2)) && cmd /C start "$(strip $(1))" cmd /T:87 /K make $(3)
 endef
else 
 define make_call
  @taskkill /FI "WINDOWTITLE eq $(strip $(1))" > nul
  @cd $(abspath $(2)) && make $(3)
 endef
endif

#------------------------------------------------------------------------------
$(GOALS): 
	$(foreach TRG, $(TRG_LIST), $(call make_call, $(TRG),$($(TRG)), $(GOALS) ) & )	

#------------------------------------------------------------------------------
#build_test:
#	taskkill /FI "WINDOWTITLE eq LED_BLINK_ALTERA_DE1" > nul
#	cd $(LED_BLINK_ALTERA_DE1) && cmd /C start "LED_BLINK_ALTERA_DE1" cmd /T:87 /K make test
#	taskkill /FI "WINDOWTITLE eq LED_BLINK_ALTERA_SOC" > nul
#	cd $(LED_BLINK_ALTERA_SOC) && cmd /C start "LED_BLINK_ALTERA_SOC" cmd /T:87 /K make test

