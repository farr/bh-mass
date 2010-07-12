open Printf
open Dist_base
open Two_gaussian_base

let outfile = ref "two-gaussian.mcmc"
let overwrite = ref false

let options = 
  Arg.align 
    (base_opts @ [("-o", Arg.Set_string outfile,
                   sprintf "output filename (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite output file with new MCMC")])

let jump_proposal = function 
  | [|mu1; mu2; sigma1; sigma2; a|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mu1;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 mu2;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 sigma1;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 sigma2;
      Mcmc.uniform_wrapping 0.0 1.0 0.1 a|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_probability _ _ = 0.0

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "two_gaussian.{byte,native} OPTIONS ...";
  let msamples = Masses.generate_samples !high_m !nmsamp in 
  let s0 = [|8.0; 8.0; 2.0; 2.0; 0.5|] in
  let log_likelihood x = log_likelihood msamples x in
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_likelihood = log_likelihood s0;
                                   log_prior = log_prior s0}} in
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_proposal log_jump_probability in
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
