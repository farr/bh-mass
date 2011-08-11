open Histogram_base
open Dist_base
open Printf
open Stats

let numbin = ref 1
let outfile = ref "histogram.nested"
let nlive = ref 1000
let nmcmc = ref 1000

let gn_args = 
  [("-o", Arg.Set_string outfile,
    sprintf "file file for output (default %s)" !outfile);
   ("-nlive", Arg.Set_int nlive,
    sprintf "n number of live points (default %d)" !nlive);
   ("-nmcmc", Arg.Set_int nmcmc,
    sprintf "n number of MCMC samples in prior draw (default %d)" !nmcmc);
   ("-numbin", Arg.Set_int numbin,
    sprintf "nbin number of bins to use (default %d)" !numbin)]

let options = 
  Arg.align (base_opts @ gn_args)

let observer {Mcmc.like_prior = {Mcmc.log_likelihood = ll}} = 
  fprintf stderr "Retired point with log(L) = %g\n%!" ll

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "histogram_nested.{byte,native} OPTIONS ...";
  fixedbin := true;
  let msamples = Masses.generate_samples !high_m !nmsamp in 
  let log_likelihood musig = log_likelihood msamples musig in 
  let draw_prior () = draw_prior !numbin () in 
  let nested_results = 
    Nested.nested_evidence 
      ~observer:observer
      ~nlive:!nlive
      ~nmcmc:!nmcmc
      draw_prior
      log_likelihood
      log_prior in 
  let out = open_out !outfile in 
    try 
      Read_write.write_nested out nested_results;
      close_out out
    with 
      | x -> close_out out; raise x
