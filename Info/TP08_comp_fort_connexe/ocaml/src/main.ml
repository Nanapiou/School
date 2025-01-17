type graphe = int list array

let afficher_int_list l = 
  Printf.printf "[%s]\n" (String.concat "; " (List.map string_of_int l))

let afficher_int_list_list l = 
  Printf.printf "[\n";
  List.iter (fun l -> Printf.printf "   [%s]\n" (String.concat "; " (List.map string_of_int l))) l;
  Printf.printf "]\n"

let afficher_int_array l = 
  Printf.printf "[|%s|]\n" (String.concat "; " (List.map string_of_int (Array.to_list l)))

let creer_graphe n = Array.make n []
let ajouter_arc g i j = g.(i) <- j :: g.(i)
let voisins g i = g.(i)
let transpose (g: graphe) = 
  let g' = creer_graphe (Array.length g) in
  Array.iteri (fun i voisins ->
      List.iter (Fun.flip (ajouter_arc g') i) voisins
    ) g;
  g'

let parcours_postfixe (g: graphe) =
  let n = Array.length g in
  let visites = Array.make n false in
  let rec aux l i =
    if visites.(i) then l
    else begin
      visites.(i) <- true;
      i :: List.fold_left aux l g.(i)
    end
  in
  List.fold_left aux [] (List.init n Fun.id)

let kosaraju (g: graphe) =
  let n = Array.length g in
  let gt = transpose g in
  let l = parcours_postfixe gt in 
  let classes = Array.make n (-1) in
  let rec aux c i =
    if classes.(i) <> -1 then ()
    else begin
      classes.(i) <- c;
      List.iter (aux c) g.(i)
    end
  in
  let rec loop c = function
    | [] -> c
    | h :: t when classes.(h) = -1 -> aux c h; loop (c + 1) t
    | _ :: t -> loop c t
  in
  let cmax = loop 0 l in 
  let somts = Array.make cmax [] in 
  Array.iteri (fun s c -> somts.(c) <- s :: somts.(c)) classes;
  Array.to_list somts

let uncurry f (x, y) = f x y

let g = creer_graphe 6
let () = List.iter (uncurry @@ ajouter_arc g) [
    0, 1;
    1, 4; 1, 5;
    2, 1;
    3, 0; 3, 2;
    4, 2;
    5, 2
  ]

let () = afficher_int_list_list (kosaraju g)

type clause =
  | Top
  | Bottom
  | Var of int
  (*| And of clause * clause*)
  | Or of clause * clause
  | Not of clause

type fnc2 = clause list (* On suppose que si une fnc2 contient n variables, elles sont numérotées de 0 à n-1 *)

let trouver_nombre_variables (f: fnc2) = 
  let rec aux acc = function
    | [] -> acc
    | Top :: t | Bottom :: t -> aux acc t
    | Var v :: t -> aux (max acc v) t
    (*| And (c1, c2) :: t*) | Or (c1, c2) :: t -> aux (aux acc [c1; c2]) t
    | Not c :: t -> aux acc (c :: t)
  in
  aux 0 f + 1

let rec simplifier_not = function
  | Not (Not c) -> simplifier_not c
  | c -> c

exception Clause_invalide of clause  
let n_var_en_nombre n = function
  | Var v -> v
  | Not (Var v) -> v + n
  | c -> raise (Clause_invalide c)

let graphe_d_implication (f: fnc2) =
  let n = trouver_nombre_variables f in
  let g = creer_graphe (n * 2) in
  List.iter (function
    | Or (c1, c2) ->
      ajouter_arc g (n_var_en_nombre n (simplifier_not @@ Not c1)) (n_var_en_nombre n c2);
      ajouter_arc g (n_var_en_nombre n (simplifier_not @@ Not c2)) (n_var_en_nombre n c1)
    | c -> raise (Clause_invalide c)
  ) f;
  g

let afficher_graphe (g: graphe): unit = 
  Array.iteri (fun i voisins -> Printf.printf "%d -> %s\n" i (String.concat "; " (List.map string_of_int voisins))) g

let afficher_graphe_impl (g: graphe) =
  let n = Array.length g / 2 in
  let conv i = if i < n then string_of_int i else Printf.sprintf "N%d" (i - n) in
  for i = 0 to n - 1 do
    Printf.printf "%d -> %s\n" i (String.concat "; " (List.map conv (voisins g i)));
    Printf.printf "N%d -> %s\n" i (String.concat "; " (List.map conv (voisins g (i + n))))
  done

let f = 
  (* [Or (Var 0, Var 0); Or (Not (Var 0), Not (Var 0))] *)
  [
    Or (Var 0, Var 1);
    Or (Var 0, Not (Var 1));
    Or (Not (Var 0), Var 2);
    Or (Not (Var 3), Not (Var 4));
  ]

let g_imp = try
  graphe_d_implication f with Clause_invalide c ->
    Printf.printf "Clause invalide: %s\n" (match c with
    | Var v -> Printf.sprintf "Var %d" v
    | Or _ -> "Or"
    | Not _ -> "Not"
    | Top -> "Top"
    | Bottom -> "Bottom"
  );
  [||]

let () = afficher_graphe_impl g_imp

let est_sat (f: fnc2) =
  let g = graphe_d_implication f in
  let composantes = kosaraju g in
  List.for_all (fun c ->
    List.for_all (fun v -> not (List.mem (v + Array.length g / 2) c)) c
  ) composantes

let print_bool = Fun.compose print_endline string_of_bool

let () = print_bool (est_sat f)