open Kppv2
open Util_apprentissage
open Ddim
open Id3

let jeu_entr = lire_iris "../iris_jeu_entr.csv" 
let jeu_test = lire_iris "../iris_jeu_test.csv"

let arbre = creer_arbredd 4 (List.map (fun {mesures; etiquette} -> (etiquette, mesures)) jeu_entr)

(* let taux_erreur_selon_k dist k = taux_erreur_global @@ (matrice_confusion (k_plus_proches_voisins dist k jeu_entr)) jeu_test
let taux_euc = List.map (taux_erreur_selon_k distance_euc) (List.init 20 ((+) 1))
let taux_man = List.map (taux_erreur_selon_k distance_man) (List.init 20 ((+) 1))
let () =
  print_endline "Taux d'erreur en fonction de k avec distance euclidienne";
  print_float_list taux_euc;
  print_endline "Taux d'erreur en fonction de k avec distance de manhattan";
  print_float_list taux_man;
  print_newline ()

let mat = matrice_confusion (k_plus_proches_voisins distance_man 2 jeu_entr) jeu_test
let () = print_matrice mat *)

let mat = matrice_confusion (k_plus_proches_voisins2 5 arbre) jeu_test
let () = print_matrice mat

(* let intervalles = tableaux_intervalles 4 jeu_entr 
let () = 
  Array.iter (Fun.compose print_float_list Array.to_list) intervalles *)

let () = print_int (determiner_intervalle [|2.5; 5.; 7.5|] 0.2)