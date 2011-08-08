open Dist_base

let alphamin = ref (-15.0)
let alphamax = ref 13.0

let log_likelihood msamples = function 
  | [|mmin; mmax; alpha|] -> 
    let ap1 = alpha +. 1.0 in 
    let norm = ap1 /. (mmax**ap1 -. mmin**ap1) in
    List.fold_left
      (fun ll msamp -> 
        let overlap = ref 0.0 and
            nsamp = Array.length msamp in
          for i = 0 to nsamp - 1 do 
            let m = msamp.(i) in 
              if mmin <= m && m <= mmax then
                overlap := !overlap +. norm*.m**alpha
          done;
          ll +. log (!overlap /. (float_of_int nsamp)))
      0.0
      msamples
  | _ -> raise (Invalid_argument "log_likelihood: bad state")

let log_prior state = 
  match state with 
    | [|minm; maxm; alpha|] ->
      if !mmin <= minm && maxm <= !mmax && minm < maxm && !alphamin <= alpha && alpha <= !alphamax then 
        let dm = !mmax -. !mmin in 
        let x = 2.0 /. ((!alphamax -. !alphamin) *. dm *. dm) in 
          log x
      else
        neg_infinity
    | _ -> raise (Invalid_argument "log_prior: bad state")

let rec draw_prior () = 
  let mlow = Stats.draw_uniform !mmin !mmax and 
      mhigh = Stats.draw_uniform !mmin !mmax and 
      alpha = Stats.draw_uniform !alphamin !alphamax in 
  let state = [|mlow; mhigh; alpha|] in 
    if log_prior state = neg_infinity then 
      draw_prior ()
    else
      state
