(** Useful statistical functions. *)

(** Mean. *)
val mean : float array -> float

(** Standard deviation; optionally, takes the mean as argument to
    avoid redundant computation. *)
val std : ?mu : float -> float array -> float
