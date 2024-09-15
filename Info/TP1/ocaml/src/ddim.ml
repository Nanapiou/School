type arbredd = Noeud of  int array * arbredd * arbredd | Feuille of int array
type fleur = {mesures : float array; etiquette : int}

let lire_iris (nom_fichier:string) =
  let fichier = open_in nom_fichier in
  let rec lecture_ligne_a_ligne fleurs =
       match In_channel.input_line fichier with
      | None -> fleurs
      | Some ligne -> 
        let liste_attributs = String.split_on_char ',' ligne in
        let tab_attributs = Array.of_list liste_attributs in
        let x0 = float_of_string tab_attributs.(0) in
        let x1 = float_of_string tab_attributs.(1) in
        let x2 = float_of_string tab_attributs.(2) in
        let x3 = float_of_string tab_attributs.(3) in
        let espece = 
          if tab_attributs.(4) = "setosa" then 1
          else if tab_attributs.(4) = "versicolor" then 2
          else if tab_attributs.(4) = "virginica" then 3        
          else failwith "nom d'espèce invalide"
        in
          {mesures = [|x0;x1;x2;x3|]; etiquette = espece}::(lecture_ligne_a_ligne fleurs)
  in 
  let _ = In_channel.input_line fichier in  
  lecture_ligne_a_ligne []

(* Affiche une liste de fleurs *)
let print_fleur_list: fleur list -> unit =
  List.iter (fun fleur -> 
    Printf.printf "mesures = [| %.3f ; %.3f ; %.3f ; %.3f |] etiquette = %d\n" 
    fleur.mesures.(0) fleur.mesures.(1) fleur.mesures.(2) fleur.mesures.(3) fleur.etiquette
  )

(* Affiche une matrice *)
let print_matrice (mat: int array array): unit =
  Array.iter (fun ligne ->
    Array.iter (fun x -> Printf.printf "%d " x) ligne;
    print_newline ()
  ) mat

(* Affiche une liste de flottants *)
let print_float_list: float list -> unit =
  List.iter (fun x -> Printf.printf "%.3f\n" x)


let minf f =
  function
  | [] -> failwith "Not with an empty list u bastard"
  | h :: l -> 
    let rec aux e = function
      | [] -> e 
      | h :: t -> aux (if f h < f e then h else e) t
    in
    aux h l

let maxf f =
  function
  | [] -> failwith "Not with an empty list u bastard"
  | h :: l -> 
    let rec aux e = function
      | [] -> e 
      | h :: t -> aux (if f h > f e then h else e) t
    in
    aux h l


(* Renvoie l'index du plus grand élément de a *)
let max_index a =
  let l = Array.length a in 
  let rec aux acc i =
    if i = l then acc 
    else
      aux (if a.(i) > a.(acc) then i else acc) (i + 1)
  in
  aux 0 1

let find_dimension d e =
  let widths = Array.make d 0 in 
  for i = 0 to d - 1 do
    let mi = minf (Fun.flip (Array.get) i) e in
    let ma = maxf (Fun.flip (Array.get) i) e in
    widths.(i) <- ma.(i) - mi.(i)
  done;
  max_index widths

let find_mid_elt i e =
  let l = List.length e in 
  let e = List.sort (fun a b -> a.(i) - b.(i)) e in
  List.nth e (l / 2)


let rec creer_arbredd (d: int) = function
  | [] -> failwith "How mf"
  | [elt] -> Feuille elt 
  | e ->
    let i = find_dimension d e in 
    let x = find_mid_elt i e in 
    (* We can do both at the same time, but I'm lazy *)
    let left = List.filter (fun elt -> elt.(i) <= x.(i) && elt <> x) e in
    let right = List.filter (fun elt -> elt.(i) > x.(i) && elt <> x) e in
    Noeud (x, creer_arbredd d left, creer_arbredd d right)

let k_plus_proches_voisins2 (k: int) (a: arbredd) (mesures: float array): int =
  