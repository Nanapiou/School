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

(* Renvoie une liste contenant les k premiers éléments de l *)
(* take 3 [5; 2; 3; 6; 4] = [5; 2; 3] *)
let rec take k l =
  if k <= 0 then []
  else match l with 
  | [] -> []
  | h :: t -> h :: (take (k - 1) t)

(* Une fonction générale de distance entre deux points *)
(* fd: La fonction à appliquer à la somme *)
(* ff: La fonction à appliquer à deux coordonnée *)
(* a1 et a2: Les deux points à comparer *)
let distance fd ff a1 a2 =
  fd @@ Array.fold_left (fun acc (x, x') -> acc +. ff x x') 0. (Array.combine a1 a2)

let distance_man = distance Fun.id (fun x x' -> abs_float (x -. x'))
let distance_euc = distance sqrt (fun x x' -> (x -. x') *. (x -. x'))

(* Renvoie l'index du plus grand élément de a *)
let max_index a =
  let l = Array.length a in 
  let rec aux acc i =
    if i = l then acc 
    else
      aux (if a.(i) > a.(acc) then i else acc) (i + 1)
  in
  aux 0 1

(* Contre le nombre d'occurences de e dans un tableau *)
let count e = Array.fold_left (fun acc e' -> if e = e' then acc + 1 else acc) 0

let rec minf f = function
  | [] -> failwith "Nah fuck you"
  | h :: t ->
    let rec aux acc = function
      | [] -> acc 
      | h :: t -> aux (if f h < f acc then h else acc) t
    in
    aux h t

(* Renvoie la classe supposée en utilisant l'algo des k-plus proches voisins *)
(* dist: la fcontion de distance utilisée *)
(* k: Le nombre de voisins à utiliser *)
(* fleurs: Le jeu d'entraînement *)
(* f: Les mesures de la fleur à tester *)
let k_plus_proches_voisins (dist: float array -> float array -> float) (k: int) (fleurs: fleur list) (f: float array) : int =
  let distances = List.sort (fun (a,_) (b,_) -> int_of_float (a -. b)) @@ List.map (fun fl -> (dist fl.mesures f, fl.etiquette)) fleurs in
  let k_plus_proches = take k distances in
  let a = Array.make 3 0 in
  List.iter (fun (_, e) -> a.(e - 1) <- a.(e - 1) + 1) k_plus_proches;
  let i = max_index a in
  let n = a.(i) in
  if count n a >= 2 then
    snd @@ minf (fun (d, _) -> d) (List.filter (fun (d, e) -> a.(e - 1) = n) k_plus_proches)
  else i + 1

(* Renvoie la matrice de confusion d'un jeu de test "fleurs" en utilisant la fonction "f" pour deviner la classe *)
let matrice_confusion (f: float array -> int) (fleurs: fleur list): int array array =
  let mat = Array.make_matrix 3 3 0 in 
  List.iter (fun {mesures; etiquette} ->
    let i = etiquette - 1 in 
    let j = f mesures - 1 in
    mat.(i).(j) <- mat.(i).(j) + 1
  ) fleurs;
  mat

(* Renvoie une liste contenant les éléments dans la diagonale de m *)
let get_diag m =
  let n = Array.length m in 
  let rec aux i =
    if i = n then []
    else m.(i).(i) :: aux (i + 1)
  in aux 0

(* Renvoie e/t avec e le nombre d'erreurs et t le nombre total d'éléments *)
let taux_erreur_global (mat: int array array): float =
  let tot = Array.fold_left (+) 0 (Array.map (Array.fold_left (+) 0) mat) in
  let err = tot - (List.fold_left (+) 0 (get_diag mat)) in 
  float_of_int err /. float_of_int tot

let jeu_entr = lire_iris "iris_jeu_entr.csv" 
let jeu_test = lire_iris "iris_jeu_test.csv"
let taux_erreur_selon_k dist k = taux_erreur_global @@ (matrice_confusion (k_plus_proches_voisins dist k jeu_entr)) jeu_test
let taux_euc = List.map (taux_erreur_selon_k distance_euc) (List.init 20 ((+) 1))
let taux_man = List.map (taux_erreur_selon_k distance_man) (List.init 20 ((+) 1))
let () =
  print_endline "Taux d'erreur en fonction de k avec distance euclidienne";
  print_float_list taux_euc;
  print_endline "Taux d'erreur en fonction de k avec distance de manhattan";
  print_float_list taux_man;