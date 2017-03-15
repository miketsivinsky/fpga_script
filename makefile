#--------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------
LED_BLINK_ALTERA_SOC := ../src/-cfg/altera_SoC/
LED_BLINK_ALTERA_DE1 := ../src/-cfg/altera_DE1/

#------------------------------------------------------------------------------
.PHONY: all  print-%


all:	$(LED_BLINK_ALTERA_SOC)  $(LED_BLINK_ALTERA_DE1)

print-%:
	@echo $* = $($*)

#------------------------------------------------------------------------------
$(LED_BLINK_ALTERA_SOC): $(LED_BLINK_ALTERA_SOC)/makefile
	cd $(LED_BLINK_ALTERA_SOC) && cmd /C start make all

$(LED_BLINK_ALTERA_DE1): $(LED_BLINK_ALTERA_DE1)/makefile
	cd $(LED_BLINK_ALTERA_DE1) && cmd /C start make all

