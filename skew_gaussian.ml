open Printf
open Dist_base
open Skew_gaussian_base

let outfile = ref "skew-gaussian.mcmc"
let overwrite = ref false

let options = 
  Arg.align
    (base_opts @ [("-o", Arg.Set_string outfile,
                   sprintf "output file for the MCMC (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite the pre-existing MCMC samples in output file");
                  ("-alpha-min", Arg.Set_float alpha_min,
                   sprintf "minimum bound for alpha parameter (default %g)" !alpha_min);
                  ("-alpha-max", Arg.Set_float alpha_max,
                   sprintf "maximum bound for alpha parameter (default %g)" !alpha_max)])

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "skew_gaussian.{byte,native} OPTIONS ...";
  let msamples = Masses.generate_samples !high_m !nmsamp in
  let log_likelihood state = log_likelihood msamples state in
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_proposal log_jump_prob in
  let s0 = [|8.0; 2.0; 0.0|] in
  let current = ref {Mcmc.like_prior = {Mcmc.log_likelihood = log_likelihood s0;
                                        Mcmc.log_prior = log_prior s0};
                     value = s0} in 
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
