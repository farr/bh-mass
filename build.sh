#!/bin/bash

set -e

prefix=.

choose_mcmc_arg () {
    case $1 in 
        histogram*) echo "-histogram";;
        gaussian*) echo "-gaussian";;
        power-law*) echo "-power-law";;
        two-gaussian*) echo "-two-gaussian";;
        exp*) echo "-exponential";;
        log-normal*) echo "-log-normal";;
        reversible*) echo "-rj";;
    esac
}

do_bounds () {
    ${prefix}/_build/bounds.native `choose_mcmc_arg $1` $1 -o $1.bds
}

do_dist () {
    ${prefix}/_build/dist.native `choose_mcmc_arg $1` $1 -o $1.dist
}

do_harm_ev () {
    ${prefix}/_build/harmonic_evidence.native -i $1 -o $1.ev
}

do_direct_ev () {
    ${prefix}/_build/direct_evidence.native -i $1 -o $1.ev.direct -ngroup 256
}

do_mcmc () {
    ${prefix}/_build/$1.native
}

do_post_file () {
    do_bounds $1;
    do_dist $1;
    if [ "$1" != "reversible-jump.mcmc" ]; then 
        do_harm_ev $1;
        if [ "$1" != "histogram.mcmc" ]; then 
            do_direct_ev $1
        fi;
    fi;
}

rule () {
    case $1 in 
        clean) ocamlbuild -clean;;
        all) ocamlbuild all.otarget;;
        mcmc) 
            for mcmc in gaussian two_gaussian histogram exp_cutoff power_law log_normal; do 
                do_mcmc $mcmc
            done;
            for i in {1..5}; do 
                ${prefix}/_build/histogram.native -fixedbin -nbin $i -o histogram-${i}bin.mcmc
            done;;
        post)
            for file in *.mcmc; do
                do_post_file $file;
            done;
            ${prefix}/_build/reversible_jump.native > reversible-jump.dat;;
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
        rule "$@";
        shift
    done
fi