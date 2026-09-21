# pico-xb80

pico-xb80 is a small expansion-bus interface for 1970s and 1980s desktop machines, designed to allow a Raspberry Pi Pico 2 board to present an SD card-backed storage device to a Sharp MZ80K system.

## Supported hardware

Currently supported:

* [Sharp MZ80K](https://en.wikipedia.org/wiki/Sharp_MZ)

Possible future targets with additional effort:

* [Tandy TRS-80 and clones](https://en.wikipedia.org/wiki/List_of_TRS-80_clones)

## What it does

The project uses a Pico 2 board and an SD card to provide a file system to the Sharp MZ80K through the expansion bus. A small monitor ROM extension and host-side software allow the machine to access files stored on an SD card in a way that is compatible with the existing monitor and tape-handling model.

The software stack includes:

* 1-bit SD card interface support for the Pico 2 board configuration used here
* `fatfs` by ChaN
* a custom expansion-bus implementation using the Pico PIO and DMA subsystems
* Sharp MZ80K-specific glue logic and ROM support for monitor commands such as `*FD`

## Hardware overview

Off-the-shelf components are used to keep the project accessible and inexpensive.

* Raspberry Pi Pico 2 / RP2350B mounted on an [Olimex Pico2-XXL](https://www.olimex.com/Products/RaspberryPi/PICO/PICO2-XXL/open-source-hardware)
* SD card socket mounted on the board
* Ribbon cable and jumper wires to connect the bus to the computer
  * Sharp MZ80K uses a [50-way ribbon cable](https://www.google.com/search?q=50+way+ribbon+cable)
  * [DuPont or similar jump wires](https://en.wikipedia.org/wiki/Jump_wire)

This is a prototype-style design intended to be simple to build and experiment with. A dedicated single-board version may be possible in the future, but the current approach uses the Olimex board for flexibility.

## Development environment

The project is built and developed with:

* VS Code
* Raspberry Pi Pico SDK
* Git - [git in VSCode](https://code.visualstudio.com/docs/sourcecontrol/overview) 
* Python 3

### Z80 code tooling

> Important: you will need to build your own copy of `sjasmplus` for your platform.

The repository includes support for:

* [sjasmplus](https://github.com/z00m128/sjasmplus) for assembling Z80 code into machine-code binaries
* `bin2header.py` to convert binary output into a C header suitable for inclusion in the Pico firmware

## Utility tools

The project includes a small set of helper scripts for working with Sharp MZ80K file images:

* `filehandle_path.py` — scans a Sharp MZ80K binary for tape-handler calls and rewrites them to use the SD-backed handlers
* `mz_tape_info.py` — inspects file images and reports the file type plus whether they have already been patched

# Build and upload

## Wiring

Only the right-hand column of pins is used from EXT1 and EXT2 on the Olimex board.

<div style="display: flex; gap: 1rem;">
  <div style="flex: 1;">

| Olimex EXT1 | MZ80K | XB Signal |
|----------|----------|----------|
| P1 | nc | |
| P3 | A25 (mark) | D0 |
| P5 | A24 | D1 |
| P7 | A23 | D2 |
| P9 | A22 | D3 |
| P11 | A21 | D4 |
| P13 | A20  | D5 |
| P15 | A19 | D6 |
| P17 | A18 | D7 |
| P19 | nc | |
| P21 | nc | |
| P23 | nc | |
| P25 | nc | |
| P27 | nc | |
| P29 | nc | |
| P31 | B10 | NWR |
| P33 | B8 | NRD |
| P35 | B6 | NMREQ |
| P37 | B4 | NIOREQ |
| P39 | B3 | GND |

  </div>

  <div style="flex: 1;">

| Olimex EXT2 | MZ80K | Signal |
|----------|----------|----------|
| P1 | nc | |
| P3 | A16 | A0 |
| P5 | A15 | A1 |
| P7 | A14 | A2 |
| P9 | A13 | A3 |
| P11 | A12 | A4 |
| P13 | A11 | A5 |
| P15 | A10 | A6 |
| P17 | A9 | A7 |
| P19 | nc | |
| P21 | nc | |
| P23 | A8 | A8 |
| P25 | A7 | A9 |
| P27 | A6 | A10 |
| P29 | A5 | A11 |
| P31 | A4 | A12 |
| P33 | A3 | A13 |
| P35 | A2 | A14 |
| P37 | A1 | A15 |
| P39 | nc | |

  </div>
</div>

![sharp-mz80k-bus-pins](sharp-mz80k/mz80k-bus-pins.png)

## Building

From the project root:

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

## Uploading

To put the Pico into bootloader mode:

* hold the BOOT button
* connect the board to your computer via USB

Then upload the firmware using VS Code with the Pico extension, or use the project task configuration already provided in the workspace.

## SD card layout

Create an SD card with a root-level folder named `MZ_FD`. Place the files you want to access inside that directory and give them the `.MZF` extension. The file `0000.MZF` is loaded whenever `*FD` is used from the monitor.

## Patch workflow

Because the monitor ROM cannot be modified in software, a replacement ROM or a patched program image is required to redirect tape-file operations to the SD-backed handlers.

The helper scripts make this easier:

* `mz_tape_info.py` identifies files that use tape-file logic
* `filehandle_path.py` patches those files to call the SD-handler routines instead

## Power

The board can be powered either from the host laptop USB port or from a standard USB power supply.

# Operating instructions

See [OPERATING.md](OPERATING.md) for instructions on using the interface from the Sharp monitor ROM.

# Reference and acknowledgements

Thanks to:

* [MZ80K_SD](https://github.com/yanataka60/MZ80K_SD)
* [Atom-DVI](https://github.com/cmoulang/Atom-DVI)
* [MZ-80A](https://mz-80a.com/)
* [MZ-Archive](https://mz-archive.co.uk/)
* [Sharp MZ](https://www.sharpmz.net/)
* the wider retro-computing community for technical discussion and reference material

This project also benefited from discussions and examples from several AI systems used during development, but the project itself is intended to stand on its own technical merits.

# Technical notes

## The software:
* 1-bit SD Card interface software (initially from prompts to Claude.ai).  The Olimex Pico2-XXL has two variants.  One use 1-bit communication protocol and the other uses the 4-bit protocol.  My board used 1-bit so the software is built for this.

* Expansion Bus - provides a shared memory on the address bus.  [Pico PIOs](https://www.raspberrypi.com/news/what-is-pio/) rapidly reads addresses and data which several DMAs pump in and out of 64Kx16bit words (128Kb).
  * heavily influenced by [ATOM-DVI](https://github.com/cmoulang/Atom-DVI) after speaking with Chris about his project at an ABUG event. 
* pico-xb80_mz80k - the specific Sharp MZ80K interface.  
  * Z80 *ROM* this is shared on the bus at `0xF000` so that the Monitor ROM can jump to it with an `*FD` command.
  * Mailbox addresses so that the Z80 can send and receive commands and data to/from the Pico
  * Communcation with the SD card via the SD Card interface and `fatfs`