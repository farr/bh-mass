#!/bin/bash

ocamlbuild all.otarget
cp _build/*.native .