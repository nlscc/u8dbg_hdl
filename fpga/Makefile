# vim: noexpandtab

# this file is a wrapper around the Xilinx 'vivado' utility
# it lets us easily re-run the build if any files have changed
# and tries to block the WebTalk telemetry engine

VIVADO = vivado
# alternatively, use unshare -n -r (if you have user namespaces on)
NONET = bwrap --bind / / --dev /dev --unshare-net

VERILOG_FILES := $(wildcard *.v */*.v)

u8dbg.bit: $(VERILOG_FILES) board.xdc
	$(NONET) $(VIVADO) -mode batch -source build.tcl
	rm -rf *.jou *.log .Xil # clean up after vivado
	rm -f usage_statistics_webtalk.html usage_statistics_webtalk.xml

.PHONY: clean
clean:
	rm -rf *.jou *.log .Xil # in case they weren't removed before
	rm -f usage_statistics_webtalk.html usage_statistics_webtalk.xml
	rm -f u8dbg.bit
