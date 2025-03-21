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
let _ = Random.self_init()
let random_volumes (n:int) (v_max:int) :int array =
  let volumes = Array.make n 0 in
  for i = 0 to n-1 do
    volumes.(i) <- (Random.int v_max) +1
  done;
  volumes

(* Représentation des boîtes *)
type box = {remaining_volume : int ; elements : int list}


let empty_box v = {remaining_volume = v; elements = []}


