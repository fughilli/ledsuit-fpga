
# LED Suit FPGA Implementation - Multi-output addressable LED driver HDL
# implementation for Kevin's LED suit controller.
# Copyright (C) 2019-2020 Kevin Balke
#
# This file is part of LED Suit FPGA Implementation.
#
# LED Suit FPGA Implementation is free software: you can redistribute it and/or
# modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LED Suit FPGA Implementation is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LED Suit FPGA Implementation.  If not, see
# <http://www.gnu.org/licenses/>.

from __future__ import print_function

import jinja2
import os
import re

SEARCH_PATH = './'
TEMPLATE_FILE_REGEX = re.compile(
    '(?P<basename>.*)\.template\.(?P<extension>[A-Za-z0-9])$')


def MakeExportName(groupdict):
    return groupdict['basename'] + '.' + groupdict['extension']

def GetTemplateMapping():
    all_filenames = os.listdir(SEARCH_PATH)

    print(all_filenames)

    mapping = []

    for filename in all_filenames:
        match = TEMPLATE_FILE_REGEX.match(filename)
        if match:
            mapping.append((filename, MakeExportName(match.groupdict())))

    return mapping


if __name__ == '__main__':
    loader = jinja2.FileSystemLoader(searchpath=SEARCH_PATH)
    env = jinja2.Environment(loader=loader)
    env.trim_blocks = True
    env.lstrip_blocks = True
    env.strip_trailing_newlines = False

    for input_name, output_name in GetTemplateMapping():
        print("Transforming", input_name, "-->", output_name)
        template = env.get_template(input_name)
        rendered_template = template.render()
        with open(output_name, 'w') as output_file:
            output_file.write(rendered_template)
