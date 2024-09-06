type fleur = {mesures : float array; etiquette : int}
let ( @. ) = Fun.compose

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


let print_fleur_list =
  List.iter (fun fleur -> 
    Printf.printf "mesures = [| %f ; %f ; %f ; %f |] etiquette = %d\n" 
    fleur.mesures.(0) fleur.mesures.(1) fleur.mesures.(2) fleur.mesures.(3) fleur.etiquette
  )

let rec take k l =
  if k <= 0 then []
  else match l with 
  | [] -> []
  | h :: t -> h :: (take (k - 1) t)

type fonction_de_classification = float array -> int

let k_plus_proches_voisins (k: int) (fleurs: fleur list) (f: float array) : int =
  let distance (f1: float array) (f2: float array) =
    Array.fold_left (fun acc (x, x') -> acc +. abs_float (x -. x')) 0. (Array.combine f1 f2)
  in
  let distances = List.sort (fun (a,_) (b,_) -> int_of_float (a -. b)) @@ List.map (fun fl -> (distance fl.mesures f, fl.etiquette)) fleurs in
  let k_plus_proches = take k distances in
  let (f1, f2, f3) = List.fold_left (fun (f1, f2, f3) (_, e) ->
    match e with
      | 1 -> (f1 + 1, f2, f3)
      | 2 -> (f1, f2 + 1, f3)
      | 3 -> (f1, f2, f3 + 1)
      | _ -> (f1, f2, f3)
    ) (0, 0, 0) k_plus_proches
  in
  if f1 = f2 && f2 = f3 then snd @@ List.hd k_plus_proches
  else if f1 >= f2 && f1 >= f3 then 1
  else if f2 >= f1 && f2 >= f3 then 2
  else 3

let matrice_confusion (fleurs: fleur list) (f: fonction_de_classification): int array array =
  let mat = Array.make_matrix 3 3 0 in 
  List.iter (fun {mesures; etiquette} ->
    let i = etiquette - 1 in 
    let j = f mesures - 1 in
    mat.(i).(j) <- mat.(i).(j) + 1
  ) fleurs;
  mat

let print_matrice_confusion mat =
  Array.iter (fun ligne ->
    Array.iter (fun x -> Printf.printf "%d " x) ligne;
    print_newline ()
  ) mat

let () =
  let jeu_entr = lire_iris "iris_jeu_entr.csv" in
  let jeu_test = lire_iris "iris_jeu_test.csv" in
  let mat = matrice_confusion jeu_test (k_plus_proches_voisins 5 jeu_entr) in
  print_matrice_confusion mat