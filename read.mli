(** Utility code to read from channels sets of measured masses and the
    associated standard deviations. *)

(** Read from the given channel [m,sigma] pairs.  Reading stops when
    the [End_of_file] exception is encountered. *)
val read_msigmas : in_channel -> (float array) * (float array)
