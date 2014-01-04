
[![Build Status](https://travis-ci.org/gilliek/fcp.png?branch=master)](https://travis-ci.org/gilliek/fcp)

## FCP

FCP stands for FTP Copy. It aims to be a simple CLI tool that performs copy
through FTP.

## Features

- ☑ Copy through FTP
- ☑ Recursive copy
- ☑ Configuration file
- ☑ Transfer in ASCII and Binary mode
- ☑ Safe copy option (ask before overwriting)
- ☐ FTPs support
- ☐ Progressbar option
- ☐ Verbose mode
- ☐ Interactively ask for user and password when they are not supplied

## Installation

Copy `bin/fcp` into one of your bin folder (eg. `/usr/bin`, `/usr/local/bin`,
or `~/.bin`). Make sure that the path is in your `$PATH`.

## Usage (TODO)

See `fcp -h` or `fcp --help`

## Tests

To run the test suite, use `rake test` from the root of the project.
