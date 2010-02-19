open Ocamlbuild_plugin

let denest_dir = "/Users/farr/Documents/code/denest-ocaml/_build"
let gsl_dir = "/Users/farr/Documents/code/ocamlgsl"
let ounit_dir = "/Users/farr/Documents/code/oUnit/"

let _ = dispatch begin function 
  | After_rules -> 
      ocaml_lib ~extern:true ~dir:denest_dir "denest";
      ocaml_lib ~extern:true ~dir:gsl_dir "gsl";
      ocaml_lib ~extern:true ~dir:ounit_dir "oUnit"
  | _ -> ()
end
