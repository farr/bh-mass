open Dist_base

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
  if mu >= !mmin && mu <= !mmax && sigma >= 0.0 && 
    mu +. 2.0*.sigma <= !mmax && mu -. 2.0*.sigma >= !mmin then 
    2.0794415416798359283 -. 2.0*.(log (!mmax -. !mmin))
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

let rec draw_prior () = 
  match ((Gaussian_base.draw_prior ()), (Gaussian_base.draw_prior ())) with 
    | [|mu1; sigma1|], [|mu2; sigma2|] -> 
      let a = Stats.draw_uniform 0.0 1.0 in 
      let state = [|mu1; mu2; sigma1; sigma2; a|] in 
        if log_prior state = neg_infinity then 
          draw_prior ()
        else
          state
    | _ -> raise (Failure "draw_prior: Gaussian_base.draw_prior returned bad state")
