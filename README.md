# VSL-Compiler

A compiler built from scratch for a Very Simple Language.

## Setup

```
sudo apt-get install flex bison
```

## Build and Test

The compiler is currently at the IR-stage, generating syntax trees to be used
for assembly code generation.

To build the trees, do

```
cd src
make && make -C vsl_programs
```

The correct versions of the trees are located in `vsl_programs` and have the
suffix `.tree.correct` appended to the name of the file. You can compare the
files with the `diff` command.
