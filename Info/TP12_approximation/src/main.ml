(* Test pour la question 0 *)
let v_max_0 = 10
let volumes_0 = [|2;5;4;7;1;3;8|]

(* Test plus conséquent. L'algorithme branch and bound devrait trouver une solution à 6 boîtes de manière quasiment instantanée *)
let v_max_bnb = 101
let volumes_bnb = [|27; 11; 41; 43; 42; 54; 34; 11; 2; 1; 17; 56; 42; 24; 31; 17; 18; 19; 24; 35; 13; 17; 25|]

(* Test encore plus conséquent sur lequel l'algorithme branch and bound est impuissant. La meilleure solution connue sur cette instance utilise 51 boîtes. On pourra tester les algorithmes d'approxiamtion sur cette entrée *)
let v_max_big  = 150
let volumes_big = [|100; 22; 25; 51; 95; 58; 97; 30; 79; 23; 53; 80; 20; 65; 64; 21; 26; 100; 81; 98;
                    70; 85; 92; 97; 86; 71; 91; 29; 63; 34; 67; 23; 33; 89; 94; 47; 100; 37; 40; 58; 73; 39;
                    49; 79; 54; 57; 98; 69; 67; 49; 38; 34; 96; 27; 92; 82; 69; 45; 69; 20; 75; 97; 51; 70; 29;
                    91; 98; 77; 48; 45; 43; 61; 36; 82; 89; 94; 26; 35; 58; 58; 57; 46; 44; 91; 49; 52; 65; 42;
                    33; 60; 37; 57; 91; 52; 95; 84; 72; 75; 89; 81; 67; 74; 87; 60; 32; 76; 85; 59; 62; 39; 64;
                    52; 88; 45; 29; 88; 85; 54; 40; 57|]

(* Fonction de génération de n volumes d'objets aléatoires. Utiliser un v_max inférieur à 1000 *)
let _ = Random.self_init ()

let random_volumes (n : int) (v_max : int) : int array =
  let volumes = Array.make n 0 in
  for i = 0 to n - 1 do
    volumes.(i) <- Random.int v_max + 1
  done;
  volumes

(* Représentation des boîtes *)
type box = { remaining_volume : int; elements : int list }
type instance = box list

(* In order to print some things... *)
let print_int_list = function
  | [] -> print_string "[]"
  | h :: t -> Printf.printf "[%d" h; List.iter (Printf.printf ", %d") t; print_char ']'
let print_box b = Printf.printf "{ v = %d, elts = " b.remaining_volume; print_int_list b.elements; print_string " }" 
let print_box_array = function
  | [||] -> print_string "[||]"
  | a -> print_string "[|"; print_box a.(0);
    for i = 1 to Array.length a - 1 do
      print_string ", "; print_box a.(i)
    done;
    print_string "|]"

(* Utility functions on boxes *)
let does_fit box v = box.remaining_volume >= v
let add i v box =
  assert (does_fit box v);
  { remaining_volume = box.remaining_volume - v; elements = i :: box.elements }
let new_box max_v = { remaining_volume = max_v; elements = [] }

let next_fit max_v (volumes : int array) =
  let n = Array.length volumes in
  let rec aux acc i =
    if i = n - 1 then acc
    else
      let v = volumes.(i) in
      let acc' =
        match acc with
        | h :: t when does_fit h v -> add i v h :: t
        | ([] as l) | l -> add i v (new_box max_v) :: l
      in
      aux acc' (i + 1)
  in
  List.length (aux [] 0)

let first_fit max_v (volumes : int array) =
  let n = Array.length volumes in
  let rec aux boxes i =
    if i = n - 1 then boxes
    else
      let v = volumes.(i) in
      let rec insert_box = function
        | [] -> [ add i v (new_box max_v) ]
        | box :: t when does_fit box v -> add i v box :: t
        | box :: t -> box :: insert_box t
      in
      aux (insert_box boxes) (i + 1)
  in
  List.length (aux [] 0)

let ffd v vs =
  let vs = Array.copy vs in
  Array.sort (fun a b -> b - a) vs;
  first_fit v vs

let bb_bnb v_max (volumes: int array): int =
  let n = Array.length volumes in
  let up_bound = ffd v_max volumes in
  let rec depth_search bound (boxes: box list) (depth as i: int) =
    let v = volumes.(i) in
    let l = List.length boxes in (* Pretty sad, but need it *)
    if i = n - 1 || l >= bound then min up_bound l else begin
      let rec insert_box_everywhere = function
        | [] -> []
        | box :: t when does_fit box v -> (add i v box :: t) :: (List.map (List.cons box) (insert_box_everywhere t))
        | box :: t -> (List.map (List.cons box) (insert_box_everywhere t))
      in
      let bound = List.fold_left (fun acc boxes' -> min acc (depth_search acc boxes' (i + 1))) bound (insert_box_everywhere boxes) in
      min bound (depth_search bound ((add i v (new_box v_max)) :: boxes) (i + 1))
    end
  in
  depth_search up_bound [] 0
    
   
let () =
  Printf.printf "%d\n%d\n%d\n%d\n"
    (next_fit v_max_big volumes_big)
    (first_fit v_max_big volumes_big)
    (ffd v_max_bnb volumes_bnb)
    (bb_bnb v_max_bnb volumes_bnb)   
    (* (bb_bnb v_max_big volumes_big) (* Too long *) *) 

