# fabric-voting
A simple voting benchmark for Fabric.  Multiple districts record local vote
counts for either candidate "a" or candidate "b".

## Setup

Copy `[config.properties.in](config.properties.in)` to a file named
`config.properties` and change the `fabric.home` setting to point to where you
have [Fabric](https://github.com/apl-cornell/fabric/) built.  Note that
`${env.HOME}` will point to the home directory of the current user.

Similarly, copy `[config.sh.in](config.sh.in)` to a file named `config.sh` and
change the `FABRIC` variable to point to where you
have [Fabric](https://github.com/apl-cornell/fabric/) built.  Note that
`${HOME}` will point to the home directory of the current user.

After setting the configuration, you can build by running `ant` with either the
default target:

    $ ant

Or with the `build-all` target:

    $ ant build-all

Finally, this repository provides credentials and fabric settings in
`$REPO/etc/` for:
  * 1 election store called "election",
  * 16 district stores "district1" through "district16", and
  * 16 additional workers "worker1" through "worker16".
If you need _additional_ workers and stores, you can create credentials following the
instructions in the Fabric manual
(discussed in [master branch
README doc](https://github.com/apl-cornell/fabric/blob/master/doc/manual/src/runtime.mkdn)
or [the published 0.3.0 release
manual](http://www.cs.cornell.edu/projects/fabric/manual/0.3.0/html/node-config.html)).
We suggest copying the properties from an existing worker or store (eg.
`$REPO/etc/config/district1.properties`).

## Running

### Ensuring a Clean Environment

To be sure you're not running using data leftover from a previous run, it is
useful to clear out `$REPO/var/`, a directory created when you run Fabric nodes.
*Note*: Be careful to save any logs you want to continue analyzing from
`$REPO/var/log/` before removing the directory!

### Starting and Initializing the System

To run the benchmark, first set up the stores and workers for the system.  Each
should be started in a separate terminal session.

There is always one election store:

    $ bin/start-store election

And one or more district stores (consecutively numbered starting from 1):

    $ bin/start-store district1
    $ bin/start-store district2
    ...
    $ bin/start-store district9
    ...

At this point, you can initialize the database, which ensures that the election
store has references to the different districts in the election as well as each
district's vote counts.  To do this, run the following, replacing $n with the
number of districts you'll be using:

    $ bin/init-voting-state $n

At this point you're ready to run vote and tally clients!

### Running Clients

For voting and tallying clients, you can either use the workers associated with
the election and district stores or create additional worker nodes (different
from stores because they do not persist state).  Like the stores, workers should
be started in separate terminal sessions:

    $ bin/start-worker worker1
    $ bin/start-worker worker2
    ...
    $ bin/start-worker worker9
    ...

#### Running Vote Clients

You can run a voting client with the following command on the shell of a worker
(or store):

    > voting.main.Vote election $district_num $max_threads $avg_vote_interval $start_bias $end_bias $shift_start_delay $shift_end_delay

Replacing the "`$`" variable(s) with the appropriate values:
  * `$district_num`: the number of the district to cast votes at.
  * `$max_threads`: the number of concurrent vote operations that can be active.
    If 0 is used, this indicates there should be no limit on the number of
    concurrent votes being run by this worker.
  * `$avg_vote_interval`: The average time in milliseconds between votes.  If 0
    is used, this indicates votes should be run as quickly as possible (_not_
    recommended).
  * `$start_bias`: The fraction of votes which, before any shift of the bias,
    will be cast for the first candidate ("a").  This is given as a double
    between 0 and 1 inclusive, so `0.60` indicates 60 percent of votes will be
    for candidate "a".
  * `$end_bias`: The fraction of votes which, after a shift of the bias is done,
    will be cast for the first candidate ("a").  Also given as a double between
    0 and 1 inclusive.
  * `$shift_start_delay`: number of milliseconds after the client starts to
    start shifting from the start bias to the end bias.
  * `$shift_end_delay`: number of milliseconds after the client starts to
    finish shifting from the start bias to the end bias.

Note that passing 0 for `shift_end_delay` will effectively run votes using the
final bias immediately.  This allows you to use a stable voting distribution
indefinitely.

(Note: The first argument `election` can be replaced with the name of whatever
node you set as the election store instead of the store named `election`)

#### Running Tally Clients

You can run a tallying client with the following command on the shell of a worker
(or store):

    > voting.main.Tally election $avg_tally_interval

Replacing the "`$`" variable(s) with the appropriate values:
  * `$avg_tally_interval`: The  time in milliseconds between tally operations.
    If 0 is used, this indicates tally operations should be run as quickly as
    possible (_not_ recommended).

(Note: The first argument `election` can be replaced with the name of whatever
node you set as the election store instead of the store named `election`).

#### Output

The FabIL code for this benchmark outputs simple log messages for the start and
end of each vote and tally operation.  These will be emitted to the log files
created in `$REPO/var/log/`.  The log messages have the form `LEVEL(TIME):
MESSAGE` where `LEVEL` is the [Java logging
level](https://docs.oracle.com/javase/8/docs/api/java/util/logging/Level.html),
`TIME` is the [epoch time](https://en.wikipedia.org/wiki/Unix_time) in
milliseconds, and `MESSAGE` is the message passed by the program to the logging
API.

The logging behavior is configured by the settings in
`$REPO/etc/logging.properties` which indicates what level of messages to include
for each [Java
Logger](https://docs.oracle.com/javase/8/docs/api/java/util/logging/Logger.html).

# Some TODOs:

Some notes for things to clean up and further document:

  * Add documentation and clean up scripts for starting and running vote and
    tally clients in `bin/vote` and `bin/tally`.
  * Discussion of how to test different forms of contention.
  * Documentation of adding synthetic network delay using Fabric node settings.
