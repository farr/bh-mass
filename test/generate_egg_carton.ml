let n = ref 1000000
let nosc = ref 3
let ndim = ref 2

let options = 
  [("-n", Arg.Set_int n, "N number of points to draw");
   ("-nosc", Arg.Set_int nosc, "NOSC number of oscillations in each dimension");
   ("-ndim", Arg.Set_int ndim, "NDIM number of dimensions") ]

let _ = 
  Random.self_init ();
  Arg.parse (Arg.align options) (fun _ -> ()) "generate_egg_carton.native OPTIONS ...";
  for i = 0 to !n - 1 do 
    let pt = Likelihoods.draw_egg_carton !nosc !ndim in 
      for j = 0 to !ndim - 2 do 
        Printf.printf "%g " pt.(j)
      done;
      Printf.printf "%g\n" pt.(!ndim - 1)
  done
