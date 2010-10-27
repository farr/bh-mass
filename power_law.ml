open Printf
open Dist_base
open Power_law_base

let _ = mmin := 0.01

let outfile = ref "power-law.mcmc"
let overwrite = ref false

let options = 
  Arg.align
    (base_opts @ [("-alphamin", Arg.Set_float alphamin,
                   sprintf "amin minimum exponent (default %g)" !alphamin);
                  ("-alphamax", Arg.Set_float alphamax,
                   sprintf "amax maximum exponent (default %g)" !alphamax);
                  ("-o", Arg.Set_string outfile, 
                   sprintf "file filename for output (default %s)" !outfile);
                  ("-overwrite", Arg.Set overwrite,
                   "overwrite the output file")])

let jump_tilt = function 
  | [|min_mass; max_mass; alpha|] -> 
    [|min_mass; max_mass;
      Mcmc.uniform_wrapping !alphamin !alphamax 1.0 alpha|]
  | _ -> raise (Invalid_argument "jump_tilt: bad state")

let log_jump_tilt_prob (source : float array) target = 
  match source,target with 
    | ([|smmin; smmax; sal|],
       [|tmmin; tmmax; tal|]) -> 
      if smmin = tmmin && smmax = tmmax && sal <> tal then 
        0.0 (* Symmetric *)
      else
        neg_infinity (* Couldn't have come from the tilt jump proposal. *)
    | _ -> raise (Invalid_argument "log_jump_tilt_prob: bad states")

let max_shift_distances min_mass max_mass = 
  (min_mass -. !mmin,
   !mmax -. max_mass)

let jump_shift = function 
  | [|min_mass; max_mass; alpha|] -> 
    let (lshiftmax, rshiftmax) = max_shift_distances min_mass max_mass in 
    let dm = Stats.draw_uniform (~-.(min 1.0 lshiftmax)) (min 1.0 rshiftmax) in 
      [|min_mass +. dm; max_mass +. dm; alpha|]
  | _ -> raise (Invalid_argument "jump_shift: bad state")

let log_jump_shift_prob (source : float array) target = 
  match source, target with 
    | ([|smmin; smmax; sal|],
       [|tmmin; tmmax; tal|]) -> 
      let (lshiftmax, rshiftmax) = max_shift_distances smmin smmax in 
      let shiftlow = ~-.(min 1.0 lshiftmax) and 
          shifthigh = min 1.0 rshiftmax in 
      let minshift = tmmin -. smmin and 
          maxshift = tmmax -. smmax in 
        if sal = tal && abs_float (minshift -. maxshift) < 1e-8 && 
          shiftlow <= minshift && minshift <= shifthigh then 
          ~-.(log (shifthigh -. shiftlow))
        else
          neg_infinity
    | _ -> raise (Invalid_argument "log_jump_shift_prob: bad states")

let max_stretch_shrink min_mass max_mass = 
  (min (min_mass -. !mmin) (!mmax -. max_mass),
   0.5*.(max_mass -. min_mass))

let jump_stretch = function 
  | [|min_mass; max_mass; alpha|] -> 
    let (maxstretch, maxshrink) = max_stretch_shrink min_mass max_mass in 
    let stretch = min 1.0 maxstretch and 
        shrink = max 1.0 maxshrink in 
    let dm = Stats.draw_uniform (~-.stretch) shrink in 
      [|min_mass +. dm;
        max_mass -. dm;
        alpha|]
  | _ -> raise (Invalid_argument "jump_stretch: bad state")

let log_jump_stretch_prob (source : float array) target = 
  match source,target with 
    | ([|smmin; smmax; sal|], 
       [|tmmin; tmmax; tal|]) -> 
      let (maxstretch, maxshrink) = max_stretch_shrink smmin smmax in 
      let stretch = min 1.0 maxstretch and 
          shrink = min 1.0 maxshrink in 
        if sal = tal && abs_float ((smmin+.smmax) -. (tmmin+.tmmax)) < 1e-8 && 
          (~-.stretch) <= tmmin -. smmin && tmmin -. smmin <= shrink then 
          ~-.(log (stretch +. shrink))
        else
          neg_infinity
    | _ -> raise (Invalid_argument "log_jump_stretch_prob: bad states")

let (jump_proposal, log_jump_probability) = 
  Mcmc.combine_jump_proposals
    [(1.0, jump_tilt, log_jump_tilt_prob);
     (1.0, jump_shift, log_jump_shift_prob);
     (1.0, jump_stretch, log_jump_stretch_prob)]

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
