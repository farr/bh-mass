(** Assuming that the underlying mass distribution is two gaussians,
    with relative weight f, MCMC the Gaussian parameters.  The program
    expects on stdin the measurements of the masses; each measurement
    is a pair of real numbers: one mass and one standard deviation of
    measurement error around that mass.  Given a measured mass, m, and
    standard deviation, sigma, it is assumed that the true mass of the
    black hole being observed has a Gaussian probability distribution
    with mean m and standard deviation sigma.

    The program outputs to stdout MCMC samples of the underlying
    distribution's mean and standard deviation.  The output begins
    with a comment line (starting with a #) describing the layout: one
    column for the mean, one column for the standard deviation, one
    column for the log of the likelihood of those parameters, and one
    column for the log of the prior of those parameters.
*)

open Stats
open Read

type state = {mu1 : float;
              sigma1 : float;
              mu2 : float;
              sigma2 : float;
              f2 : float}

let nsamp = ref 1000000
let nout = ref 100
let nbin = ref 1000
let mumin = ref 1.0
let mumax = ref 26.0
let sigmamin = ref 0.0
let sigmamax = ref 26.0

let options = 
  [("-nsamp",
    Arg.Set_int nsamp,
    Printf.sprintf "number of samples: default %d" !nsamp);
   ("-nout",
    Arg.Set_int nout,
    Printf.sprintf "number of samples to take between output: default %d" !nout);
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

let random_between a b = 
  let delta = b -. a in 
    a +. (Random.float delta)

let propose sample_sigma sample_n {mu1 = mu1; sigma1 = sigma1; mu2 = mu2; sigma2 = sigma2; f2 = f2} = 
  let dmu = sample_sigma /. (sqrt sample_n) and 
      dsigma = sample_sigma /. (sqrt (2.0*.sample_n)) in 
    {mu1 = mu1 +. (random_between (~-.dmu) dmu);
     sigma1 = sigma1 +. (random_between (~-.dsigma) dsigma);
     mu2 = mu2 +. (random_between (~-.dmu) dmu);
     sigma2 = sigma2 +. (random_between (~-.dsigma) dsigma);
     f2 = f2 +. (random_between (-0.1) 0.1)}

let log_prior {mu1 = mu1; sigma1 = sigma1; mu2 = mu2; sigma2 = sigma2; f2 = f2} = 
  if !mumin <= mu1 && mu1 <= !mumax &&
    !sigmamin <= sigma1 && sigma1 <= !sigmamax && 
    !mumin <= mu2 && mu2 <= !mumax && 
    !sigmamin <= sigma2 && sigma2 <= !sigmamax &&
    0.0 <= f2 && f2 <= 1.0
  then 
    (-2.0)*.((log (!sigmamax -. !sigmamin)) +. (log (!mumax -. !mumin)))
  else
    neg_infinity

let pi = 4.0*.(atan 1.0)

let log_one_like mu sigma m sigmam = 
  let dm = mu -. m and 
      s2 = sigma*.sigma +. sigmam*.sigmam in 
    ~-.(dm*.dm/.(2.0*.s2)) -. 0.5*.(log (2.0*.pi)) -. 0.5*.(log s2)

let log_likelihood ms sigmas {mu1 = mu1; sigma1 = sigma1; mu2 = mu2; sigma2 = sigma2; f2 = f2} = 
  let sum = ref 0.0 in 
    for i = 0 to Array.length ms - 1 do 
      let ll1 = log_one_like mu1 sigma1 ms.(i) sigmas.(i) and 
          ll2 = log_one_like mu2 sigma2 ms.(i) sigmas.(i) in 
      let ll = log ((1.0-.f2)*.(exp ll1) +. f2*.(exp ll2)) in
      sum := !sum +. ll
    done;
    !sum +. 0.0

let _ = 
  Random.self_init (); (* Should come before arg parsing so that arg seed can re-seed RNG if necessary. *)
  Arg.parse options (fun _ -> ()) "gaussian.{native,byte} OPTIONS ...";
  let (ms,sigmas) = read_msigmas stdin in 
    Array.iteri
      (fun i m -> 
         let sigma = sigmas.(i) in 
           Printf.eprintf "m = %g, sigma = %g\n" m sigma)
      ms;
    flush stderr;
  let sample_n = float_of_int (Array.length ms) and 
      sample_sigma = std ms in 
    let start_ms = {mu1 = mean ms; sigma1 = sample_sigma;
                    mu2 = mean ms; sigma2 = sample_sigma;
                    f2 = 0.5} in 
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
          if i mod !nout = 0 then 
            Read_write.write_sample 
              (fun {mu1 = mu1; sigma1 = s1; mu2 = mu2; sigma2 = s2; f2 = f2} -> [| mu1; s1; mu2; s2; f2 |]) stdout !current_state
      done

