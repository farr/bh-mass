open Rj_base
open Dist_base
module Ec = Expc_base
module G = Gaussian_base
module H = Histogram_base
module Pl = Power_law_base
module Tg = Two_gaussian_base

let outfile = ref "reversible-jump.dat"

let options = 
  Arg.align 
    (base_opts @ [("-o", Arg.Set_string outfile,
                   Printf.sprintf "output file (default %s)" !outfile)])

module Interp = Interpolate_pdf.Make(struct
  type point = float array

  let coord (p : point) = p

  let point (c : float array) = c
end)

let permutations (arr : float array) = 
  let elts = Array.to_list arr in 
  let rec perms = function 
    | [] -> []
    | [x] -> [[x]]
    | elts ->
      List.concat
        (List.map 
           (fun elt -> 
             let without = List.filter (fun (e : float) -> e <> elt) elts in 
             let wperms = perms without in 
               List.map (fun wperm -> elt :: wperm) wperms)
           elts) in 
    List.map Array.of_list (perms elts)

let log_likelihood samples = 
  let hlog = H.log_likelihood samples and 
      glog = G.log_likelihood samples and 
      plog = Pl.log_likelihood samples and 
      elog = Ec.log_likelihood samples and 
      tglog = Tg.log_likelihood samples and 
      lnlog x = Logn_base.log_likelihood samples x in
    function 
      | Histogram(bins) -> hlog bins
      | Gaussian(params) -> glog params
      | Power_law(params) -> plog params
      | Exp_cutoff(params) -> elog params
      | Two_gaussian(params) -> tglog params
      | Log_normal(params) -> lnlog params

let log_prior =
  let offset = -2.3025850929940456840 in (* offset = log(1/10) because 10 models, each equally likely. *)
    function 
      | Histogram(params) -> H.log_prior params +. offset
      | Gaussian(params) -> G.log_prior params +. offset
      | Power_law(params) -> Pl.log_prior params +. offset
      | Exp_cutoff(params) -> Ec.log_prior params +. offset
      | Two_gaussian(params) -> Tg.log_prior params +. offset
      | Log_normal(params) -> Logn_base.log_prior params +. offset

let interp_from_file file low high = 
  let inp = open_in file in 
  let samples = Read_write.read (fun x -> x) inp in 
    close_in inp;
    Interp.make (Array.map (fun {Mcmc.value = x} -> x) samples) low high

let hinterps = 
  let files = [|"histogram-1bin.mcmc"; "histogram-2bin.mcmc";
                "histogram-3bin.mcmc"; "histogram-4bin.mcmc";
                "histogram-5bin.mcmc"|] in 
    Array.mapi 
      (fun i file -> 
        interp_from_file file (Array.make (i+2) !mmin) (Array.make (i+2) !mmax))
      files

let ginterp = interp_from_file "gaussian.mcmc" [|!mmin; 0.0|] [|!mmax; 0.25*.(!mmax-. !mmin)|]

let pinterp = interp_from_file "power-law.mcmc" [|!mmin; !mmin; !Power_law_base.alphamin|] [|!mmax; !mmax; !Power_law_base.alphamax|]

let einterp = interp_from_file "exp-cutoff.mcmc" [|!mmin; 0.0|] [|!mmax; 0.5*.(!mmin-. !mmax)|]

let tginterp = 
  interp_from_file "two-gaussian.mcmc" 
    [|!mmin; !mmin; 0.0; 0.0; 0.0|] 
    [|!mmax; !mmax; 0.25*.(!mmax -. !mmin); 0.25*.(!mmax-. !mmin); 1.0|]

let lninterp = 
  interp_from_file "log-normal.mcmc"
    (Logn_base.low_bounds ())
    (Logn_base.high_bounds ())

let interps = Array.append hinterps [|ginterp; pinterp; einterp; tginterp; lninterp|]

let interp_of_state = function 
  | Histogram(state) -> 
    hinterps.(Array.length state - 2)
  | Gaussian(_) -> ginterp
  | Power_law(_) -> pinterp
  | Exp_cutoff(_) -> einterp
  | Two_gaussian(_) -> tginterp
  | Log_normal(_) -> lninterp

let array_of_state = function 
  | Histogram(state) | Gaussian(state) | Power_law(state) 
  | Exp_cutoff(state) | Two_gaussian(state) | Log_normal(state) -> 
    state

let _ = Printf.eprintf "Done with interpolations.\n%!"

let constr = 
  Array.append 
    (Array.make 5 (fun x -> Histogram x))
    [|(fun x -> Gaussian x);
      (fun x -> Power_law x);
      (fun x -> Exp_cutoff x);
      (fun x -> Two_gaussian x);
      (fun x -> Log_normal x)|]

let compare_float (x : float) y = Pervasives.compare x y

