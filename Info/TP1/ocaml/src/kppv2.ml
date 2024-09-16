open Ddim
open Util_apprentissage

type 'a file = 'a File_prio.file
let compare_couples (a, _) (b, _) = Float.compare a b
let enfiler = File_prio.file_enfiler compare_couples
let defiler = File_prio.file_defiler compare_couples


let k_plus_proches_voisins2 (k: int) (a: arbredd) (mesures: float array): int =
  let traiter f (x: float array) (c: int) =
    if File_prio.file_taille f < k then enfiler f (distance_man x mesures, c) else
    let (d, _) = File_prio.file_tete f in
    let dist = distance_man x mesures in 
    if d < dist then f 
    else let (f, _) = defiler f in enfiler f (dist, c)
  in
  let rec aux f = function
    | Feuille (x, c) -> traiter f x c
    | Noeud (i, y, c, gauche, droite) ->
      (* Doesn't stand for "Fuck You Coward" *)
      let f = traiter f y c in
      let first, second = if mesures.(i) < y.(i) then gauche, droite else droite, gauche in
      let f = aux f first in
      if File_prio.file_taille f < k then aux f second
      else
        let (dz, _) = File_prio.file_tete f in 
        if dz < y.(i) -. mesures.(i) then f 
        else aux f second
  in
  let f = aux File_prio.file_vide a in
  let result = Array.make 3 0 in 
  File_prio.file_iter (fun (_, c) -> result.(c - 1) <- result.(c - 1) + 1) f;
  max_index result + 1