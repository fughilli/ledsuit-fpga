import os, sys

width = int(sys.argv[1])
select_wire = sys.argv[2]
input_wire = sys.argv[3]
output_wire = sys.argv[4]

def ternary(cond, lop, rop):
    return "((%s) ? (%s) : (%s))" % (cond, lop, rop)

def compare(lop, rop):
    return "((%s) == (%s))" % (lop, rop)

def wrap_value(value, width):
    return "%d'%s" % (width, bin(value)[1:])

def select(vector, index):
    return "%s[%s]" % (vector, index)

def generate_selector(width, selector, input_vector, output):
    selector_options = zip([wrap_value(1 << _, width) for _ in range(0, width)], range(0, width))
    return generate_selector_helper(selector_options, selector, input_vector, output)

def generate_selector_helper(selector_options, selector, input_vector, output):
    mask, index = selector_options[0]
    if (len(selector_options) == 1):
        return select(input_vector, index)

    return ternary(compare(mask, selector), ("%s[%s]" % (input_vector, index)),generate_selector_helper(selector_options[1:], selector, input_vector, output))

#print generate_selector(5, "select", "arb_input", "arb_output")
print generate_selector(width, select_wire, input_wire, output_wire)
