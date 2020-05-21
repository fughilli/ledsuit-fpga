#!/bin/bash
#
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
#

function program()
{
    mojo-loader -i build/design.bit -r -p -d /dev/serial/by-id/usb-Embedded_Micro_Mojo_V3-if00
}

function flash()
{
    mojo-loader -i build/design.bit -p -d /dev/serial/by-id/usb-Embedded_Micro_Mojo_V3-if00
}

for arg in $@
do

    if [[ $arg == "-p" ]]
    then
        program
    fi

    if [[ $arg == "-f" ]]
    then
        flash
    fi

done
