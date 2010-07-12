open Dist_base

let log_likelihood msamples = function 
  | [|mc; m0|] -> 
    let norm = (exp (mc /. m0)) /. m0 in
      List.fold_left
        (fun ll msamp -> 
          let n = Array.length msamp in 
          let overlap = ref 0.0 in 
            for i = 0 to n - 1 do 
              let m = msamp.(i) in 
                if m >= mc then 
                  overlap := !overlap +. norm *. (exp ~-.(msamp.(i) /. m0))
            done;
            ll +. log (!overlap /. (float_of_int n)))
        0.0
        msamples
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

let log_prior = function 
  | [|mc; m0|] -> 
    if mc >= !mmin && mc <= !mmax && m0 >= 0.0 && mc +. 2.0*.m0 <= !mmax then 
      1.3862943611198906188 -. 2.0*.(log (!mmax -. !mmin)) (* Log(4) is first constant. *)
    else
      neg_infinity
  | _ -> raise (Failure "log_prior: bad state")

let jump_proposal = function 
  | [|mc; m0|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mc;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 m0|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_probability _ _ = 0.0