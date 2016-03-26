# log4j_dataloss
Example illustrative of data loss problems with log4j DailyRollingFileAppender

## Problem statement

From the log4j documentation

    DailyRollingFileAppender extends FileAppender so that the underlying file is rolled over at a user chosen frequency. DailyRollingFileAppender has been observed to exhibit synchronization issues and data loss. The log4j extras companion includes alternatives which should be considered for new deployments and which are discussed in the documentation for org.apache.log4j.rolling.RollingFileAppender.

## Proof

### Installation

Ensure you have rvm installed.  The .rvmrc should handle the correct installation of Jruby 1.7.13 and creation of a gemset.  To install the appropriate gems run the following.

   bundle install

### Control

The 'control' illustrates a correct and working state to compare against.  One process managing multiple logs via a single configuration file.  All logs rollover every minute.  Typically logs are set to rollover daily but the mechanics are identical.

    rm log/*
    timeout 5m jruby logger.rb "CONTROL"

This will run for 5 minutes and then terminate.  The example logs to the main log every second and to the secondary log every 10 with the string 'CONTROL' and an incrementing counter to assist in verifying record continuity and loss.

    ls -ali log/

You will note variable size at the first and last log and cosistency in the middle.
To visually inspect for log continuity use the following

    cat log/production.log* | sort
    cat log/production_other.log* | sort

No record loss should be apparent in either case

### Problem scenario


### Solutions

## References

- https://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/DailyRollingFileAppender.html
- http://stackoverflow.com/questions/7500212/log4j-dailyrollingfileappender-file-issues
- http://stackoverflow.com/questions/285081/log4j-logging-to-a-shared-log-file