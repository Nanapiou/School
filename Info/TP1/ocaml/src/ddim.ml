open Util_apprentissage
(* Noeud of dim * point * classe *)
type arbredd = Noeud of int * float array * int * arbredd * arbredd | Vide

(*
Trouve sur quelle dimension découper
d: Nombre de dimensions
e: Ensemble de etiquette * mesures
*)
let find_dimension d e =
  let widths = Array.make d 0. in 
  for i = 0 to d - 1 do
    let mi = minf (Fun.flip (Array.get) i) (List.map snd e) in
    let ma = maxf (Fun.flip (Array.get) i) (List.map snd e) in
    widths.(i) <- ma.(i) -. mi.(i)
  done;
  max_index widths

(*
Trouve sur quel élément découper
i: la dimension
e: l'ensemble
*)
let find_mid_elt i e =
  let l = List.length e in 
  let e = List.sort (fun (_, a) (_, b) -> sgn (a.(i) -. b.(i))) e in
  List.nth e (l / 2)

(*
Créé l'arbre d-dimensionnel
d: nombre de dimension (Normalement non nécessaire, car Array.length?)
e: Ensemble (liste) de etiquette * mesures
*)
let rec creer_arbredd (d: int): (int * float array) list -> arbredd = function
  | [] -> Vide
  | e ->
    let i = find_dimension d e in 
    let c, x = find_mid_elt i e in 
    (* We can do both at the same time, but I'm lazy *)
    let left = List.filter (fun (_, elt) -> elt.(i) <= x.(i) && elt <> x) e in
    let right = List.filter (fun (_, elt) -> elt.(i) > x.(i) && elt <> x) e in
    Noeud (i, x, c, creer_arbredd d left, creer_arbredd d right)

  