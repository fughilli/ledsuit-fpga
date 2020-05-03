#!/usr/bin/python

from ninja_syntax import Writer
import os
import sys
import re

## CONFIGURATION ##
source_dirs = ["."]
source_ext = [(".v", "verilog")]
constraint_file = "pins.pcf"
top_file_suffix = "ice40_top"

build_dir = "build"

device = "8k"
device_type = "lp8k"
clock_constraint_mhz = 16
package = "cm81"

exclude_patterns = [".*mojo.*", ".*test.*"]


def bdir(f):
    return os.path.join(build_dir, f)

## CONFIGURE BUILD ##


def mkdir_if_ne(d):
    '''Make a directory if it doesn't exist'''
    if not os.path.exists(d):
        os.mkdir(d)


def check_source_ext(s):
    '''Check that a source has a valid source extension'''
    return reduce(lambda a, b: a or b, [s.endswith(ext[0]) for ext in
                                        source_ext])

def filter_source(s):
    if not check_source_ext(s):
        return False
    for exclude_pattern in exclude_patterns:
        if re.match(exclude_pattern, s):
            return False
    return True


def source_type(s):
    '''Get the source type for a given source file'''
    for ext in source_ext:
        if s.endswith(ext[0]) and ext[1] is not None:
            return ext[1]
    return None


def find_top(ss):
    '''Find the topfile from the sources list'''
    for s in ss:
        if os.path.splitext(s)[0].endswith(top_file_suffix):
            return s
    return None


# Create working directories
mkdir_if_ne(build_dir)

## Collect the sources list
sources = reduce(lambda a, b: a+b, [filter(filter_source,
                                           os.listdir(source_dir)) for source_dir in source_dirs])

## Identify toplevel design file
topfile = find_top(sources)

with open("build.ninja", "w") as buildfile:
    n = Writer(buildfile)

    n.variable("builddir", build_dir)
    n.variable("const", constraint_file)
    n.variable("device", device)
    n.variable("device_type", device_type)
    n.variable("package", package)
    n.variable("clock_constraint_mhz", clock_constraint_mhz)
    n.variable("topfile", topfile)
    n.variable("top_module", os.path.splitext(topfile)[0])
    n.variable("sources", ' '.join(sources))

    n.rule("cpbuild", "cp $in $out")

    n.rule("synthesize", "(cd $builddir; yosys -ql hardware.log -p 'synth_ice40 -top $top_module -blif hardware.blif; write_verilog optimized.v' $sources)")
    n.rule("par", "(cd $builddir; arachne-pnr -d $device -P $package -o hardware.asc -p $const hardware.blif)")
    n.rule("timing", "(cd $builddir; icetime -d $device_type -c $clock_constraint_mhz -mtr hardware.rpt hardware.asc)")
    n.rule("bitgen", "(cd $builddir; icepack hardware.asc hardware.bin)")

    for f in sources + [constraint_file]:
        n.build(os.path.join(build_dir, f), "cpbuild", f)
    n.build("${builddir}/hardware.blif", "synthesize", sources)
    n.build("${builddir}/hardware.asc", "par",
            ["${builddir}/${const}", "${builddir}/hardware.blif"])
    n.build("${builddir}/hardware.rpt", "timing", ["${builddir}/hardware.asc"])
    n.build("${builddir}/hardware.bin", "bitgen",
            ["${builddir}/hardware.asc", "${builddir}/hardware.rpt"])
