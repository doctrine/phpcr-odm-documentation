# MOVED

**The documentation is now directly in the [phpcr-odm repository](https://github.com/doctrine/phpcr-odm)**

## Read compiled doc online

http://www.doctrine-project.org/projects/phpcr-odm.html

## Setup

Git clone this repository.

Update the submodules (used for the doctrine theme)

    git submodule update --init

Run

    ./bin/install-dependencies.sh

## How to Generate

Run

    ./bin/generate-docs.sh

It will generate the documentation in PDF format into the build directory of the checkout.

Alternatively, you can go into en/ and type `make` to see what other formats you can generate.
