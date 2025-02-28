type state = {
  grid : int array array;
  mutable i : int;
  mutable j : int;
  mutable h : int
}
type direction = U | D | L | R | No_move
let n = 4

let delta = function
| U -> (-1, 0)
| D -> (1, 0)
| L -> (0, -1)
| R -> (0, 1)
| No_move -> assert false

let print_state (s: state) = 
  let n = Array.length s.grid in
  Printf.printf "---------------------\n";
  for i = 0 to n - 1 do
    Printf.printf "| ";
    for j = 0 to n - 1 do
      print_string(if s.i = i && s.j = j then " X | " else Printf.sprintf "%2d | " s.grid.(i).(j))
    done;
    Printf.printf "\n---------------------\n";
  done;
  Printf.printf "i = %d, j = %d, h = %d\n" s.i s.j s.h


(*
Renvoie la distance de manhattan entre la case (i,j) et la case de valeur value
*)  
let distance (i: int) (j: int) (value: int): int =
  let i_target = value / n in
  let j_target = value mod n in
  abs (i - i_target) + abs (j - j_target)

let possible_moves (s: state): direction list =
  let n = Array.length s.grid in
  let i = s.i in
  let j = s.j in
  let moves = ref [] in
  if i > 0 then moves := U :: !moves;
  if i < n - 1 then moves := D :: !moves;
  if j > 0 then moves := L :: !moves;
  if j < n - 1 then moves := R :: !moves;
  !moves

let h (s: state): int =
  let n = Array.length s.grid in
  let size = n * n - 1 in
  let positions = Array.make size (0, 0) in
  List.iter (fun i ->
    List.iter (fun j ->
      if i <> s.i || j <> s.j then
      positions.(s.grid.(i).(j)) <- (i, j)
    ) (List.init n Fun.id)
  ) (List.init n Fun.id);
  let rec aux v tot =
    if v = size - 1 then tot 
    else begin
      let ci, cj = positions.(v) in
      aux (v + 1) (tot + distance ci cj v)
    end
  in
  aux 0 0

let compute_h (s: state): unit =
  s.h <- h s


