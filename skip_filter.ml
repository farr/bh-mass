let infile = ref ""

let options = 
  [("-i", Arg.Set_string infile, "input file")]

let _ = 
  Arg.parse options (fun _ -> ()) "skip_filter.{byte,native} OPTIONS ...";
  let infile = !infile in 
  let inp = open_in infile in 
  let samples = Read_write.read (fun x -> x) inp in 
    close_in inp;
    let outfile = infile ^ ".tmp" in
    let out = open_out outfile in 
      for i = 0 to Array.length samples - 1 do 
        if i mod 5 = 0 then 
          Read_write.write_sample (fun x -> x) out samples.(i)
      done;
      close_out out;
      Unix.rename outfile infile
