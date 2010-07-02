type state = 
  | Histogram of float array
  | Gaussian of float array
  | Power_law of float array
  | Two_gaussian of float array
  | Exp_cutoff of float array
  | Log_normal of float array

let state_to_array = function 
  | Histogram(x) -> Array.append [|0.0|] x
  | Gaussian(x) -> Array.append [|1.0|] x
  | Power_law(x) -> Array.append [|2.0|] x
  | Two_gaussian(x) -> Array.append [|3.0|] x
  | Exp_cutoff(x) -> Array.append [|4.0|] x
  | Log_normal(x) -> Array.append [|5.0|] x

let array_to_state x = 
  let n = Array.length x in
  let pt = Array.sub x 1 (n-1) in
  match x.(0) with 
    | 0.0 -> Histogram pt
    | 1.0 -> Gaussian pt
    | 2.0 -> Power_law pt
    | 3.0 -> Two_gaussian pt
    | 4.0 -> Exp_cutoff pt
    | 5.0 -> Log_normal pt
    | _ -> raise (Failure "array_to_state: bad first 'coordinate'")