(* On utilise le fait que tous les termes de la somme sont identiques à l'exception du terme de valeur grid.(i).(j) *)
let delta_h (s: state) (d: direction): int =
  let i, j = s.i, s.j in
  let i', j' = i + fst (delta d), j + snd (delta d) in
  let value = s.grid.(i).(j) in
  let d1 = distance i j value in
  let d2 = distance i' j' value in
  d2 - d1


let apply (s: state) (d: direction) =
  let i, j = s.i, s.j in
  let i', j' = i + fst (delta d), j + snd (delta d) in
  s.grid.(i).(j) <- s.grid.(i').(j');
  s.i <- i';
  s.j <- j';
  s.h <- s.h + delta_h s d

let copy (s: state): state =
  {s with grid = Array.map Array.copy s.grid}


let sucessors (s: state): state list =
  let moves = possible_moves s in
  List.map (fun d ->
    let s' = copy s in
    apply s' d;
    s'
  ) moves

(*
Renvoie une liste contenant [x, f x, f (f x), f (f (f x)), ...] jusqu'à ce que prédicat soit faux,
*)  
let iterateWhile predicate f x =
  let rec aux acc x =
    if predicate x then
      aux (x :: acc) (f x)
    else
      List.rev (x :: acc)
  in
  aux [] x


let reconstruct (h: ('a, 'a) Hashtbl.t) (s: 'a): 'a list =
  (* iterateWhile (fun s -> Hashtbl.find h s <> s) (Hashtbl.find h) s *)
  (* Mais en marrant *)
  let doubleCompose phi f g x = phi (f x) (g x) in
  iterateWhile (doubleCompose ( <> ) (Hashtbl.find h) Fun.id) (Hashtbl.find h) s

(* Ne marche pas :)  *)  
let astar (start: state) (end_s: state): state list =
  let dists: (state, int) Hashtbl.t = Hashtbl.create 500 in (* idfk abt the size *)
  let preds: (state, state) Hashtbl.t = Hashtbl.create 500 in
  let f: (state, int) Heap.t = Heap.create () in
  Hashtbl.add dists start 0;
  Hashtbl.add preds start start;
  Heap.insert f (start, 0);
  let rec loop () = 
    match Heap.extract_min f with
    | None -> false
    | Some (u, _) ->
      if u = end_s then true
      else
      let du = Hashtbl.find dists u in
      List.iter (fun v -> 
        match Hashtbl.find_opt dists v with
        | None ->
          Hashtbl.add dists v (du + 1);
          Hashtbl.add preds v u;
          Heap.insert f (v, du + 1 + v.h)
        | Some dv ->
          let new_d = du + 1 in
          if new_d < dv then
            Hashtbl.replace dists v new_d;
            Hashtbl.replace preds v u;
            Heap.insert_or_decrease f (v, new_d + v.h)
      ) (sucessors u);
      loop ()
  in
  if loop () then 
    reconstruct preds end_s
  else failwith "Failed to find a way"


(* ------------------------------------------------------------------------------------ *)
(* Tests                                                                                *)
(* ------------------------------------------------------------------------------------ *)

(* La configuration finale *)
let final =
  let m = Array.make_matrix n n 0 in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      m.(i).(j) <- i * n + j
    done
  done;
  {grid = m; i = n - 1; j = n - 1; h = 0}

(* Génère une configuration en appliquant une série de mouvements à la configuration finale *)
(* La configuration s génère vérifie évidemment d(s,final) <= nb_moves *)
let random_state nb_moves =
  let state = copy final in
  for i = 0 to nb_moves - 1 do
    let moves = possible_moves state in
    let n = List.length moves in
    apply state (List.nth moves (Random.int n))
  done;
  state

(* distance 10 *)
let ten =
  let moves = [U; U; L; L; U; R; D; D; L; L] in
  let state = copy final in
  List.iter (apply state) moves;
  state

(* distance 20 *)
let twenty =
  {grid =
    [| [|0; 1; 2; 3|];
      [|12; 4; 5; 6|];
      [|8; 4; 10; 11|];
      [|13; 14; 7; 9|] |];
   i = 1; j = 1; h = 14}

(* distance 30 *)
let thirty =
  {grid =
     [| [|8; 0; 3; 1|];
       [|8; 5; 2; 13|];
       [|6; 4; 11; 7|];
       [|12; 10; 9; 14|] |];
   i = 0; j = 0; h = 22}

(* distance 40 *)
let forty =
  {grid =
     [| [|7; 6; 0; 10|];
       [|1; 12; 11; 3|];
       [|8; 4; 2; 5|];
       [|8; 9; 13; 14|] |];
   i = 2; j = 0; h = 30}

(* distance 50 *)
let fifty =
  let s =
    {grid =
       [| [| 2; 3; 1; 6 |];
          [| 14; 5; 8; 4 |];
          [| 15; 12; 7; 9 |];
          [| 10; 13; 11; 0|] |];
     i = 2;
     j = 0;
     h = 0} in
  compute_h s;
  s

(* distance 64 *)
let sixty_four =
  let s =
    {grid =
       [| [| 15; 14; 11; 7|];
          [| 5; 9; 12; 4|];
          [| 3; 10; 13; 8|];
          [| 2; 6; 0; 1|] |];
     i = 0;
     j = 0;
     h = 0} in
  compute_h s;
  s


let arbre = Hashtbl.create 100 
let () = Hashtbl.add arbre 0 0
let () = Hashtbl.add arbre 1 0
let () = Hashtbl.add arbre 2 1
let () = Hashtbl.add arbre 3 2

(* Affiche une liste sous le forme [0, 1, 2, 3, ...] *)
let print_int_list l =
  Printf.printf "[";
  List.iter (Printf.printf "%d; ") l;
  Printf.printf "]\n"
let () = print_int_list (reconstruct arbre 3)

(* let () = List.iter (fun s -> print_state s; Printf.printf "\n") (sucessors ten) *)

let solution = astar ten final

(* Test de delata_h *)
(* let h = ten.h
let d = delta_h ten U
let () = apply ten U; Printf.printf "h = %d, d = %d\n" ten.h d
let () = assert (h + d = ten.h) *)