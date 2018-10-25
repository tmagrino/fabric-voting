# fabric-voting
A simple voting benchmark for Fabric.

## Setup

Copy `[config.properties.in](config.properties.in)` to a file named
`config.properties` and change the `fabric.home` setting to point to where you
have [Fabric](https://github.com/apl-cornell/fabric/) built.  Note that
`${env.HOME}` will point to the home directory of the current user.

After setting the configuration, you can build by running `ant` with either the
default target:

    $ ant

Or with the `build-all` target:

    $ ant build-all

## Running

TODO: Need to clean up code and create scripts for running things locally.
