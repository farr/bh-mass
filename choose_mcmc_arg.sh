#!/bin/bash

set -e

case $1 in 
    histogram*) echo "-histogram";;
    gaussian*) echo "-gaussian";;
    power-law*) echo "-power-law";;
    two-gaussian*) echo "-two-gaussian";;
    exp*) echo "-exponential";;
    log-normal*) echo "-log-normal";;
    reversible*) echo "-rj";;
    skew-gaussian*) echo "-skew-gaussian";;
    *) exit 1;;
esac

