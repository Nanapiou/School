type 'a regex = 
     | Empty
     | Epsilon
     | Letter of 'a
     | Concat of 'a regex * 'a regex
     | Union of 'a regex * 'a regex
     | Etoile of 'a regex;;

let parse s =
  let open Printf in
  let n = String.length s in
  let i = ref 0 in
  let rec peek () =
    if !i >= n then None else match s.[!i] with
    | ' ' -> incr i; peek ()
    | c   -> Some c in
  let eat x =
    match peek () with
    | Some y when y = x -> incr i;
    | Some y -> failwith (sprintf "expected %c, got %c" x y)
    | None -> failwith "incomplete" in
  let rec regex () =
    let t = term () in
    match peek () with
    | Some '|' -> eat '|'; Union (t, regex ())
    | _ -> t
  and term () =
    let f = factor () in
    match peek () with
    | None | Some ')' | Some '|' -> f
    | _ -> Concat (f, term ())
 and factor () =
    let rec aux acc =
      match peek () with
      | Some '*' -> eat '*'; aux (Etoile acc)
      | _ -> acc in
    aux (base ())
  and base () =
    match peek () with
    | Some '(' -> eat '('; let r = regex () in eat ')'; r
    | Some '&' -> eat '&'; Epsilon
    | Some '#' -> eat '#'; Empty
    | Some (')' | '|' | '*' as c) -> failwith (sprintf "unexpected '%c'" c)
    | Some c -> eat c; Letter c
    | None -> failwith "unexpected end of string" in
  let r = regex () in
  if !i = n then r else failwith "trailing ')' ?";;

let rec string_of_regex = function
  | Empty -> "#"
  | Epsilon -> "&"
  | Letter a -> String.make 1 a
  | Concat (a, b) -> string_of_regex a ^ string_of_regex b 
  | Union (a, b) -> "(" ^ string_of_regex a ^ "|" ^ string_of_regex b ^ ")"
  | Etoile a -> string_of_regex a ^ "*"


let is_empty: 'a regex -> bool = (==) Empty