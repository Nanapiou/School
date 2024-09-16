open Util_apprentissage

type arbre_decision = Noeud of int * arbre_decision array | Feuille of int

let tableaux_intervalles (k: int) (jeu: fleur list): float array array =
  let apply f =
    match List.map (fun i -> f (fun {mesures=e; _} -> e.(i)) jeu) (List.init 4 Fun.id) with
    | [{mesures=a; _}; {mesures=b; _}; {mesures=c; _}; {mesures=d; _}] -> [|a.(0); b.(1); c.(2); d.(3)|]
    | _ -> failwith "Unknown case"
  in
  let mi = apply minf in 
  let ma = apply maxf in
  (* print_float_list (Array.to_list mi);
  print_newline ();
  print_float_list (Array.to_list ma);
  print_newline (); *)
  let longueurs = Array.map (fun (mi, ma) -> (ma -. mi) /. float_of_int k) (Array.combine mi ma) in
  Array.mapi (fun i m -> Array.init (k - 1) (fun elt_i -> m +.  (float_of_int (elt_i + 1)) *. longueurs.(i))) mi

let determiner_intervalle (inter: float array) (f: float): int = 
  match Array.find_index ((<) f) inter with 
  | Some i -> i
  | None -> Array.length inter