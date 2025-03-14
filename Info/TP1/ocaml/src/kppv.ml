open Util_apprentissage

(* Renvoie la classe supposée en utilisant l'algo des k-plus proches voisins *)
(* dist: la fcontion de distance utilisée *)
(* k: Le nombre de voisins à utiliser *)
(* fleurs: Le jeu d'entraînement *)
(* f: Les mesures de la fleur à tester *)
let k_plus_proches_voisins (dist: float array -> float array -> float) (k: int) (fleurs: fleur list) (f: float array) : int =
  let distances = List.sort (fun (a,_) (b,_) -> sgn (a -. b)) @@ List.map (fun fl -> (dist fl.mesures f, fl.etiquette)) fleurs in
  let k_plus_proches = take k distances in
  let a = Array.make 3 0 in
  List.iter (fun (_, e) -> a.(e - 1) <- a.(e - 1) + 1) k_plus_proches;
  max_index a + 1