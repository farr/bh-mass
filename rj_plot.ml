open Plplot

let re_ordering = 
  [|4; 5; 6; 7; 8; 1; 2; 0; 3|]

let data = 
  let inp = open_in "reversible-jump.dat" in 
  let d = Array.init 9 (fun _ -> Scanf.fscanf inp " %d " (fun x -> x)) in 
    close_in inp;
    let res = Array.make 9 0.0 in 
      for i = 0 to 8 do  
        res.(re_ordering.(i)) <- float_of_int d.(i)
      done;
      res

let names = 
  [|"Exp"; "Gaussian"; "Power Law"; "Two Gaussian";
    "Hist (1)"; "Hist (2)"; "Hist (3)"; "Hist (4)"; "Hist (5)"|]

let ndata = 
  Array.fold_left (+.) 0.0 data

let (datamax, datamin) = 
  let pairs = 
    Array.map 
      (fun d -> 
        let p = d /. ndata in 
        let sd = sqrt (ndata*.p*.(1.0 -. p)) in
          (d +. sd,
           d -. sd))
      data in 
        (Array.map fst pairs,
         Array.map snd pairs)

let log10 x = (log x) /. (log 10.0)

let ymin = (Array.fold_left min infinity datamin) /. 3.0
let ymax = (Array.fold_left max neg_infinity datamax) *. 6.0

let xs = Array.init 9 (fun i -> float_of_int i)

let _ = 
  plparseopts Sys.argv [PL_PARSE_FULL];
  plinit ();
  plenv (-1.0) 9.0 (log10 ymin) (log10 ymax) 0 20;
  plpoin xs (Array.map log10 data) 2;
  pllab "" "N" "";
  Array.iteri
    (fun i name -> 
      plptex xs.(i) (log10 (1.3*.data.(i))) 0.0 1.0 0.0 name)
    names;
  plend ()
