open Dist_base

let msigma_to_musigma = function 
  | [|m; sigmam|] -> 
    let som = sigmam/.m in
    let sigma2 = log (1.0 +. som*.som) in 
    let mu = (log m) -. 0.5*.sigma2 and 
        sigma = sqrt sigma2 in 
      [|mu; sigma|]
  | _ -> raise (Invalid_argument "msigma_to_musigma")

let musigma_to_msigma = function 
  | [|mu; sigma|] -> 
    let sig2 = sigma*.sigma in
    let m = exp (mu +. 0.5*.sig2) in
    let s = m *. (sqrt (exp sig2 -. 1.0)) in 
      [|m; s|]
  | _ -> raise (Invalid_argument "musigma_to_msigma")

let log_prior = function 
  | [|m; sigmam|] -> 
    if m >= !mmin && m <= !mmax && 
      sigmam > 0.0 && sigmam <= (!mmax -. m)/.2.0 then 
      1.3862943611198906188 -. 2.0*.(log (!mmax -. !mmin)) (* Log(4) is first constant. *)
    else
      neg_infinity
  | _ -> raise (Invalid_argument "log_prior: bad state")

let log_likelihood msamples state = 
  match msigma_to_musigma state with 
    | [|mu; sigma|] -> 
      List.fold_left
        (fun ll msamp -> 
          let n = Array.length msamp in 
          let sum = ref 0.0 in 
            for i = 0 to n - 1 do 
              sum := !sum +. (exp (Stats.log_lognormal mu sigma msamp.(i)))
            done;
            ll +. (log (!sum /. (float_of_int n))))
        0.0
        msamples
    | _ -> raise (Invalid_argument "log_likelihood: bad state")

let jump_proposal = function 
  | [|m; sigmam|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 m;
      Mcmc.uniform_wrapping 0.0 (0.5*.(!mmax)) 1.0 sigmam|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_prob _ _ = 0.0
        
let low_bounds () = [|!mmin; 0.0|]
let high_bounds () = [|!mmax; 0.5*.(!mmax)|]
