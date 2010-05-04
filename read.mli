(** Utility code to read from channels sets of measured masses and the
    associated standard deviations. *)

(** [call_with_input_file file f] calls the function [f] with the
    result of [open_in file], but makes sure to close the file upon
    the return of [f], {b or} when an exception is thrown. *)
val call_with_input_file : string -> (in_channel -> 'a) -> 'a

(** Read from the given channel [m,sigma] pairs.  Reading stops when
    the [End_of_file] exception is encountered. *)
val read_msigmas : in_channel -> (float array) * (float array)
