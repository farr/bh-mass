(** Assuming that the underlying mass distribution is a Gaussian, MCMC
    the Gaussian parameters. *)

open Stats

type state = {mu : float;
              sigma : float}

let nsamp = ref 100
let nout = ref 1
let nbin = ref 1000
let mumin = ref 0.0 
let mumax = ref 100.0
let sigmamin = ref 0.0 
let sigmamax = ref 100.0

let options = 
  [("-nsamp",
    Arg.Set_int nsamp,
    Printf.sprintf "number of samples: default %d" !nsamp);
   ("-nout",
    Arg.Set_int nout,
    Printf.sprintf "number of samples to take before output: default %d" !nout);
   ("-nburn",
    Arg.Set_int nbin,
    Printf.sprintf "number of samples to discard initially: default %d" !nbin);
   ("-seed",
    Arg.Int (fun seed -> Random.init seed),
    "use seed for RNG: default self_init");
   ("-mumin",
    Arg.Set_float mumin,
    Printf.sprintf "minimum mean mass: default %g" !mumin);
   ("-mumax",
    Arg.Set_float mumax,
    Printf.sprintf "maximum mean mass: default %g" !mumax);
   ("-sigmamin",
    Arg.Set_float sigmamin,
    Printf.sprintf "minimum mass std-dev: default %g" !sigmamin);
   ("-sigmamax",
    Arg.Set_float sigmamax,
    Printf.sprintf "maximum mass std-dev: default %g" !sigmamax)]

let read_msigmas () = 
  let mss = ref [] in 
    try
      while true do 
        let m = Scanf.scanf " %g " (fun x -> x) and
            sigma = Scanf.scanf " %g " (fun x -> x) in 
          mss := (m,sigma) :: !mss
      done;
      Array.of_list (List.rev !mss)
    with 
      | End_of_file -> Array.of_list (List.rev !mss)

let split_mss mss = 
  let ms = Array.map fst mss and 
      sigmas = Array.map snd mss in 
    (ms,sigmas)

let random_between a b = 
  let delta = b -. a in 
    a +. (Random.float delta)

let propose sample_sigma sample_n {mu = mu; sigma = sigma} = 
  let dmu = sample_sigma /. (sqrt sample_n) and 
      dsigma = sample_sigma /. (sqrt (2.0*.sample_n)) in 
    {mu = mu +. (random_between (~-.dmu) dmu);
     sigma = sigma +. (random_between (~-.dsigma) dsigma)}

let log_prior {mu = mu; sigma = sigma} = 
  if !mumin <= mu && mu <= !mumax &&
     !sigmamin <= sigma && sigma <= !sigmamax then 
      ~-.((log (!sigmamax -. !sigmamin)) +. (log (!mumax -. !mumin)))
  else
    neg_infinity

let pi = 4.0*.(atan 1.0)

let log_one_like mu sigma m sigmam = 
  let dm = mu -. m and 
      s2 = sigma*.sigma +. sigmam*.sigmam in 
    ~-.(dm*.dm/.(2.0*.s2)) -. 0.5*.(log (2.0*.pi)) -. 0.5*.(log s2)

let log_likelihood ms sigmas {mu = mu; sigma = sigma} = 
  let sum = ref 0.0 in 
    for i = 0 to Array.length ms - 1 do 
      sum := !sum +. log_one_like mu sigma ms.(i) sigmas.(i)
    done;
    !sum +. 0.0

let _ = 
  Random.self_init (); (* Should come before arg parsing so that arg seed can re-seed RNG if necessary. *)
  Arg.parse options (fun _ -> ()) "gaussian.{native,byte} OPTIONS ...";
  let (ms,sigmas) = split_mss (read_msigmas ()) in 
    Array.iteri
      (fun i m -> 
         let sigma = sigmas.(i) in 
           Printf.printf "m = %g, sigma = %g\n" m sigma)
      ms;
  let sample_n = float_of_int (Array.length ms) and 
      sample_sigma = std ms in 
    Printf.printf "# mu sigma log_like log_prior\n";
    let start_ms = {mu = mean ms; sigma = sample_sigma} in 
    let current_state = ref {Mcmc.value = start_ms;
                             like_prior = {Mcmc.log_likelihood = log_likelihood ms sigmas start_ms;
                                           Mcmc.log_prior = log_prior start_ms}} and 
        next_state = 
      Mcmc.make_mcmc_sampler 
        (fun state -> log_likelihood ms sigmas state)
        log_prior
        (fun state -> propose sample_sigma sample_n state)
        (fun _ _ -> 0.0) in
      for i = 1 to !nbin do 
        current_state := next_state !current_state
      done;
      for i = 1 to !nsamp do 
        current_state := next_state !current_state;
        let {value = {mu = mu; sigma = sigma};
             Mcmc.like_prior = {Mcmc.log_likelihood = ll;
                                log_prior = lp}} = !current_state in 
          if i mod !nout = 0 then 
            Printf.printf "%g %g %g %g\n" mu sigma ll lp
      done
