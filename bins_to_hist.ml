(** Turns a list of bin boundaries into points on the PDF.  The points
    are evenly spaced between the maximum and minimum mass. *)

let npts = ref 10

let options = 
  [("-npts", Arg.Set_int npts,
    Printf.sprintf "number of points to sample histogram at (default %d)" !npts)]

let find_interval_start bdys (m : float) = 
  let n = Array.length bdys in 
  if m < bdys.(0) || m >= bdys.(n-1) then raise (Invalid_argument "find_interval_start: value not inside interval");  
  let rec find_interval_loop lowi highi = 
    if highi - lowi = 1 then 
      lowi
    else
      let midi = (highi + lowi) / 2 in 
        if bdys.(midi) <= m then 
          find_interval_loop midi highi
        else
          find_interval_loop lowi midi in 
    find_interval_loop 0 (n-1)

let eval_histogram bdys m = 
  let pbin = 1.0 /. (float_of_int (Array.length bdys - 1)) in 
  let ilow = find_interval_start bdys m in 
  let width = bdys.(ilow+1) -. bdys.(ilow) in 
    pbin /. width

let write_one_hist bdys = 
  let n = Array.length bdys in 
  let dm = (bdys.(n-1) -. bdys.(0)) /. (float_of_int !npts) in 
    for i = 0 to !npts - 1 do 
      let m = bdys.(0) +. ((float_of_int i) +. 0.5)*.dm in 
        Printf.printf "%g " (eval_histogram bdys m)
    done;
    Printf.printf "\n"

let _ = 
  Arg.parse options (fun _ -> ()) "bins_to_hist.{native,byte} OPTIONS ...";
  let samples = Read_write.read (fun pt -> pt) stdin in 
    Array.iter 
      (fun {Mcmc.value = v} -> write_one_hist v)
      samples
