open Util_apprentissage

type arbre_decision = Noeud of int * arbre_decision array | Feuille of int

let tableaux_intervalles (k: int) (jeu: fleur list): float array array =
  let apply f =
    match List.map (fun i -> f (fun {mesures=e; _} -> e.(i)) jeu) (List.init 4 Fun.id) with
    | [{mesures=a; _}; {mesures=b; _}; {mesures=c; _}; {mesures=d; _}] -> [|a.(0); b.(1); c.(2); d.(3)|]
    | _ -> failwith "Unknown case in tableaux_intervalles"
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

let classifier_jeu (k: int) (jeu: fleur list) = 
  let inters = tableaux_intervalles k jeu in 
  List.map
    (fun {mesures; etiquette=e} -> (Array.mapi (fun i e -> determiner_intervalle inters.(i) e) mesures, e))
    jeu

let entropie (e: (int array * int) list) =
  let classes = List.map snd e in
  let len = List.length e in
  let c = Array.make (List.fold_left max 0 classes) 0 in 
  List.iter (fun i -> c.(i) <- c.(i) + 1) classes;
  Array.fold_left (fun acc ci ->
    let prop = (float_of_int ci /. float_of_int len) in 
    acc -. prop *. Float.log2 prop
  ) 0. c

let gain (e: (int array * int) list) (a: int) = 
  let h = entropie e in
  let len = List.length e in
  let vals = List.sort Int.compare @@ List.map (fun (arr, _) -> arr.(a)) e in
  let groups = group vals in
  List.fold_left (fun acc g ->
    let prop = float_of_int (List.length g) /. float_of_int len in 
    acc -. prop *. entropie (List.filter (fun (m, _) -> m.(a) = List.hd g) e)
  ) h groups



let id3 (k: int) (jeu_entr: fleur list): arbre_decision =
  let jeu = classifier_jeu k jeu_entr in 
  let attributs = List.init (Array.length (fst (List.hd jeu))) Fun.id in
  let rec aux att = function
    | [] -> failwith "Idk why e is empty"
    | e ->
      let gains = List.map (fun a -> (a, gain e a)) att in 
      let (a, max_g) = maxf snd gains in 
      let vals = Array.of_list @@ remove_duplicate (List.map (fun (arr, _) -> arr.(a)) e) in
      Noeud (a, Array.map)