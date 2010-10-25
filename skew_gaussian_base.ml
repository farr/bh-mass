open Dist_base

let alpha_min = ref (-5.0)
let alpha_max = ref 20.0

let gaussian x = 
  exp (-0.5*.x*.x) /. 2.5066282746310005024

let gaussian_cdf x = 
  0.5*.(1.0 +. Gsl_sf.erf (x /. 1.4142135623730950488))

(* Note: mu, sigma are not the mean and standard deviation here! *)
let skew_gaussian xi omega alpha x = 
  let arg = (x -. xi) /. omega in 
    (2.0/.omega)*.(gaussian arg)*.(gaussian_cdf (alpha*.arg))

let delta alpha = alpha /. sqrt (1.0 +. alpha*.alpha)

let mu_sigma_to_xi_omega = function 
  | [|mu; sigma; alpha|] -> 
    [|mu -. 
        (1.4142135623730950488 *. alpha *. sigma) /. 
        ((sqrt (1.0 +. alpha*.alpha))*.
            (sqrt (1.1415926535897932385 +. 2.0 /. (1.0 +. alpha*.alpha))));
      sigma /. (sqrt (1.0 -. 2.0*.alpha*.alpha /. (3.1415926535897932385*.(1.0 +. alpha*.alpha))))|]
  | _ -> raise (Invalid_argument "mu_sigma_to_xi_omega: bad state")

let log_likelihood msamples = function 
  | [|mu; sigma; alpha|] as state -> 
    (match mu_sigma_to_xi_omega state with 
      | [|xi; omega|] ->
        List.fold_left
          (fun ll msamples -> 
            let overlap = ref 0.0 and 
                nsamples = Array.length msamples in 
              for i = 0 to nsamples - 1 do 
                let m = msamples.(i) in 
                  overlap := !overlap +. skew_gaussian xi omega alpha m
              done;
              ll +. (log (!overlap /. (float_of_int nsamples))))
          0.0
          msamples
      | _ -> raise (Failure "log_likelihood: bad state transformation"))
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

(* The parameterization is mu, sigma, alpha; restrict the prior volume
   in the same way as the Gaussian, so that the bounds are always at
   least two sigma away from the mean.*)
let log_prior = function 
  | [|mu; sigma; alpha|] -> 
    if mu >= !mmin && mu <= !mmax && sigma >= 0.0 && 
      mu +. 2.0*.sigma <= !mmax && mu -. 2.0*.sigma >= !mmin && 
      !alpha_min <= alpha && alpha <= !alpha_max then 
      2.0794415416798359283 -. 2.0*.(log (!mmax -. !mmin)) -. (log (!alpha_max -. !alpha_min))
    else
      neg_infinity
  | _ -> raise (Failure "log_prior: bad state")

let jump_proposal = function 
  | [|mu; sigma; alpha|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mu;
      Mcmc.uniform_wrapping 0.0 (!mmax -. !mmin) 1.0 sigma;
      Mcmc.uniform_wrapping !alpha_min !alpha_max 1.0 alpha|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_prob _ _ = 0.0
