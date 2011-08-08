open Dist_base

let gaussian mu sigma x = 
  let d = mu -. x in 
  (exp ~-.((d*.d)/.(2.0*.sigma*.sigma))) /. (2.5066282746310005024 *. sigma)

let log_likelihood msamples = function 
  | [|mu; sigma|] -> 
    List.fold_left
      (fun ll msamples -> 
        let overlap = ref 0.0 and
            nsamples = Array.length msamples in
          for i = 0 to nsamples - 1 do
            let m = msamples.(i) in 
              overlap := !overlap +. gaussian mu sigma m
          done;
          ll +. (log (!overlap /. (float_of_int nsamples))))
      0.0
      msamples
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

let valid_state = function 
  | [|mu; sigma|] -> 
    mu >= !mmin && mu <= !mmax && sigma >= 0.0 && 
      mu +. 2.0*.sigma <= !mmax && mu -. 2.0*.sigma >= !mmin 
  | _ -> false

let log_prior state = 
    if valid_state state then 
      2.0794415416798359283 -. 2.0*.(log (!mmax -. !mmin))
    else
      neg_infinity

let draw_prior () = 
  let sigma_min = 0.0 and 
      sigma_max = (!mmax -. !mmin) /. 4.0 in
  let rec dp_loop () = 
    let mu = Stats.draw_uniform !mmin !mmax and 
        sigma = Stats.draw_uniform sigma_min sigma_max in 
    let state = [|mu; sigma|] in 
      if valid_state state then 
        state
      else
        dp_loop () in 
    dp_loop ()

let jump_proposal = function 
  | [|mu; sigma|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mu;
      Mcmc.uniform_wrapping 0.0 (!mmax -. !mmin) 1.0 sigma|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_prob _ _ = 0.0

