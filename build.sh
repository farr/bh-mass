#!/bin/bash

set -e

choose_mcmc_arg () {
    case $1 in 
        histogram*) echo "-histogram";;
        gaussian*) echo "-gaussian";;
        power-law*) echo "-power-law";;
        two-gaussian*) echo "-two-gaussian";;
        exp*) echo "-exponential";;
    esac
}

do_bounds () {
    _build/bounds.native `choose_mcmc_arg $1` $1 -o $1.bds
}

do_dist () {
    _build/dist.native `choose_mcmc_arg $1` $1 -o $1.dist
}

do_harm_ev () {
    _build/harmonic_evidence.native -i $1 -o $1.ev
}

do_direct_ev () {
    _build/direct_evidence.native -i $1 -o $1.ev.direct -ngroup 256
}

do_mcmc () {
    _build/$1.native
}

do_post_file () {
    do_bounds $1;
    do_dist $1;
    do_harm_ev $1;
    if [ "$1" != "histogram.mcmc" ]; then 
        do_direct_ev $1
    fi;
}

rule () {
    case $1 in 
        clean) ocamlbuild -clean;;
        all) ocamlbuild all.otarget;;
        mcmc) 
            for mcmc in gaussian two_gaussian histogram exp_cutoff power_law; do 
                do_mcmc $mcmc
            done;
            for i in {1..5}; do 
                _build/histogram.native -fixedbin -nbin $i -o histogram-${i}bin.mcmc
            done;;
        post)
            for file in *.mcmc; do
                do_post_file $file;
            done;
            _build/reversible_jump.native > reversible-jump.dat;;
        post-file)
            do_post_file $2;
            shift;;
        *) ocamlbuild $1;;
    esac
}

if [ $# -eq 0 ]; then 
    rule all
else
    while [ $# -gt 0 ]; do
        rule $1;
        shift
    done
fi