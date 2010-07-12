open Rj_base
module Ec = Expc_base
module G = Gaussian_base

let mmin = 0.0 
let mmax = 40.0
let alphamin = -12.0
let alphamax = 8.0
let nmsamp = 1000

let nsamp = ref 1000000
let high_m = ref false
let outfile = ref "reversible-jump.dat"

let options = 
  [("-n", Arg.Set_int nsamp,
    Printf.sprintf "number of samples to take (default %d)" !nsamp);
   ("-high-mass", Arg.Set high_m,
    "include high-mass objects in sample");
   ("-o", Arg.Set_string outfile,
    Printf.sprintf "output file (default %s)" !outfile)]

module Interp = Interpolate_pdf.Make(struct
  type point = float array

  let coord (p : point) = p

  let point (c : float array) = c
end)

module H = struct 
  let compare_float (x : float) y = Pervasives.compare x y

  let log_likelihood msamples = 
    let msamples = 
      List.map 
        (fun msamp -> 
          let msamp = Array.copy msamp in 
            Array.fast_sort compare_float msamp;
            msamp)
        msamples in 
      fun (bins : float array) -> 
        List.fold_left
          (fun (ll : float) (msamp : float array) -> 
            let nm = Array.length msamp and 
                nb = Array.length bins in
            let rec overlap_loop im ib ol = 
              if im >= nm then 
                ol /. (float_of_int nm)
              else if ib >= nb - 1 then 
                ol /. (float_of_int nm)
              else
                let m = msamp.(im) and 
                    low = bins.(ib) and 
                    high = bins.(ib+1) in
                  if m < low then 
                    overlap_loop (im+1) ib ol
                  else if m >= high then 
                    overlap_loop im (ib+1) ol
                  else
                    overlap_loop (im+1) ib (ol +. 1.0 /. ((float_of_int (nb-1))*.(high-.low))) in 
            let overlap = overlap_loop 0 0 0.0 in 
              ll +. (log overlap))
          0.0
          msamples

  let log_factorial n = 
    let sum = ref 0.0 in 
      for i = 2 to n do 
        sum := !sum +. (log (float_of_int i))
      done;
      !sum

  let log_prior bins = 
    let log_bin_factor = 0.0 in
    let n = Array.length bins in 
      (log_factorial n) +. log_bin_factor -. (float_of_int n)*.(log (mmax -. mmin))
end

module Pl = struct 
  let log_likelihood msamples = function 
    | [|mmin; mmax; alpha|] -> 
      let ap1 = alpha +. 1.0 in 
      let norm = ap1 /. (mmax**ap1 -. mmin**ap1) in
        List.fold_left
          (fun ll (msamp : float array) -> 
            let overlap = ref 0.0 and
                nsamp = Array.length msamp in
              for i = 0 to nsamp - 1 do 
                let m = msamp.(i) in 
                  if mmin <= m && m <= mmax then
                    overlap := !overlap +. norm*.m**alpha
              done;
              ll +. log (!overlap /. (float_of_int nsamp)))
          0.0
          msamples
    | _ -> raise (Invalid_argument "log_likelihood: bad state")

  let log_prior _ = 
    let dm = mmax -. mmin in 
    let x = 2.0 /. ((alphamax -. alphamin) *. dm *. dm) in 
      log x
end

module Tg = struct 
  let gaussian mu sigma x = 
    let d = mu -. x in 
      (exp ~-.((d*.d)/.(2.0*.sigma*.sigma))) /. (2.5066282746310005024 *. sigma)

  let log_likelihood msamples = function 
    | [|mu1; mu2; sigma1; sigma2; a|] -> 
      List.fold_left 
        (fun ll msamp -> 
          let n = Array.length msamp in 
          let ol = ref 0.0 in 
            for i = 0 to n - 1 do 
              let m = msamp.(i) in 
                ol := !ol +. a*.(gaussian mu1 sigma1 m);
                ol := !ol +. (1.0 -. a)*.(gaussian mu2 sigma2 m)
            done;
            ll +. (log (!ol /. (float_of_int n))))
        0.0
        msamples
    | _ -> raise (Invalid_argument "log_likelihood: bad state")

  let log_prior1 mu sigma = 
    if mu >= mmin && mu <= mmax && sigma >= 0.0 && 
      mu +. 2.0*.sigma <= mmax && mu -. 2.0*.sigma >= mmin then 
      2.0794415416798359283 -. 2.0*.(log (mmax -. mmin))
    else
      neg_infinity

  let log_prior = function 
    | [|mu1; mu2; sigma1; sigma2; a|] -> 
      if mu1 > mu2 then 
        neg_infinity
      else
        let lp1 = log_prior1 mu1 sigma1 and 
            lp2 = log_prior1 mu2 sigma2 in 
          0.69314718055994530942 +. lp1 +. lp2 (* Account for factor of two with first number. *)
    | _ -> raise (Invalid_argument "log_prior: bad state")
end

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
        interp_from_file file (Array.make (i+2) mmin) (Array.make (i+2) mmax))
      files

let ginterp = interp_from_file "gaussian.mcmc" [|mmin; 0.0|] [|mmax; 0.25*.(mmax-.mmin)|]

let pinterp = interp_from_file "power-law.mcmc" [|mmin; mmin; alphamin|] [|mmax; mmax; alphamax|]

let einterp = interp_from_file "exp-cutoff.mcmc" [|mmin; 0.0|] [|mmax; 0.5*.(mmin-.mmax)|]

let tginterp = 
  interp_from_file "two-gaussian.mcmc" 
    [|mmin; mmin; 0.0; 0.0; 0.0|] 
    [|mmax; mmax; 0.25*.(mmax -. mmin); 0.25*.(mmax-.mmin); 1.0|]

let lninterp = 
  interp_from_file "log-normal.mcmc"
    (Logn_base.low_bounds ())
    (Logn_base.high_bounds ())

let interps = Array.append hinterps [|ginterp; pinterp; einterp; tginterp; lninterp|]

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
  let msamples = Masses.generate_samples !high_m nmsamp in
  let log_likelihood = log_likelihood msamples in 
  let s0 = jump_proposal (Histogram [||]) in (* Use dummy state. *)
  let current = ref {Mcmc.value = s0;
                     like_prior = {Mcmc.log_prior = log_prior s0;
                                   log_likelihood = log_likelihood s0}} in 
  let next = Mcmc.make_mcmc_sampler log_likelihood log_prior jump_proposal log_jump_prob in
  let counts = Array.make 10 0 in 
    for i = 1 to !nsamp do
      current := next !current;
      accumulate_into_counter counts (!current).Mcmc.value
    done;
    let out = open_out !outfile in
      Array.iteri (fun i ct -> Printf.fprintf out "%d %% %s\n" ct names.(i)) counts;
      close_out out
