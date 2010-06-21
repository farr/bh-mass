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

plot_name () {
    case $1 in 
        _build/all_masses*) echo "all-masses.ps";;
        _build/bounds_plot*) echo "bounds.ps";;
        _build/dist*) echo "dist.ps";;
        _build/evidence*) echo "evidence.ps";;
        _build/mass*) echo "masses.ps";;
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
                do_bounds $file;
                do_dist $file;
                do_harm_ev $file;
                if [ "$file" != "histogram.mcmc" ]; then 
                    do_direct_ev $file
                fi;
            done;;
        plots)
            for file in _build/*plot.native; do
                $file -dev ps -o `plot_name $file`
            done;
            for file in *.ps; do
                ps2pdf $file
            done;
            mv *.ps *.pdf ../Paper/plots/;;
        *) echo "Unknown command: $1";;
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