#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
CFG_NAME        := $(notdir $(CURDIR))
SCRIPT_DIR      := $(REF_DIR)/script
BIN_DIR         := $(REF_DIR)/bin

OUT_DIR         := $(SRC_DIR)/-out
OUT_CFG_DIR     := $(OUT_DIR)/$(CFG_NAME)

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
ifeq ($(QUARTUS),16.1)
 QUARTUS_BIN_DIR := D:/CAD/Altera/16.1/quartus/bin64
else ifeq ($(QUARTUS),12.1)
 QUARTUS_BIN_DIR := D:/CAD/Altera/12.1/quartus/bin64
else
 $(error Incorrect Quartus toolchain)
endif

QUARTUS_SHELL    := quartus_sh
QUARTUS_PGM      := quartus_pgm
PRJ_GEN_SCRIPT   := altera_prj_gen.tcl
PRJ_BUILD_SCRIPT := altera_prj_build.tcl

#------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
 fixPath = $(subst /,\,$1)
else
 fixPath = $1
endif

SRC_DIR     := $(abspath $(SRC_DIR))
OUT_DIR     := $(call fixPath, $(OUT_DIR))
OUT_CFG_DIR := $(call fixPath, $(OUT_CFG_DIR))
BIN_DIR     := $(call fixPath, $(abspath $(BIN_DIR)))

#------------------------------------------------------------------------------
ifndef PRJ_NAME
	PRJ_NAME := $(notdir $(SRC_DIR))
endif

TARGET_FILE_NAME := $(PRJ_NAME)-$(CFG_NAME)


#------------------------------------------------------------------------------
INC            := $(abspath $(INC)) 
SRC            := $(abspath $(SRC)) 

SRC_DEPS       := $(call fixPath, $(SRC)) $(call fixPath, $(INC)) $(call fixPath, $(SDC))
QSF_FILE       := $(call fixPath, $(abspath $(OUT_CFG_DIR)/$(TARGET_FILE_NAME).qsf)) 
SOF_FILE       := $(call fixPath, $(abspath $(OUT_CFG_DIR)/$(TARGET_FILE_NAME).sof)) 
TRG_FILE       := $(call fixPath, $(abspath $(BIN_DIR)/$(TARGET_FILE_NAME).sof)) 
ABS_SCRIPT_DIR := $(call fixPath, $(abspath $(SCRIPT_DIR)))

CMD_DEPS     := $(SCRIPT_DIR)/altera.mk makefile
CMD_DEPS_PRJ := $(SCRIPT_DIR)/altera_prj_gen.tcl groups.tcl settings.tcl signals.tcl
CMD_DEPS_BLD := $(SCRIPT_DIR)/altera_prj_build.tcl

ifneq ($(wildcard cfg_params.tcl),)
 CMD_DEPS_PRJ := $(CMD_DEPS_PRJ) cfg_params.tcl
endif

#------------------------------------------------------------------------------
.PHONY: all prg_sof build_prj create_prj clean clean_all print-% test

all:    build_prj

prg_sof: $(TARGET_FILE_NAME).cdf $(TRG_FILE)
	$(QUARTUS_BIN_DIR)/$(QUARTUS_PGM) --cable $(DEV) $(TARGET_FILE_NAME).cdf

build_prj:  $(TRG_FILE)

create_prj: $(QSF_FILE)

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


$(TRG_FILE): $(SOF_FILE)
	@if not exist $(BIN_DIR) mkdir $(BIN_DIR)	
	@if exist $(TRG_FILE) del /Q/ F $(TRG_FILE)	
	copy $(SOF_FILE) $(TRG_FILE) > nul

$(SOF_FILE): $(QSF_FILE) $(CMD_DEPS) $(CMD_DEPS_BLD) $(CMD_DEPS_PRJ)
	$(QUARTUS_BIN_DIR)/$(QUARTUS_SHELL) -t $(SCRIPT_DIR)/$(PRJ_BUILD_SCRIPT) $(OUT_CFG_DIR) $(PRJ_NAME) $(TARGET_FILE_NAME)

$(QSF_FILE): $(SRC_DEPS) $(CMD_DEPS) $(CMD_DEPS_PRJ)
	@if not exist $(OUT_DIR) mkdir $(OUT_DIR)	
	@if exist $(OUT_CFG_DIR) rmdir /s/q $(OUT_CFG_DIR)	
	mkdir $(OUT_CFG_DIR)
	$(QUARTUS_BIN_DIR)/$(QUARTUS_SHELL) -t $(SCRIPT_DIR)/$(PRJ_GEN_SCRIPT) $(SRC_DIR) $(OUT_CFG_DIR) $(PRJ_NAME) $(TARGET_FILE_NAME) $(SRC) $(SDC)
	
