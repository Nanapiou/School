type image = int array array


let print_and_flush s =
  print_string s;
  flush stdout  

let ouvrir_images fichier =
    let images = open_in_bin fichier in
    ignore (input_binary_int images);
    let nb = input_binary_int images in
    let hauteur = input_binary_int images in
    let largeur = input_binary_int images in
    (* ignore (really_input_string etiquettes 8); *)
    let data = Array.make nb [||] in
    for i = 0 to nb - 1 do
        data.(i) <- Array.make_matrix hauteur largeur 0;
        for lgn = 0 to hauteur - 1 do
            for col = 0 to largeur - 1 do
                data.(i).(lgn).(col) <- input_byte images
            done
        done
   done;
   data

let ouvrir_etiquettes fichier nb =
  let etiquettes = open_in_bin fichier in
  ignore (really_input_string etiquettes 8);
  let data = Array.make nb (-1) in
  for i = 0 to nb - 1 do
      data.(i) <- input_byte etiquettes;
  done;
  data

let print_image_nombres image =
  for i = 0 to 27 do
    for j = 0 to 27 do
      if image.(i).(j) < 100 then print_int 0 else ();
      if image.(i).(j) < 10 then print_int 0 else ();
      print_int image.(i).(j);
      print_string " "
    done;
    print_newline ()
  done

let print_image_degrade image =
  for i = 0 to 27 do
    for j = 0 to 27 do
      if image.(i).(j) < 52 * 1 then print_string " "
      else if image.(i).(j) < 52 * 2 then print_string "░"
      else if image.(i).(j) < 52 * 3 then print_string "▒"
      else if image.(i).(j) < 52 * 4 then print_string "▓"
      else  print_string "█"
    done;
    print_newline ()
  done

let images = ouvrir_images "train-images-idx3-ubyte"
let etiquettes = ouvrir_etiquettes "train-labels-idx1-ubyte" (Array.length images)

let distance_euclidienne image1 image2 =
  let somme = ref 0. in
  for i = 0 to 27 do
    for j = 0 to 27 do
      somme := !somme +. (float_of_int (image1.(i).(j) - image2.(i).(j))) ** 2.
    done
  done;
  sqrt !somme

let echantillon (m: int) (t: 'a array): 'a array =
  let indices = Array.init m (fun _ -> -1) in
  for i = 0 to m - 1 do
    let j = ref @@ Random.int (Array.length t) in
    while Array.mem !j indices do
      j := Random.int (Array.length t)
    done;
    indices.(i) <- !j
  done;
  Array.map (fun i -> t.(i)) indices

let n_images = Array.length images
(* let () = Printf.printf "Nombre d'images: %d\nDimensions: %d x %d\n" (Array.length images) (Array.length images.(0)) (Array.length images.(0).(0))

let () = print_image_degrade images.(39654) *)

let plus_proche (ims: image array) (im: image): int =
  let plus_proche = ref 0 in
  let distance_min = ref (distance_euclidienne ims.(0) im) in
  for i = 1 to Array.length ims - 1 do
    let distance = distance_euclidienne ims.(i) im in
    if distance < !distance_min then
      begin
        distance_min := distance;
        plus_proche := i
      end
  done;
  !plus_proche

let classes (ims: image array) (barycentres: image array): (int array) =
  Array.map (plus_proche barycentres) ims

let barycentres (nb_classes: int) (ims: image array) (cs : int array): image array =
  let m = Array.length ims.(0) and n = Array.length ims.(0).(0) in
  let barycentres = Array.init nb_classes (fun _ -> Array.make_matrix m n 0) in
  let nb = Array.make nb_classes 0 in
  for i = 0 to Array.length ims - 1 do
    let c = cs.(i) in
    for lgn = 0 to m - 1 do
      for col = 0 to n - 1 do
        barycentres.(c).(lgn).(col) <- barycentres.(c).(lgn).(col) + ims.(i).(lgn).(col)
      done
    done;
    nb.(c) <- nb.(c) + 1
  done;
  for i = 0 to nb_classes - 1 do
    for lgn = 0 to m - 1 do
      for col = 0 to n - 1 do
        barycentres.(i).(lgn).(col) <- barycentres.(i).(lgn).(col) / nb.(i)
      done
    done
  done;
  barycentres

  

let k_moyennes (nb_classes: int) (iter_max: int) (images: image array): int array =
  let barys: image array = echantillon nb_classes images in
  print_and_flush "Barycentres calculés\n";
  let cs = ref (classes images barys) in
  print_and_flush "Classes initiales calculées\n";
  let i = ref 0 in
  while !i < iter_max do
    let barys = barycentres nb_classes images !cs in
    let cs' = classes images barys in
    if cs' = !cs then
      begin
        i := iter_max;
        cs := cs'
      end
    else
      cs := cs';
    incr i
  done;
  print_and_flush "Classes finales calculées, renvoit\n";
  !cs

(* Essayer echantillon *)
(* let () = print_and_flush "Echantillon\n"
let ech = echantillon 10 (Array.init 100 (fun i -> i))
let () = print_and_flush "Echantillon: "
let () = Array.iter (fun d -> print_and_flush (Printf.sprintf "%d " d)) ech *)

let cs = k_moyennes 10 4 images

(* Afficher les 20 premières images de la première classe *)
let () =
  let i = ref 0 in
  let compteur = ref 0 in
  let loop = ref true in
  while !loop && !i < n_images do
    if cs.(!i) = 5 then
      begin
        print_image_degrade images.(!i);
        print_newline ();
        incr compteur;
        if !compteur = 20 then
          loop := false
      end;
    incr i
  done;

(* Afficher les 20 premières images de la deuxième classe *)