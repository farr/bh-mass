(** Turns a list of bin boundaries into points on the PDF.  The points
    are evenly spaced between the maximum and minimum mass. *)

open Printf

let nskip = ref 1

let options = 
  [("-nskip", Arg.Set_int nskip,
    sprintf "plot one histogram for every nskip lines on stdin (default %d)" !nskip)]

let write_one_histogram bins = 
  let nbins = Array.length bins - 1 in 
  let area = 1.0 /. (float_of_int nbins) in 
    for i = 0 to Array.length bins - 2 do 
      let x = 0.5*.(bins.(i) +. bins.(i+1)) and 
          y = area /. (bins.(i+1) -. bins.(i)) in 
        printf "%g %g\n" x y
    done

let _ = 
  Arg.parse options (fun _ -> ()) "bins_to_hist OPTIONS ... < input_file > output_file";
  let samples = Read_write.read (fun pt -> pt) stdin in 
    for i = 0 to Array.length samples - 1 do 
      if i mod !nskip = 0 then 
        let {Mcmc.value = bins} = samples.(i) in write_one_histogram bins
    done
