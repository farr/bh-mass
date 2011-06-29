let nrj = ref 1000000
let nsamp = ref 100000
let ndim = ref 5
let ncarton = ref 5

let options = 
  [("-nrj", Arg.Set_int nrj, "N number of RJMCMC jumps");
   ("-nsamp", Arg.Set_int nsamp, "N number of samples in each model");
   ("-ndim", Arg.Set_int ndim, "N number of dimensions");
   ("-ncarton", Arg.Set_int ncarton, "N number of 'egg cartons'")]

module Interp = Interpolate_pdf.Make(struct
  type point = float array
  let coord (x : point) = x
  let point (x : float array) = x
end)

let _ = 
  Random.self_init ();
  Arg.parse (Arg.align options) (fun _ -> ()) "rj_test.native OPTIONS ...";
  let mu = Array.make !ndim 0.5 and 
      sigma = Array.init !ndim (fun i -> 0.05 /. (float_of_int (i+1))) in
  let interp_egg = 
    Interp.make (Array.init !nsamp (fun _ -> Likelihoods.draw_egg_carton !ncarton !ndim))
      (Array.make !ndim 0.0) (Array.make !ndim 1.0) and 
      interp_gauss = 
    Interp.make (Array.init !nsamp (fun _ -> Likelihoods.draw_multi_gaussian mu sigma))
      (Array.make !ndim 0.0) (Array.make !ndim 1.0) in 
  let e_jump_prop _ = Interp.draw interp_egg and 
      g_jump_prop _ = Interp.draw interp_gauss in 
  let log_e_jump_prob _ x = log (Interp.jump_prob interp_egg () x) and 
      log_g_jump_prob _ x = log (Interp.jump_prob interp_gauss () x) in 
  let rj_samps = 
    Mcmc.rjmcmc_array ~nskip:100 !nrj
      ((fun x -> Likelihoods.log_egg_carton_likelihood !ncarton x), 
       (fun x -> Likelihoods.log_multi_gaussian mu sigma x))
      ((fun x -> 0.0), (fun x -> 0.0))
      (e_jump_prop, g_jump_prop)
      (log_e_jump_prob, log_g_jump_prob)
      (e_jump_prop, g_jump_prop)
      (log_e_jump_prob, log_g_jump_prob)
      (0.5, 0.5)
      (Interp.draw interp_egg, Interp.draw interp_gauss) in 
  let (ne, ng) = Mcmc.rjmcmc_model_counts rj_samps in 
    Printf.printf "With %d egg carton and %d Gaussian counts, evidence ratio is %g\n"
      ne ng (Mcmc.rjmcmc_evidence_ratio rj_samps)
