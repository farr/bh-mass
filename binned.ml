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

let mmin = ref 0.0 
let mmax = ref 20.0 
let nbin = ref 5
let nsamp = ref 1000000
let nburnin = ref 1000
let nout = ref 100

let options = 
  [("-mmin",
    Arg.Set_float mmin,
    Printf.sprintf "minimum allowed mass: default %g" !mmin);
   ("-mmax",
    Arg.Set_float mmax,
    Printf.sprintf "maximum allowed mass: default %g" !mmax);
   ("-nbin",
    Arg.Set_int nbin,
    Printf.sprintf "number of bins: default %d" !nbin);
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
    Printf.sprintf "RNG seed: default self_init")]
   
type state = float array

let log_factorial n = 
  let lf = ref 0.0 in 
    for i = 1 to n do 
      lf := !lf +. (log (float_of_int i))
    done;
    !lf +. 0.0

let log_prior (s : state) = 
  let n = !nbin - 1 in 
    (log_factorial n) -. (float_of_int n)*.(log (!mmax -. !mmin))

let gaussian_overlap mu sigma a b = 
  let denom = (sqrt 2.0)*.sigma and 
      da = a -. mu and 
      db = b -. mu in 
  let ol = 0.5*.(Gsl_sf.erf (db/.denom) -. Gsl_sf.erf (da/.denom)) in 
    ol

let bin_height a b = 
  let dm = b -. a in 
  let area = 1.0 /. (float_of_int !nbin) in 
    area /. dm

let one_measurement_one_bin_like mu sigma a b = 
  (bin_height a b) *. (gaussian_overlap mu sigma a b)

let log_likelihood ms sigmas state = 
  let ll = ref 0.0 in 
    for i = 0 to Array.length ms - 1 do 
      let mu = ms.(i) and 
          sigma = sigmas.(i) and 
          ol = ref 0.0 in 
        for j = 0 to Array.length state - 2 do 
          let a = state.(j) and b = state.(j+1) in 
            ol := !ol +. one_measurement_one_bin_like mu sigma a b
        done;
        ll := !ll +. (log !ol)
    done;
    !ll +. 0.0

let random_between a b = 
  a +. (b-.a)*.(Random.float 1.0)

let float_compare (a : float) b = Pervasives.compare a b

let random_bins () = 
  let bins = Array.make (!nbin + 1) !mmin in 
    bins.(!nbin) <- !mmax;
    for i = 1 to !nbin - 1 do 
      bins.(i) <- random_between !mmin !mmax
    done;
    Array.fast_sort float_compare bins;
    bins

let move_one_boundary (bins : state) = 
  let bins = Array.copy bins in 
  let i = 1 + Random.int (!nbin - 1) in 
  let low = bins.(i-1) and high = bins.(i+1) in 
    bins.(i) <- random_between low high;
    bins

let _ = 
  Random.self_init ();
  Arg.parse options (fun _ -> ()) "binned OPTIONS ...";
  let ms, sigmas = read_msigmas stdin in 
  let current_state = 
    let bins = random_bins () in 
      ref {Mcmc.value = random_bins ();
           like_prior = {Mcmc.log_likelihood = log_likelihood ms sigmas bins;
                         log_prior = log_prior bins}} and 
      next_state = 
    Mcmc.make_mcmc_sampler
      (fun state -> log_likelihood ms sigmas state)
      log_prior 
      move_one_boundary
      (fun _ _ -> 0.0) in 
    for i = 1 to !nburnin do 
      current_state := next_state !current_state
    done;
    for i = 1 to !nsamp do 
      current_state := next_state !current_state;
      if i mod !nout = 0 then 
        let {Mcmc.value = bins;
             like_prior = {Mcmc.log_likelihood = ll; log_prior = lp}} = !current_state in 
          for i = 0 to Array.length bins - 1 do 
            Printf.printf "%g " bins.(i)
          done;
          Printf.printf "%g %g\n" ll lp
    done
    
