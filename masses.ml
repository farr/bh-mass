open Stats

let make_mass_generator draw_f draw_q draw_i = 
  fun () -> 
    let f = abs_float (draw_f ()) and 
        q = draw_q () and 
        i = draw_i () in 
    let qp1 = q +. 1.0 and 
        si = abs_float (sin i) in 
      f *. qp1 *. qp1 /. (si *. si *. si)

let pi = 3.1415926535897932385

let rad_of_deg d = 
  d *. pi /. 180.0

(* Greiner, Cuby, McCaughrean, 2001.  (Mass ratio derived from quoted masses!) *)
let grs_1915 = 
  make_mass_generator
    (fun () -> draw_gaussian 9.5 3.0)
    (fun () -> draw_gaussian 0.0857 0.0284)
    (fun () -> draw_gaussian (rad_of_deg 70.0) (rad_of_deg 2.0))

(* Gelino et. al., 2008.  (Also Harlaftis and Filippenko 2005.) *)
let xte_j1118 = 
  make_mass_generator
    (fun () -> draw_gaussian 6.44 0.08)
    (fun () -> draw_gaussian 0.0264 0.0040)
    (fun () -> draw_gaussian (rad_of_deg 68.0) (rad_of_deg 2.0))

(* Orosz, McClintock, Remillard, Corbel, 2004. *)
let xte_j1650 = 
  make_mass_generator
    (fun () -> draw_gaussian 2.73 0.56)
    (fun () -> draw_uniform 0.0 0.5) (* No constraints on mass ratio; use uniform for broad. *)
    (fun () -> draw_uniform (rad_of_deg 50.0) (rad_of_deg 80.0)) (* If no disk light, 50 +/- 3 *)

(* Orosz Nature paper. *)
let m33_x7 = 
  make_mass_generator
    (fun () -> draw_gaussian 0.46 0.08)
    (fun () -> draw_gaussian 4.47 0.61)
    (fun () -> draw_gaussian (rad_of_deg 74.6) (rad_of_deg 1.0))

(* Andy's A0620 paper; also Neilsen, Steeghs and Vrtilek, MNRAS,
   vol. 384, pp. 849--862, 2008. *)
let a0620 = 
  make_mass_generator
    (fun () -> draw_gaussian 3.10 0.04)
    (fun () -> draw_gaussian 0.06 0.004)
    (fun () -> draw_gaussian (rad_of_deg 50.98) (rad_of_deg 0.87))

(* Gelino and Harrison 2003 *)
let gro_j0422 = 
  make_mass_generator
    (fun () -> draw_gaussian 1.13 0.09)
    (fun () -> draw_gaussian 0.116 0.083)
    (fun () -> draw_gaussian (rad_of_deg 45.0) (rad_of_deg 2.0))

(* Gelino, Harrison, McNamara, 2001. *)
let nova_mus_1991 = 
  make_mass_generator
    (fun () -> draw_gaussian 3.01 0.15)
    (fun () -> draw_gaussian 0.128 0.04)
    (fun () -> draw_gaussian (rad_of_deg 54.0) (rad_of_deg 1.5))

(* Greene, Bailyn, Orosz, 2001. *)
let gro_j1655 = 
  make_mass_generator
    (fun () -> draw_gaussian 2.73 0.09)
    (fun () -> draw_gaussian 0.3663 0.04025)
    (fun () -> draw_gaussian (rad_of_deg 70.2) (rad_of_deg 1.9))

(* Orosz et al, 2001. *)
let v4641_sgr = 
  make_mass_generator
    (fun () -> draw_gaussian 2.74 0.04)
    (fun () -> draw_gaussian 0.6667 0.0356)
    (fun () -> draw_gaussian (rad_of_deg 65.0) (rad_of_deg 5.0))

let generators = 
  [grs_1915; xte_j1118; xte_j1650; m33_x7; a0620; gro_j0422; nova_mus_1991; gro_j1655; v4641_sgr]

let generate_samples nsamp = 
  List.map (fun gen -> Array.init nsamp (fun _ -> gen ())) generators
