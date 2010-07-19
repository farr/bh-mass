open Printf
open Dist_base
open Power_law_base

let _ = mmin := 0.01

let outfile = ref "power-law.mcmc"
let overwrite = ref false

let options = 
  Arg.align
    (base_opts @ [("-alphamin", Arg.Set_float alphamin,
                   sprintf "minimum exponent (default %g)" !alphamin);
                  ("-alphamax", Arg.Set_float alphamax,
                   sprintf "maximum exponent (default %g)" !alphamax);
                  ("-o", Arg.Set_string outfile, 
                   sprintf "filename for output (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite the output file")])

let jump_proposal = function 
  | [|min_mass; max_mass; alpha|] -> 
    let mid_mass = 0.5*.(min_mass +. max_mass) in 
    let min_min = max !mmin (min_mass -. 1.0) and 
        min_max = min mid_mass (min_mass +. 1.0) and 
        max_min = max mid_mass (max_mass -. 1.0) and 
        max_max = min !mmax (max_mass +. 1.0) in 
    let amin = max !alphamin (alpha -. 0.1) and 
        amax = min !alphamax (alpha +. 0.1) in 
      [|Stats.draw_uniform min_min min_max;
        Stats.draw_uniform max_min max_max;
        Stats.draw_uniform amin amax|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_probability source _ = 
  match source with 
    | [|min_mass; max_mass; alpha|] -> 
          let mid_mass = 0.5*.(min_mass +. max_mass) in 
          let min_min = max !mmin (min_mass -. 1.0) and 
              min_max = min mid_mass (min_mass +. 1.0) and 
              max_min = max mid_mass (max_mass -. 1.0) and 
              max_max = min !mmax (max_mass +. 1.0) in 
          let amin = max !alphamin (alpha -. 0.1) and 
              amax = min !alphamax (alpha +. 0.1) in 
            ~-.((log (min_max -. min_min)) +. 
                   (log (max_max -. max_min)) +. 
                   (log (amax -. amin)))
    | _ -> raise (Invalid_argument "log_jump_prob: bad source state")

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "power_law.{byte,native} ...";
  assert(!mmin > 0.0);
  let msamples = Masses.generate_samples !high_m !nmsamp in 
  let next = 
    Mcmc.make_mcmc_sampler 
      (fun x -> log_likelihood msamples x) log_prior jump_proposal log_jump_probability in
  let s0 = [|!mmin; !mmax; 0.0|] in 
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_likelihood = log_likelihood msamples s0;
                                   log_prior = log_prior s0}} in
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
