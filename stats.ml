let mean xs = 
  let mu = ref 0.0 and 
      n = Array.length xs in 
    for i = 0 to n - 1 do 
      mu := !mu +. xs.(i)
    done;
    !mu/.(float_of_int n)

let std ?mu xs = 
  let mu = 
    match mu with 
      | None -> mean xs 
      | Some(mu) -> mu in 
  let std = ref 0.0 and 
      n = Array.length xs in 
    for i = 0 to n - 1 do 
      let tmp = xs.(i) -. mu in 
        std := !std +. tmp*.tmp
    done;
    sqrt (!std/.(float_of_int (n-1)))
