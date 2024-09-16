(* Oui, c'est du faux fonctionnel, grosse flemme *)

let echanger a i j =
  let temp = a.(i) in 
  a.(i) <- a.(j);
  a.(j) <- temp

type 'a file = 'a array
let file_vide: 'a file = [||]
let file_est_vide f = Array.length f == 0
let file_tete f = f.(0)
let file_taille = Array.length
let file_iter = Array.iter
let file_enfiler (compare: 'a -> 'a -> int) (f: 'a file) (e: 'a): 'a file =
  let f = Array.append f [|e|] in 
  let i = ref @@ Array.length f - 1 in
  while !i > 0 && compare (f.(!i)) (f.((!i - 1) / 2)) > 0 do
    echanger f !i ((!i - 1) / 2);
    i := (!i - 1) / 2
  done;
  f
let file_defiler (compare: 'a -> 'a -> int) (f: 'a file): 'a file * 'a =
  let len = Array.length f in
  if len = 0 then failwith "File vide" else
  let elt = f.(0) in 
  f.(0) <- f.(len - 1);
  let f = Array.sub f 0 (len - 1) in
  let len = len - 1 in
  let i = ref 0 in 
  while !i < len do
    let left = 2 * !i + 1 in 
    let right = 2 * !i + 2 in
    if right < len then
      let ma = if compare f.(left) f.(right) < 0 then right else left in 
      if compare f.(!i) f.(ma) < 0 then begin
        echanger f !i ma;
        i := ma
      end else i := len
    else if left < len && compare f.(!i) f.(left) < 0 then begin 
      echanger f !i left;
      i := left
    end else i := len
  done;
  (f, elt)

let heap_sort comp l =
  let f = List.fold_left (file_enfiler comp) file_vide l in 
  let rec aux f l =
    if file_est_vide f then l 
    else
      let f, e = file_defiler comp f in 
      aux f (e :: l)
  in
  aux f []