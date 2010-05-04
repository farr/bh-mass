module Ev = Evidence.Make(
  struct
    type params = float array
    let to_coords sample = 
      Array.sub sample 1 (Array.length sample - 2)
  end)

let samples = Read_write.read (fun pt -> pt) stdin

let _ = 
  Printf.printf "%g %g\n"
    (Ev.evidence_direct samples)
    (Ev.evidence_harmonic_mean samples)
