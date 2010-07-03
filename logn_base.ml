let mmin = ref 0.01
let mmax = ref 40.0

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
    let m = exp (mu +. 0.5*.sigma*.sigma) in
    let s = m *. (sqrt (exp (sigma*.sigma) -. 1.0)) in 
      [|m; s|]
  | _ -> raise (Invalid_argument "musigma_to_msigma")

let log_prior = function 
  | [|mu; sigma|] -> 
    let lmmax = log !mmax and 
        lmmin = log !mmin in
    if lmmin <= mu && mu <= lmmax && sigma >= 0.0 && 
      sigma <= 0.5*.(lmmax -. mu) then 
      let dlm = lmmax -. lmmin in 
        1.3862943611198906188 -. 2.0*.(log dlm)
    else
      neg_infinity
  | _ -> raise (Invalid_argument "log_prior: bad state")

let log_likelihood msamples = function 
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
  | [|mu; sigma|] -> 
    let dm = 0.2 in (* times 1.1, 0.9 *)
    let ds = 0.2 in
      [|mu +. dm*.(Random.float 1.0 -. 0.5);
        sigma +. ds*.(Random.float 1.0 -. 0.5)|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_prob _ _ = 0.0
        
let low_bounds () = [|log !mmin; 0.0|]
let high_bounds () = [|log !mmax; 0.5*.(log !mmax)|]
