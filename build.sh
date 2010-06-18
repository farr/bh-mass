#!/bin/bash

set -e

OCAMLBUILD=ocamlbuild

ocb ()
{
    $OCAMLBUILD $FLAGS $*
}

rule() {
    case $1 in
        clean) ocb -clean;;
        all) ocb all.otarget;;
        *) ocb $1;;
    esac;
}

if [ $# -eq 0 ]; then 
    rule all
else
    while [ $# -gt 0 ]; do
        rule $1
        shift
    done
fi