(** Represents the underlying mass distribution by a binned histogram.
    Each bin is allocated a constant fraction of the total mass
    probability---i.e. each bin has a constant width x height.  The
    bin widths are adjusted in the MCMC to try to match the data.  

    This program expects m and sigma pairs on stdin, and outputs to
    stdout samples of the bin boundaries followed (as usual) by the
    log_likelihood and log_prior.  For a model with N bins, there will
    be N+1 boundaries; the lowest will always be at the minimum mass,
    and the highest will always be at the maximum mass. 

    The prior is assumed to be uniform over bin boundary
    distributions. *)

open Read

let mmin = ref 1.0
let mmax = ref 26.0
let nsamp = ref 1000000
let nburnin = ref 10000
let nout = ref 100
let nbin_max = ref 10
let fixed_bin = ref false
let nfixedbin = ref (-1)
let smaller_prior = ref false

let options = 
  [("-mmin",
    Arg.Set_float mmin,
    Printf.sprintf "minimum allowed mass: default %g" !mmin);
   ("-mmax",
    Arg.Set_float mmax,
    Printf.sprintf "maximum allowed mass: default %g" !mmax);
   ("-nsamp",
    Arg.Set_int nsamp,
    Printf.sprintf "number of MCMC samples: default %d" !nsamp);
   ("-nburnin",
    Arg.Set_int nburnin,
    Printf.sprintf "number of samples for the burn-in period: default %d" !nburnin);
   ("-nout",
    Arg.Set_int nout,
    Printf.sprintf "number of samples between outputs: default %d" !nout);
   ("-seed",
    Arg.Int (fun seed -> Random.init seed),
    Printf.sprintf "RNG seed: default self_init");
   ("-nbinmax", Arg.Set_int nbin_max,
    Printf.sprintf "max number of bins (default %d)" !nbin_max);
   ("-fixedbin", Arg.Int (fun i -> fixed_bin := true; nfixedbin := i),
    "fixed number of bins (normally, bins vary)");
   ("-smaller-prior", Arg.Set smaller_prior, 
    Printf.sprintf "use a smaller prior, assiging 1/N! prior mass to N-bin model (default %b)" !smaller_prior)]
   
type state = float array

let nbin (s : state) = Array.length s - 1

let log_factorial n = 
  let lf = ref 0.0 in 
    for i = 1 to n do 
      lf := !lf +. (log (float_of_int i))
    done;
    !lf +. 0.0

let log_prior (s : state) = 
  if not !smaller_prior then 
    let n = Array.length s - 2 in 
      if !fixed_bin then 
        (log_factorial n) -. (float_of_int n)*.(log (!mmax -. !mmin))
      else
        (log_factorial n) -. (float_of_int n)*.(log (!mmax -. !mmin))  -. (log (float_of_int !nbin_max))
  else 
    let n = Array.length s - 2 in 
      ~-.(float_of_int n)*.(log (!mmax -. !mmin))
          
let log_uniform_int n = 
  ~-.(log (float_of_int n))

let gaussian_overlap mu sigma a b = 
  let denom = (sqrt 2.0)*.sigma and 
      da = a -. mu and 
      db = b -. mu in 
  let ol = 0.5*.(Gsl_sf.erf (db/.denom) -. Gsl_sf.erf (da/.denom)) in 
    ol

let bin_height nbin a b = 
  let dm = b -. a in 
  let area = 1.0 /. (float_of_int nbin) in 
    area /. dm

let one_measurement_one_bin_like nbin mu sigma a b = 
  (bin_height nbin a b) *. (gaussian_overlap mu sigma a b)

let log_likelihood ms sigmas state = 
  let ll = ref 0.0 and 
      nbin = nbin state in 
    for i = 0 to Array.length ms - 1 do 
      let mu = ms.(i) and 
          sigma = sigmas.(i) and 
          ol = ref 0.0 in 
        for j = 0 to Array.length state - 2 do 
          let a = state.(j) and b = state.(j+1) in 
            ol := !ol +. one_measurement_one_bin_like nbin mu sigma a b
        done;
        ll := !ll +. (log !ol)
    done;
    !ll +. 0.0

let random_between a b = 
  a +. (b-.a)*.(Random.float 1.0)

let float_compare (a : float) b = Pervasives.compare a b

let random_bins nbin = 
  let bins = Array.make (nbin + 1) !mmin in 
    bins.(nbin) <- !mmax;
    for i = 1 to nbin - 1 do 
      bins.(i) <- random_between !mmin !mmax
    done;
    Array.fast_sort float_compare bins;
    bins

let random_bins_jp (a : state) = 
  random_bins (nbin a)

let random_bins_log_jump_prob (a : state) b = 
  let n = Array.length a in 
    if Array.length b = n then begin
      (* Could be a random jump. *)
      let tmp = !smaller_prior in 
        smaller_prior := false;
        let res = log_prior b in 
          smaller_prior := tmp;
          res
    end else
      (* zero chance of a jump. *)
      neg_infinity

let move_one_boundary (bins : state) = 
  if Array.length bins <= 2 then 
    bins
  else begin
    let bins = Array.copy bins in 
    let nbin = nbin bins in 
    let i = 1 + Random.int (nbin - 1) in 
    let low = bins.(i-1) and high = bins.(i+1) in 
      bins.(i) <- random_between low high;
      bins
  end

