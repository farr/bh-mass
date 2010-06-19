#!/bin/bash

set -e

dist_type () {
    case $1 in
        histogram*) echo "histogram";;
        exp*) echo "exponential";;
        power*) echo "power-law";;
        gaussian*) echo "gaussian";;
        two-gaussian*) echo "two-gaussian";;
    esac;
}

generate () {
    for file in *.mcmc; do
        TYPE=`dist_type $file`;
        _build/harmonic_evidence.native -i $file -o ${file}.ev;
        _build/bounds.native -$TYPE $file -o ${file}.bds;
        _build/plot_dist.native -$TYPE $file -o ${file}.dist;
    done
}

clean () {
    rm *.ev *.dist *.bds
}

case $1 in 
    clean*) clean;;
    *) generate;;
esac