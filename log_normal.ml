open Printf
open Logn_base

(* These are provided by the base module. *)
(* let mmin = ref 0.0 *)
(* let mmax = ref 40.0 *)
let nmsamp = ref 1000
let nmcmc = ref 30000
let nskip = ref 100
let nbin = ref 10000
let outfile = ref "log-normal.mcmc"
let overwrite = ref false
let high_m = ref false

let options = 
  [("-mmin", Arg.Set_float mmin, 
    sprintf "minimum mass (default %g)" !mmin);
   ("-mmax", Arg.Set_float mmax,
    sprintf "maximum mass (default %g)" !mmax);
   ("-nmsamp", Arg.Set_int nmsamp,
    sprintf "number of samples to take from mass distributions (default %d)" !nmsamp);
   ("-nmcmc", Arg.Set_int nmcmc,
    sprintf "number of MCMC samples to output (default %d)" !nmcmc);
   ("-nskip", Arg.Set_int nskip,
    sprintf "number of MCMC samples to skip between outputs (default %d)" !nskip);
   ("-nbin", Arg.Set_int nbin,
    sprintf "number of burn-in samples (default %d)" !nbin);
   ("-seed", Arg.Int (fun s -> Random.init s), "initialize RNG with given seed");
   ("-o", Arg.Set_string outfile, 
    sprintf "output file for the mcmc (default %s)" !outfile);
   ("-overwrite", Arg.Set overwrite,
    "overwrite the pre-existing MCMC samples in output file");
   ("-high-mass", Arg.Set high_m,
    "use high-mass objects in sample")]

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "log_normal.{byte,native} OPTIONS ...";
  let msamples = Masses.generate_samples !high_m !nmsamp in
  let log_likelihood x = log_likelihood msamples x in
  let s0 = [|log 9.97; 0.01|] in 
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_prior = log_prior s0;
                                   log_likelihood = log_likelihood s0}} in
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_proposal log_jump_prob in 
    for i = 1 to !nbin do
      current := next !current
    done;
    let flags = (if !overwrite then Open_trunc else Open_append) :: [Open_wronly; Open_creat; Open_text] in
    let out = open_out_gen flags 0o644 !outfile in 
      for i = 1 to !nmcmc do
        for j = 1 to !nskip do
          current := next !current
        done;
        Read_write.write_sample (fun x -> x) out !current
      done;
      close_out out
