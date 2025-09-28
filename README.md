# avionics-tools
Cinira Avionics Tools

Modules
=
This repository is divided into modules, each under the `module/` directory.
* `module/scripts`: *Scripts* module, command line scripts for dealing with avionics data cards.

*Scripts* Module
-
This module provides Bash scripts for dealing with avionics data cards. They are compatible with Linux, BSD,
and macOS.

To build all scripts to the `dist/` directory, run:
```shell
(cd module/scripts && make)
```
* `dcls.sh` searches for mounted avionics data cards and displays
  information such as the aircraft tail number, avionics type, mount point,
  and device.
* `dctar.sh` searches for mounted avionics data cards, presents a
  selection list, and creates a compressed archives of the selected
  card(s).

> These scripts require software which is not typically installed by default.
> On a Linux system, these can be installed via the package manager. On macOS,
> they can be installed via [Homebrew](https://brew.sh/).
> * `dialog`
> * GNU `tar` (BSD `tar` is not supported)
> * `xz`
