open Dist_base

let log_likelihood msamples = function 
  | [|mc; m0|] -> 
    let norm = (exp (mc /. m0)) /. m0 in
    let ll = 
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
        msamples in 
      (* For some reason, have to worry about NaN's here? *)
      match classify_float ll with 
        | FP_nan -> neg_infinity
        | _ -> ll
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

let log_prior = function 
  | [|mc; m0|] -> 
    if mc >= !mmin && mc <= !mmax && m0 >= 0.0 && mc +. 2.0*.m0 <= !mmax then 
      1.3862943611198906188 -. 2.0*.(log (!mmax -. !mmin)) (* Log(4) is first constant. *)
    else
      neg_infinity
  | _ -> raise (Failure "log_prior: bad state")

let draw_prior () = 
  let m0_min = 0.0 and 
      m0_max = (!mmax -. !mmin) /. 2.0 in 
  let rec dp_loop () = 
    let mc = Stats.draw_uniform !mmin !mmax and 
        m0 = Stats.draw_uniform m0_min m0_max in 
    let state = [|mc; m0|] in 
      if log_prior state = neg_infinity then 
        dp_loop ()
      else
        state in 
    dp_loop ()

let jump_proposal = function 
  | [|mc; m0|] -> 
    [|Mcmc.uniform_wrapping !mmin !mmax 1.0 mc;
      Mcmc.uniform_wrapping !mmin !mmax 1.0 m0|]
  | _ -> raise (Invalid_argument "jump_proposal: bad state")

let log_jump_probability _ _ = 0.0
