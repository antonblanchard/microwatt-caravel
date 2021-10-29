# Microwatt Tests

To run these you need icarus verilog, and a ppc64le toolchain. On Fedora
these are available as packages:

```
sudo dnf install iverilog gcc-powerpc64le-linux-gnu
```

And on Ubuntu:

```
sudo apt install iverilog gcc-powerpc64le-linux-gnu
```

The test cases need a path to the PDK, eg:

```
make PDK_PATH=/home/anton/pdk/sky130A
```

## minimal
This is probably where you should start. This is a minimal test that verifies
that Microwatt is running. The SPI flash controller is lightly tested because
Microwatt uses it to fetch instructions for the test case. The GPIO macro
is also lightly tested because Microwatt uses that to signal back to the
management engine that it is alive.

## jtag
This reads the IDCODE register out of the Microwatt JTAG TAP interface.

## uart
A simple UART test where we send a character to Microwatt and it echoes it back.

## spi_flash
Before starting flash is initialized with a hash of the offset. The test case
then does reads at various offsets and checks if the values returned are
correct.

## memory_test
A simple memory tester. Writes hashes of the offset of memory into memory,
then reads them back.
