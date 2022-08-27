#!/usr/bin/python3

import re
import os

X=0
Y=1

# We place a 40um halo around the macros, so if we place the macros 40um
# in from the edges we will allow some space for routing external I/Os on
# the periphery while still preventing any standard cells from being laid
# down
horizontal_margin = 40
vertical_margin   = 40

horizontal_placement = 0.46
vertical_placement = 2.72

# Wrapper size
die_size   = (2920, 3520)

r = re.compile('SIZE\s+([0-9\.]+) BY ([0-9\.]+) ;')

def get_macro_size(name):
    lef_file = os.path.dirname(os.path.abspath(__file__)) + '/../../../lef/' + name + '.lef'
    with open(lef_file) as f:
        for line in f:
            m = r.search(line)
            if m:
                lx = float(m.group(1))
                ly = float(m.group(2))
                return (lx, ly)

def align(size, align_val):
    multiple = int((size+align_val)/align_val)
    return multiple*align_val

def align_down(size, align_val):
    multiple = int(size/align_val)
    return multiple*align_val

def align_h(size):
    return align(size, horizontal_placement)

def align_v(size):
    return align(size, vertical_placement)

def align_h_down(size):
    return align_down(size, horizontal_placement)

def align_v_down(size):
    return align_down(size, vertical_placement)

# Macro sizes
ram512 = get_macro_size('RAM512')
ram32_1rw1r = get_macro_size('RAM32_1RW1R')
multiply_add_64x64 = get_macro_size('multiply_add_64x64')
microwatt_fp_dffrfile = get_macro_size('Microwatt_FP_DFFRFile')

# Macro layout

# RAM at top
ram_l =            (align_h((die_size[X]-ram512[X])/2),                                   align_v_down(die_size[Y]-ram512[Y]-vertical_margin))

# cache RAMs at bottom - need a bigger margin because there are a lot of wires
icache_ram_1_l =   (align_h(horizontal_margin),                                           align_v(vertical_margin))
dcache_ram_1_l =   (align_h_down(die_size[X]-ram32_1rw1r[X]-horizontal_margin),           align_v(vertical_margin))

cache_end_y = icache_ram_1_l[Y]+ram32_1rw1r[Y]
middle_y = (ram_l[Y]-cache_end_y)/2 + cache_end_y

# Multipliers and regfile in middle
multiplier_l =     (align_h(horizontal_margin),                                           align_v(cache_end_y + 300))
multiplier_fpu_l = (align_h(horizontal_margin),                                           align_v(ram_l[Y]-multiply_add_64x64[Y]-300))
regfile_l =        (align_h_down(die_size[X]-microwatt_fp_dffrfile[X]-horizontal_margin), align_v(middle_y - microwatt_fp_dffrfile[Y]/2))

print('microwatt_0.soc0.bram_bram0.ram_0.memory_0                  %8.3f %8.3f N' % ram_l)
print('microwatt_0.soc0.processor.dcache_0.rams_n1_way.cache_ram_0 %8.3f %8.3f N' % icache_ram_1_l)
print('microwatt_0.soc0.processor.icache_0.rams_n1_way.cache_ram_0 %8.3f %8.3f N' % dcache_ram_1_l)
print('microwatt_0.soc0.processor.execute1_0.multiply_0.multiplier %8.3f %8.3f N' % multiplier_l)
print('microwatt_0.soc0.processor.with_fpu_fpu_0.fpu_multiply_0.multiplier %8.3f %8.3f N' % multiplier_fpu_l)
print('microwatt_0.soc0.processor.register_file_0.register_file_0  %8.3f %8.3f N' % regfile_l)
