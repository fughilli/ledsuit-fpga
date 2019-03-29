# LED Suit FPGA Component

This repo contains the Verilog implementation of a multi-channel WS2812B
addressable LED strip driver. The driver exposes a SPI slave interface at one
end, and multiple pulse-width encoded data output ports at the other. The SPI
interface is intended to be connected to a host which performs the rendering for
the LED strips. The host blits raster image data into the FPGA block ram using
the SPI interface, and the LED strip driver blocks read segments of that color
data out of the block RAM to drive the output ports.

A true dual-port block RAM for Spartan6 is used in this implementation, and the
`const.ucf` is configured for the MojoV3 board. However, other Spartan6 boards
should be supported with a little modification, and even other FPGAs should be
usable with a bit more work.

## Building

To build the bitstream, first ensure that you have `ninja-build`,
[`mojo-loader`](https://github.com/embmicro/mojo-loader) and the Xilinx ISE
toolchain installed. You will also need to add the Xilinx ISE bin directory to
your `PATH`.

Once you have the dependencies, simply run:

```
./configure.py
```

followed by:

```
ninja
```

To program the MojoV3 with the bitstream temporarily, invoke:

```
./program.sh -p
```

To flash the MojoV3 onboard EEPROM with the bitstream, invoke:

```
./program.sh -f
```
