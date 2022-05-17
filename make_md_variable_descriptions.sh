#!/bin/bash
cat variables.hcl | grep "^variable\| description" | sed 's/variable "\(.*\)" {/\1/' | sed 's/.*description =.*"\(.*\)"/\1/' | awk 'NR%2{printf "* `%s`: ",$0;next;}1'
