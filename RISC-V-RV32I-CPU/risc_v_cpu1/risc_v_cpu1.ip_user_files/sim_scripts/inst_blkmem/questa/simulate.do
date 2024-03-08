onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib inst_blkmem_opt

do {wave.do}

view wave
view structure
view signals

do {inst_blkmem.udo}

run -all

quit -force
