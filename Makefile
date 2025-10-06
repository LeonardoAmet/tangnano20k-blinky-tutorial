# SPDX-License-Identifier: MIT
# ==========================================================

# Makefile - Tang Nano 20K Blink (OSS CAD Suite + Apicula)

# Estructura con directorios build/ y bit/

# ==========================================================

# --- Dispositivo / familia / board ---

DEVICE   := GW2AR-LV18QN88C8/I7
FAMILY   := GW2A-18C
BOARD    := tangnano20k

# --- Directorios ---

SRC_DIR  := src
CST_DIR  := constraints
BUILD    := build
BIT      := bit

# --- Top y fuentes ---

TOP      := blinky
SRC      := $(SRC_DIR)/$(TOP).v
CST      := $(CST_DIR)/tangnano20k.cst

# --- Herramientas ---

YOSYS    := yosys
NEXTPNR  := nextpnr-himbaechel
PACKER   := gowin_pack
PROG     := openFPGALoader

# --- Artefactos ---

JSON_SYN := $(BUILD)/$(TOP)_synth.json
JSON_PNR := $(BUILD)/$(TOP)_pnr.json
FS       := $(BIT)/$(TOP).fs

.PHONY: all bit synth pnr pack flash clean dirs

all: bit

bit: dirs synth pnr pack

# 1) Síntesis (Yosys)


$(JSON_SYN): $(SRC)
	@echo "\n[ YOSYS ] Síntesis HDL -> JSON"
	$(YOSYS) -p "read_verilog $(SRC); synth_gowin -family gw2a -top $(TOP) -json $(JSON_SYN)"

synth: $(JSON_SYN)

# 2) Place & Route (nextpnr-himbaechel)

$(JSON_PNR): $(JSON_SYN) $(CST)
	@echo "\n[ NEXTPNR ] Colocación y ruteo"
	$(NEXTPNR) --json $(JSON_SYN) --write $(JSON_PNR) \
		--device $(DEVICE) \
		--vopt family=$(FAMILY) \
		--vopt cst=$(CST)

pnr: $(JSON_PNR)

# 3) Empaquetar bitstream (gowin_pack)

$(FS): $(JSON_PNR)
	@echo "\n[ GOWIN_PACK ] Generando $(FS)"
	$(PACKER) -d $(FAMILY) -o $(FS) $(JSON_PNR)

pack: $(FS)

# 4) Programar FPGA (openFPGALoader)

flash: $(FS)
	@echo "\n[ PROGRAMACIÓN FPGA ]"
	$(PROG) -b $(BOARD) $(FS)

# Directorios necesarios

dirs:
	@mkdir -p $(SRC_DIR) $(CST_DIR) $(BUILD) $(BIT)

# Limpieza

clean:
	rm -rf $(BUILD) $(BIT)
	@echo "\n[ CLEAN ] Archivos temporales eliminados."
# ==========================================================