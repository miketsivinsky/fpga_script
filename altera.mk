#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
CFG_NAME        := $(notdir $(CURDIR))
SCRIPT_DIR      := $(REF_DIR)/script
BIN_DIR         := $(REF_DIR)/bin

OUT_DIR         := $(SRC_DIR)/-out
OUT_CFG_DIR     := $(OUT_DIR)/$(CFG_NAME)

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
PRJ_GEN_SCRIPT := altera_prj_gen.tcl
OUT_GEN_SCRIPT := altera_prj_build.tcl


#------------------------------------------------------------------------------
ifeq ($(QUARTUS),16.1)
 SHELL_DIR := D:/CAD/Altera/16.1/quartus/bin64
else ifeq ($(QUARTUS),12.1)
 SHELL_DIR := D:/CAD/Altera/12.1/quartus/bin64
else
 $(error Incorrect Quartus toolchain)
endif

#------------------------------------------------------------------------------
PRJ_SHELL          := quartus_sh
PGM_SHELL          := quartus_pgm

#------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
 fixPath = $(subst /,\,$1)
else
 fixPath = $1
endif

#------------------------------------------------------------------------------
SRC_DIR     := $(abspath $(SRC_DIR))
OUT_DIR     := $(call fixPath, $(OUT_DIR))
OUT_CFG_DIR := $(call fixPath, $(OUT_CFG_DIR))
BIN_DIR     := $(call fixPath, $(abspath $(BIN_DIR)))
SCRIPT_DIR  := $(call fixPath, $(abspath $(SCRIPT_DIR)))

#------------------------------------------------------------------------------
PRJ_FILE_CMD_LINE := -t $(SCRIPT_DIR)/$(PRJ_GEN_SCRIPT)
OUT_FILE_CMD_LINE := -t $(SCRIPT_DIR)/$(OUT_GEN_SCRIPT)
DEV_PGM_CMD_LINE  := --cable

#------------------------------------------------------------------------------
ifndef PRJ_NAME
	PRJ_NAME := $(notdir $(SRC_DIR))
endif

#------------------------------------------------------------------------------
PRJ_FILE_NAME    := $(PRJ_NAME)-$(CFG_NAME)
OUT_FILE_NAME    := $(PRJ_NAME)-$(CFG_NAME)
TARGET_FILE_NAME := $(PRJ_NAME)-$(CFG_NAME)


#------------------------------------------------------------------------------
INC            := $(abspath $(INC)) 
SRC            := $(abspath $(SRC)) 

SRC_DEPS       := $(call fixPath, $(SRC)) $(call fixPath, $(INC)) $(call fixPath, $(SDC))
PRJ_FILE       := $(call fixPath, $(abspath $(OUT_CFG_DIR)/$(PRJ_FILE_NAME).qsf)) 
OUT_FILE       := $(call fixPath, $(abspath $(OUT_CFG_DIR)/$(OUT_FILE_NAME).sof)) 
TRG_FILE       := $(call fixPath, $(abspath $(BIN_DIR)/$(TARGET_FILE_NAME).sof)) 

CMD_DEPS     := $(SCRIPT_DIR)/altera.mk makefile
CMD_DEPS_PRJ := $(SCRIPT_DIR)/altera_prj_gen.tcl $(SCRIPT_DIR)/cfg_header_gen.tcl groups.tcl settings.tcl signals.tcl
CMD_DEPS_BLD := $(SCRIPT_DIR)/altera_prj_build.tcl
CMD_DEPS_PRG := 

ifneq ($(wildcard cfg_params.tcl),)
 CMD_DEPS_PRJ := $(CMD_DEPS_PRJ) cfg_params.tcl
endif

#------------------------------------------------------------------------------
.PHONY: all dev_pgm build_prj create_prj clean clean_all print-% test

all:    build_prj

dev_pgm: $(TARGET_FILE_NAME).cdf $(TRG_FILE) $(CMD_DEPS_PRG)
	$(SHELL_DIR)/$(PGM_SHELL) $(DEV_PGM_CMD_LINE) $(DEV) $(TARGET_FILE_NAME).cdf



build_prj:  $(TRG_FILE)

create_prj: $(PRJ_FILE)

clean:
	@if exist $(OUT_CFG_DIR) rmdir /s/q $(OUT_CFG_DIR)	
	@if exist $(TRG_FILE) del /F /Q $(TRG_FILE)

clean_all:
	@if exist $(OUT_DIR) rmdir /s/q $(OUT_DIR)	
	@if exist $(BIN_DIR) rmdir /s/q $(BIN_DIR)	
	       
print-%:
	@echo $* = $($*)

test:
	@echo test $(TARGET_FILE_NAME)	

#------------------------------------------------------------------------------
$(TRG_FILE): $(OUT_FILE)
	@if not exist $(BIN_DIR) mkdir $(BIN_DIR)	
	@if exist $(TRG_FILE) del /Q/ F $(TRG_FILE)	
	@copy $(OUT_FILE) $(TRG_FILE) > nul


$(OUT_FILE): $(PRJ_FILE) $(CMD_DEPS) $(CMD_DEPS_BLD) $(CMD_DEPS_PRJ)
	$(SHELL_DIR)/$(PRJ_SHELL)  $(OUT_FILE_CMD_LINE) $(OUT_CFG_DIR) $(PRJ_FILE_NAME)


$(PRJ_FILE): $(SRC_DEPS) $(CMD_DEPS) $(CMD_DEPS_PRJ)
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)	
	@if exist $(OUT_CFG_DIR) rmdir /s/q $(OUT_CFG_DIR)	
	mkdir $(OUT_CFG_DIR)
	$(SHELL_DIR)/$(PRJ_SHELL) $(PRJ_FILE_CMD_LINE) $(SCRIPT_DIR) $(SRC_DIR) $(OUT_CFG_DIR) $(PRJ_NAME) $(PRJ_FILE_NAME) $(SRC) $(SDC)
