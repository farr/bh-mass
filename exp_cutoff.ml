open Printf
open Dist_base

let outfile = ref "exp-cutoff.mcmc"
let overwrite = ref false

let options = 
  Arg.align
    (base_opts @ [("-o", Arg.Set_string outfile,
                   sprintf "file output file name (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite the output file instead of appending to it")])

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "exp_cutoff.{byte,native} OPTIONS ...";
  let samples = Masses.generate_samples !high_m !nmsamp in
  let s0 = [|4.0; 1.0|] in 
  let log_likelihood x = Expc_base.log_likelihood samples x in 
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_likelihood = log_likelihood s0;
                                   log_prior = Expc_base.log_prior s0}} in 
  let next = Mcmc.make_mcmc_sampler log_likelihood Expc_base.log_prior Expc_base.jump_proposal Expc_base.log_jump_probability in
    for i = 1 to !nbin do 
      current := next !current
    done;
    let flags = [Open_wronly; Open_creat; Open_text] in
    let flags = if !overwrite then Open_trunc :: flags else Open_append :: flags in
    let out = open_out_gen flags 0o644 !outfile in
      for i = 1 to !nmcmc do 
        for j = 1 to !nskip do 
          current := next !current
        done;
        Read_write.write_sample (fun x -> x) out !current
      done;
      close_out out
