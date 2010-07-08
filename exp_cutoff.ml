open Printf
open Dist_base

let outfile = ref "exp-cutoff.mcmc"
let overwrite = ref false

let options = 
  Arg.align
    (base_opts @ [("-o", Arg.Set_string outfile,
                   sprintf "output file name (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite the output file instead of appending to it")])

let log_likelihood msamples = function
  | [|mc; m0|] -> 
    let norm = (exp (mc /. m0)) /. m0 in
      List.fold_left
        (fun ll msamp -> 
          let overlap = ref 0.0 in 
          let n = Array.length msamp in 
            for i = 0 to n - 1 do 
              let m = msamp.(i) in 
                if m >= mc then 
                  overlap := !overlap +. norm *. (exp ~-.(m /. m0))
            done;
            ll +. (log (!overlap /. (float_of_int n))))
        0.0
        msamples
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

let log_prior = function 
  | [|mc; m0|] -> 
    if mc >= !mmin && mc <= !mmax && m0 >= 0.0 && mc +. 2.0*.m0 <= !mmax then 
      1.3862943611198906188 -. 2.0*.(log (!mmax -. !mmin)) (* Log(4) is first constant. *)
    else
      neg_infinity
  | _ -> raise (Failure "log_prior: bad state")

let jump_proposal = function 
  | [|mc; m0|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mc;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 m0|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_probability _ _ = 0.0

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "exp_cutoff.{byte,native} OPTIONS ...";
  let samples = Masses.generate_samples !high_m !nmsamp in
  let s0 = [|4.0; 1.0|] in 
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_likelihood = log_likelihood samples s0;
                                   log_prior = log_prior s0}} in 
  let log_likelihood x = log_likelihood samples x in
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
