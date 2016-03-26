# log4j_dataloss
Example illustrative of data loss problems with log4j DailyRollingFileAppender

## Problem statement

Log4j is thread safe but not process safe.  If multiple processes managing the same log files, are running at the same time as when logs are rotated, data loss will be evident.

From the log4j documentation

> DailyRollingFileAppender extends FileAppender so that the underlying file is rolled over at a user chosen frequency. DailyRollingFileAppender has been observed to exhibit synchronization issues and data loss. The log4j extras companion includes alternatives which should be considered for new deployments and which are discussed in the documentation for org.apache.log4j.rolling.RollingFileAppender.

## Proof

### Installation

Ensure you have rvm installed.  The .rvmrc should handle the correct installation of Jruby 1.7.13 and creation of a gemset.  To install the appropriate gems run the following.

    bundle install

### Control

The 'control' illustrates a correct and working state to compare against.  One process managing multiple log files via a single configuration file.  All log files rollover every minute.  Typically logs are set to rollover daily but the mechanics are identical.

    rm log/*
    timeout 5m jruby logger.rb "CONTROL"

This will run for 5 minutes and terminate.  The example logs to the main log file every second and to the secondary log file every 10 seconds with the string 'CONTROL' and an incrementing counter on each entry to assist in verifying record continuity and potential loss.

    ls -ali log/

You will note variable size at the first and last log file and cosistency in the middle.
To visually inspect for log continuity use the following

    cat log/production.log* | sort
    cat log/production_other.log* | sort

No record loss should be apparent in either case

### Problem scenario

The problem arises when 2 processes are running and writing/managing the same set of logfiles.  To illustrate

    rm log/*
    timeout 5m jruby logger.rb "CONTROL" &
    timeout 5m jruby logger.rb "NOTGOOD"

Wait for the second process to terminate.

The following will most likley display breaks in the continuous sequence number in the log entry confirming data loss.  Remember, every entry should start at 1 or 10 and end ~300 (minus jvm startup time)

    cat log/production.log* | grep CONTROL | sort
    cat log/production_other.log* | grep CONTROL |sort
    cat log/production.log* | grep NOTGOOD | sort
    cat log/production_other.log* | grep NOTGOOD |sort


Multiple runs will exhibit non-deterministic log results but the same issue.

### Solutions

1. Put process ids (pid) in configuration file.
   * + Resolves issue
   * + Simple & quick
   * - Fragments log files
   * - Application still responsible for log management
   * - No aggregation
2. Log to centralized and singular log management service.
   * + Resolves issue
   * + Decouples log management from application
   * - Additional infrastructure and monitoring necessary - Single point of failure
3. Create multiple log configuration files, loading only the relevant one upon startup.
   * + Reduces surface area
   * - Does not 100% resolve issue (multipl processes may still need to write to common log)

## References

- https://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/DailyRollingFileAppender.html
- http://stackoverflow.com/questions/7500212/log4j-dailyrollingfileappender-file-issues
- http://stackoverflow.com/questions/285081/log4j-logging-to-a-shared-log-file