(* Returns index of difference if a and b differ in exactly one
   location; returns < 0 otherwise. *)
let differ_in_one_index (a : state) b = 
  let n = Array.length a in 
    if Array.length b <> n then 
      -1
    else
      let rec differ_in_one_index_loop i idiff = 
        if i >= n then 
          idiff
        else
          if a.(i) <> b.(i) then 
            if idiff < 0 then 
              differ_in_one_index_loop (i+1) i
            else
              (* Already differ in another index; must be at least two differences. *)
              -1
          else
            differ_in_one_index_loop (i+1) idiff in
        differ_in_one_index_loop 0 (-1)

let move_one_boundary_log_jump_prob (a : state) b = 
  let idif = differ_in_one_index a b in 
    if idif < 0 then 
      (* Differ in zero, or more than one; can't be result of
         move_one_boundary. *)
      neg_infinity
    else
      let low = a.(idif-1) and 
          high = a.(idif+1) in 
        ~-.(log (high -. low))

let reduce_dimension (bins : state) = 
  if !fixed_bin then 
    bins
  else if nbin bins <= 1 then 
    (* Can't reduce dimension. *)
    bins
  else begin
    let iremove = Random.int (Array.length bins - 2) + 1 in 
    let new_bins = Array.make (Array.length bins - 1) 0.0 in 
      Array.blit bins 0 new_bins 0 iremove;
      Array.blit bins (iremove+1) new_bins iremove (Array.length new_bins - iremove);
      new_bins
  end

let first_different_index (a : state) b = 
  let n = Array.length a in 
  let rec first_different_index_loop i = 
    if i >= n then 
      raise (Failure "first_different_index: arrays are equal")
    else
      let ai = a.(i) and 
          bi = b.(i) in 
        if ai = bi then 
          first_different_index_loop (i+1) 
        else
          i in 
    first_different_index_loop 0

let subarrays_equal (a : state) a0 b b0 n = 
  let rec subarrays_equal_loop i = 
    (i >= n) ||
      (let ai = a.(a0+i) and 
           bi = b.(b0+i) in 
         if ai = bi then 
           subarrays_equal_loop (i+1)
         else
           false) in 
    subarrays_equal_loop 0

let reduce_dimension_log_jump_prob (a : state) b = 
  if !fixed_bin then 
    0.0
  else begin
    let nba = nbin a and 
        nbb = nbin b in 
      if nba = nbb && nba <= 1 then 
        (* If only one bin, reduce_dimension returns same state with p = 1. *)
        0.0
      else if nbb = nba - 1 then 
        let i = first_different_index a b in 
          if subarrays_equal a 0 b 0 i && subarrays_equal a (i+1) b i (Array.length b - i) then 
          ~-.(log (float_of_int (Array.length a - 2)))
          else
            neg_infinity
      else
        neg_infinity
  end
let increase_dimension (bins : state) = 
  if !fixed_bin then 
    bins
  else if nbin bins >= !nbin_max then 
    bins
  else begin
    let iadd = Random.int (Array.length bins - 1) in 
      (* Add a bin at a random location between iadd and iadd+1 *)
    let new_bins = Array.make (Array.length bins + 1) 0.0 in  
      Array.blit bins 0 new_bins 0 (iadd+1);
      new_bins.(iadd+1) <- random_between bins.(iadd) bins.(iadd+1);
      Array.blit bins (iadd+1) new_bins (iadd+2) (Array.length new_bins - iadd - 2);
      new_bins
  end

let increase_dimension_log_jump_prob (a : state) b = 
  if !fixed_bin then 
    0.0
  else if nbin a >= !nbin_max then 
    if a = b then 
      0.0 
    else
      neg_infinity
  else begin
    let nba = nbin a and 
        nbb = nbin b in 
      if nbb = nba + 1 then 
        let i = first_different_index a b in 
          if subarrays_equal a 0 b 0 i && subarrays_equal a i b (i+1) (Array.length a - i) then 
            ~-.(log (b.(i+1)-.b.(i-1))) -. (log (float_of_int nba))
          else
            neg_infinity
      else
        neg_infinity
  end

let _ = 
  Random.self_init ();
  Arg.parse options (fun _ -> ()) "binned OPTIONS ...";
  let ms, sigmas = read_msigmas stdin in 
  let current_state = 
    let bins = if !fixed_bin then random_bins !nfixedbin else random_bins 1 in 
      ref {Mcmc.value = bins;
           like_prior = {Mcmc.log_likelihood = log_likelihood ms sigmas bins;
                         log_prior = log_prior bins}} and 
      (jump_propose, log_jump_prob) = 
    Mcmc.combine_jump_proposals 
      [(0.1, reduce_dimension, reduce_dimension_log_jump_prob);
       (0.1, increase_dimension, increase_dimension_log_jump_prob);
       (0.1, random_bins_jp, random_bins_log_jump_prob);
       (0.7, move_one_boundary, move_one_boundary_log_jump_prob)] in
  let next_state = 
    Mcmc.make_mcmc_sampler
      (fun state -> log_likelihood ms sigmas state)
      log_prior 
      jump_propose
      log_jump_prob in 
    for i = 1 to !nburnin do 
      current_state := next_state !current_state
    done;
    for i = 1 to !nsamp do 
      current_state := next_state !current_state;
      if i mod !nout = 0 then begin
        Read_write.write_sample (fun bins -> bins) stdout !current_state
      end
    done
