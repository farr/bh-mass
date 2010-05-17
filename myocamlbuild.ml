open Ocamlbuild_plugin

let mcmc_dir = "/Users/farr/Documents/code/mcmc-ocaml/_build"
let gsl_dir = "/Users/farr/Documents/code/ocamlgsl"
let ounit_dir = "/Users/farr/Documents/code/oUnit/"
let mpi_dir = "/Users/farr/Documents/code/ocamlmpi"

let _ = dispatch begin function 
  | After_rules -> 
      ocaml_lib ~extern:true ~dir:mpi_dir "mpi";
      ocaml_lib ~extern:true ~dir:mcmc_dir "mcmc";
      ocaml_lib ~extern:true ~dir:gsl_dir "gsl";
      ocaml_lib ~extern:true ~dir:ounit_dir "oUnit"
  | _ -> ()
end
