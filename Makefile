IVERILOG ?= iverilog
IVERILOG_FLAGS ?= -Wall -g2012
VVP ?= vvp
BUILD_DIR ?= build

.PHONY: all test test-alu test-register-file test-top clean

all: test

test: test-alu test-register-file test-top

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

test-alu: $(BUILD_DIR)/alu_tb
	$(VVP) $(BUILD_DIR)/alu_tb

test-register-file: $(BUILD_DIR)/register_file_tb
	$(VVP) $(BUILD_DIR)/register_file_tb

test-top: $(BUILD_DIR)/top_tb
	$(VVP) $(BUILD_DIR)/top_tb

$(BUILD_DIR)/alu_tb: src/alu.v tb/alu_tb.v | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ src/alu.v tb/alu_tb.v

$(BUILD_DIR)/register_file_tb: src/register_file.v tb/register_file_tb.v | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ src/register_file.v tb/register_file_tb.v

$(BUILD_DIR)/top_tb: src/*.v tb/top_tb.v | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ src/*.v tb/top_tb.v

clean:
	rm -rf $(BUILD_DIR) waveform.vcd
