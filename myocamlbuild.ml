open Ocamlbuild_plugin

let mcmc_dir = "/Users/farr/Documents/code/mcmc-ocaml/_build"
let gsl_dir = "/Users/farr/Documents/code/ocamlgsl"
let ounit_dir = "/Users/farr/Documents/code/oUnit/"
let mpi_dir = "/Users/farr/Documents/code/ocamlmpi"
let plplot_dir = "+plplot"
let plplot_link_dir_command = "-L/usr/local/lib"

let _ = dispatch begin function 
  | After_rules -> 
      ocaml_lib ~extern:true ~dir:mpi_dir "mpi";
      ocaml_lib ~extern:true ~dir:mcmc_dir "mcmc";
      ocaml_lib ~extern:true ~dir:gsl_dir "gsl";
      ocaml_lib ~extern:true ~dir:ounit_dir "oUnit";
      ocaml_lib ~extern:true ~dir:plplot_dir "plplot";
      flag ["compile"; "use_plplot"]
        (S[A"-ccopt"; A plplot_link_dir_command]);
      flag ["link"; "use_plplot"]
        (S[A"-ccopt"; A plplot_link_dir_command])
  | _ -> ()
end
