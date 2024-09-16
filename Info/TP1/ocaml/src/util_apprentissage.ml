type fleur = {mesures : float array; etiquette : int}
type ('a, 'b) either = ('a, 'b) Either.t

(* Don't worry I know what I'm doing *)
(* It's needed for the use of Either in the pattern matching *)
[@@@warning "-8"]
let lire_iris (nom_fichier:string) =
  let fichier = open_in nom_fichier in
  let rec lecture_ligne_a_ligne fleurs =
       match In_channel.input_line fichier with
      | None -> fleurs
      | Some ligne -> 
        let [Left x0; Left x1; Left x2; Left x3; Right e] = List.mapi
          (fun i e -> if i = 4 then Either.Right e else Either.Left (float_of_string e)) 
          (String.split_on_char ',' ligne)
        in
        let espece = 
          match e with
          | "setosa" -> 1
          | "versicolor" -> 2
          | "virginica" -> 3
          | _ -> failwith "nom d'espèce invalide"
        in
          {mesures = [|x0;x1;x2;x3|]; etiquette = espece} :: (lecture_ligne_a_ligne fleurs)
  in 
  let _ = In_channel.input_line fichier in  
  lecture_ligne_a_ligne []
[@@@warning "+8"]

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

let minf f = function
  | [] -> failwith "Nah fuck you"
  | h :: t ->
    let rec aux acc = function
      | [] -> acc 
      | h :: t -> aux (if f h < f acc then h else acc) t
    in
    aux h t

let maxf f = function
| [] -> failwith "Nah fuck you"
| h :: t ->
  let rec aux acc = function
    | [] -> acc 
    | h :: t -> aux (if f h > f acc then h else acc) t
  in
  aux h t

let sgn x = if x < 0. then -1 else if x > 0. then 1 else 0

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