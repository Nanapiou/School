type graphe = int list array 

let creer_graphe n = Array.make n []
let ajouter_arc g i j = g.(i) <- j :: g.(i)
let voisins g i = g.(i)

let dfs (g: graphe) = 
  let n = Array.length g in
  let visites = Array.make n false in
  let rec visite i =
    visites.(i) <- true;
    Printf.printf "%d " i;
    List.iter (fun j -> if not visites.(j) then visite j) (voisins g i)
  in
  for i = 0 to n - 1 do
    if not visites.(i) then visite i
  done

type couleur = Blanc | Gris | Noir
let possede_cycle g =
  let n = Array.length g in
  let couleurs = Array.make n Blanc in
  let rec visite i =
    couleurs.(i) <- Gris;
    let trouve_cycle = List.fold_left (fun trouve_cycle j ->
        match couleurs.(j) with
        | Gris -> true 
        | Blanc -> trouve_cycle || visite j
        | Noir -> trouve_cycle
      ) false (voisins g i)
    in
    couleurs.(i) <- Noir;
    trouve_cycle
  in
  List.fold_left
    (Fun.flip @@ Fun.compose (||) visite)
    false
    (List.init n Fun.id)

let uncurry f (x, y) = f x y

let g = creer_graphe 6
let () = List.iter (uncurry @@ ajouter_arc g) [
    (0, 1);
    (0, 2);
    (1, 3);
    (2, 5);
    (4, 0);
    (4, 1);
    (5, 3);
    (3, 4)
  ]
let () = dfs g
let () = Printf.printf "%s\n" (string_of_bool (possede_cycle g))