(* The fixup functions below deal with the fact that the interpolating
   function lives on a cubical domain, while some of the parameter
   spaces here are only a corner of the cube; so, the interpolating
   proposal may propose parameters outside the corner, in which case
   they need to be mapped into the corner, and the jump probabilities
   need to change accordingly. *)
let hist_jump_fixup proposed_bins = 
  let pbs = Array.copy proposed_bins in 
    Array.fast_sort compare_float pbs;
    pbs

let pl_jump_fixup = function 
  | [|mmin; mmax; alpha|] as s -> 
    if mmin > mmax then 
      [|mmax; mmin; alpha|]
    else
      s
  | _ -> raise (Invalid_argument "pl_fixup: bad state")

let log_sum_logs l1 l2 = 
  if l1 > l2 then 
    let lr = l2 -. l1 in 
      l1 +. (log (1.0 +. (exp lr)))
  else
    let lr = l1 -. l2 in 
      l2 +. (log (1.0 +. (exp lr)))

let hist_jump_prob_fixup log_jp state = 
  let perms = permutations state in 
    List.fold_left
      (fun sum state -> log_sum_logs sum (log_jp state))
      neg_infinity
      perms

let pl_jump_prob_fixup log_jp = function 
  | [|mmin; mmax; alpha|] as state -> 
    log_sum_logs (log_jp state) (log_jp [|mmax; mmin; alpha|])
  | _ -> raise (Invalid_argument "pl_jump_prob_fixup: bad state")

let jump_proposal _ = 
  let i = Random.int (Array.length interps) in 
  let state = Interp.draw interps.(i) in 
    if i <= 4 then 
      constr.(i) (hist_jump_fixup state)
    else if i = 6 then 
      constr.(i) (pl_jump_fixup state)
    else
      constr.(i) state

(* Leave off the 1/9 factor for each model being equally likely.  *)
let log_jump_prob _ = function 
  | Histogram(state) -> 
    let interp = interps.(Array.length state - 2) in 
    let log_jp = fun state -> log (Interp.jump_prob interp () state) in 
      hist_jump_prob_fixup log_jp state
  | Gaussian(state) -> 
    let interp = interps.(5) in 
      log (Interp.jump_prob interp () state)
  | Power_law(state) -> 
    let interp = interps.(6) in 
    let jp state = log (Interp.jump_prob interp () state) in 
      pl_jump_prob_fixup jp state
  | Exp_cutoff(state) -> 
    let interp = interps.(7) in 
      log (Interp.jump_prob interp () state)
  | Two_gaussian(state) -> 
    let interp = interps.(8) in 
      log (Interp.jump_prob interp () state)
  | Log_normal(state) -> 
    let interp = interps.(9) in 
      log (Interp.jump_prob interp () state)

let accumulate_into_counter counters = function 
  | Power_law(_) -> 
    counters.(0) <- counters.(0) + 1
  | Exp_cutoff(_) -> 
    counters.(1) <- counters.(1) + 1
  | Gaussian(_) -> 
    counters.(2) <- counters.(2) + 1
  | Two_gaussian(_) -> 
    counters.(3) <- counters.(3) + 1
  | Log_normal(_) -> 
    counters.(4) <- counters.(4) + 1
  | Histogram(bins) -> 
    let n = Array.length bins + 3 in 
      counters.(n) <- counters.(n) + 1

let names = [|"Power Law"; "Exp With Cutoff"; "Gaussian"; "Two Gaussians"; "Log Normal";
              "Histogram 1"; "Histogram 2"; "Histogram 3"; "Histogram 4"; 
              "Histogram 5"|]

let _ = 
  Randomize.randomize ();
  Arg.parse options (fun _ -> ()) "reversible_jump.{byte,native} OPTIONS ...";
  let msamples = Masses.generate_samples !high_m !nmsamp in
  let log_likelihood = log_likelihood msamples in 
  let s0 = 
    let rec loop () = (* Needed to ensure that we don't start with an outlawed state. *)
      let prop = jump_proposal (Histogram [||]) in (* Use dummy state. *)
        if log_likelihood prop +. log_prior prop > neg_infinity then 
          prop
        else
          loop () in 
      loop () in 
    Printf.eprintf "Found initial state!\n%!";
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_prior = log_prior s0;
                                   log_likelihood = log_likelihood s0}} in 
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_proposal log_jump_prob in
  let counts = Array.make 10 0 in 
    for i = 1 to !nbin do 
      current := next !current
    done;
    Printf.eprintf "Done with burn-in.\n%!";
    for i = 1 to !nmcmc do
      for i = 1 to !nskip do
        current := next !current
      done;
      accumulate_into_counter counts (!current).Mcmc.value
    done;
    let out = open_out !outfile in
      Array.iteri (fun i ct -> Printf.fprintf out "%d %% %s\n" ct names.(i)) counts;
      close_out out
