open Iris
open Util_apprentissage

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
  print_newline ()

let mat = matrice_confusion (k_plus_proches_voisins distance_man 2 jeu_entr) jeu_test
let () = print_matrice mat