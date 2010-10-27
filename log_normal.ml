open Printf
open Logn_base
open Dist_base

let outfile = ref "log-normal.mcmc"
let overwrite = ref false

let options = 
  Arg.align
    (base_opts @ [("-o", Arg.Set_string outfile, 
                   sprintf "file output file for the mcmc (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite the pre-existing MCMC samples in output file")])

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "log_normal.{byte,native} OPTIONS ...";
  let msamples = Masses.generate_samples !high_m !nmsamp in
  let log_likelihood x = Logn_base.log_likelihood msamples x in
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
