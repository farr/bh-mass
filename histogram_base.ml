open Dist_base

let fixedbin = ref false
let nbinmax = ref 5

let compare_float (x : float) y = Pervasives.compare x y

let log_likelihood msamples = 
  let msamples = 
    List.map 
      (fun msamp -> 
        let msamp = Array.copy msamp in 
          Array.fast_sort compare_float msamp;
          msamp)
      msamples in 
    fun bins -> 
      List.fold_left
        (fun ll msamp -> 
          let nm = Array.length msamp and 
              nb = Array.length bins in
          let rec overlap_loop im ib ol = 
            if im >= nm then 
              ol /. (float_of_int nm)
            else if ib >= nb - 1 then 
              ol /. (float_of_int nm)
            else
              let m = msamp.(im) and 
                  low = bins.(ib) and 
                  high = bins.(ib+1) in
                if m < low then 
                  overlap_loop (im+1) ib ol
                else if m >= high then 
                  overlap_loop im (ib+1) ol
                else
                  overlap_loop (im+1) ib (ol +. 1.0 /. ((float_of_int (nb-1))*.(high-.low))) in 
          let overlap = overlap_loop 0 0 0.0 in 
            ll +. (log overlap))
        0.0
        msamples

let log_factorial n = 
  let sum = ref 0.0 in 
    for i = 2 to n do 
      sum := !sum +. (log (float_of_int i))
    done;
    !sum

let log_prior bins = 
  let log_bin_factor = if !fixedbin then 0.0 else ~-.(log (float_of_int !nbinmax)) in
  let n = Array.length bins in 
    (log_factorial n) +. log_bin_factor -. (float_of_int n)*.(log (!mmax -. !mmin))
