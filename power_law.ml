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

let shift = function 
  | [|min_mass; max_mass; alpha|] -> 
    let left_bound = max !mmin (min_mass -. 0.5) and 
        right_bound = min !mmax (max_mass +. 0.5) and
        d = max_mass -. min_mass in 
    let new_min = Stats.draw_uniform left_bound (right_bound -. d) in 
      [|new_min; new_min +. d; alpha|]
  | _ -> raise (Invalid_argument "shift: bad state")

let log_shift_jp x y = 
  match x,y with 
    | [|min_mass1; max_mass1; alpha1|], [|min_mass2; max_mass2; alpha2|] when alpha1 = alpha2 -> 
      let left_bound = max !mmin (min_mass1 -. 0.5) and 
          right_bound = min !mmax (max_mass1 +. 0.5) and 
          d = max_mass1 -. min_mass1 in 
        ~-.(log ((right_bound -. d) -. left_bound))
    | _ -> neg_infinity

let stretch = function 
  | [|min_mass; max_mass; alpha|] -> 
    let d = max_mass -. min_mass and 
        c = 0.5 *. (max_mass +. min_mass) in 
    let c_bounds_dist = min (!mmax -. c) (c -. !mmin) in
    let min_d = max 0.0 (d -. 0.5) and 
        max_d = min (2.0*.c_bounds_dist) (d +. 0.5) in
    let new_d = Stats.draw_uniform min_d max_d in 
      [| c -. 0.5*.new_d; c +. 0.5*.new_d; alpha |] 
  | _ -> raise (Invalid_argument "stretch: bad state")

let log_stretch_jp x y = 
  match x,y with 
    | [|min_mass1; max_mass1; alpha1|], [|min_mass2; max_mass2; alpha2|]
      when abs_float (0.5*.(max_mass1 -. min_mass1) -. 0.5*.(max_mass2 -. min_mass2)) < 1e-8 
        && alpha1 = alpha2 -> 
      let d = max_mass1 -. min_mass1 and 
          c = 0.5 *. (max_mass1 +. min_mass1) in 
      let c_bounds_dist = min (!mmax -. c) (c -. !mmin) in
      let min_d = max 0.0 (d -. 0.5) and 
          max_d = min (2.0*.c_bounds_dist) (d +. 0.5) in
        ~-.(log (max_d -. min_d))
    | _ -> neg_infinity

let tilt = function 
  | [|min_mass; max_mass; alpha|] -> 
    let amin = max !alphamin (alpha -. 0.1) and 
        amax = min !alphamax (alpha +. 0.1) in 
      [|min_mass; max_mass; Stats.draw_uniform amin amax|]
  | _ -> raise (Invalid_argument "tilt: bad state")

let log_tilt_jp x y = 
  match x,y with 
    | [|min_mass1; max_mass1; alpha1|], [|min_mass2; max_mass2; alpha2|] 
      when min_mass1 = min_mass2 && max_mass1 = max_mass2 -> 
      let amin = max !alphamin (alpha1 -. 0.1) and 
          amax = min !alphamax (alpha1 +. 0.1) in 
        ~-.(log (amax -. amin))
    | _ -> neg_infinity
      
let (jump_proposal, log_jump_probability) = 
  Mcmc.combine_jump_proposals
    [(1.0, shift, log_shift_jp);
     (1.0, stretch, log_stretch_jp);
     (1.0, tilt, log_tilt_jp)]

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
