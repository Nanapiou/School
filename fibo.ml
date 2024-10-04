type matrix = int array array 

let mult_mat m1 m2 =
  let n = Array.length m1 in 
  let m = Array.make_matrix n n 0 in 
  for i = 0 to n - 1 do 
    for j = 0 to n - 1 do 
      for k = 0 to n - 1 do
        m.(i).(j) <- m.(i).(j) + m1.(i).(k) * m2.(k).(j)
      done;
    done;
  done;
  m

let rec fast_expo id mult a n =
  let rec aux acc a n =
    if n = 1 then mult acc a 
    else if n = 0 then mult acc id
    else if n mod 2 = 0 then aux acc (mult a a) (n / 2)
    else aux (mult acc a) (mult a a) (n / 2)
  in
  aux id a n

let fibo_mat = [|[|1; 1|]; [|1; 0|]|]
let id = [|[|1; 0|]; [|0; 1|]|]

let fibo n = (fast_expo id mult_mat fibo_mat n).(0).(1)

let fibo_mat_n = fast_expo id mult_mat fibo_mat 20
let print_mat = Array.iter (fun l -> Array.iter (Printf.printf "%d ") l; print_newline ())
let () = print_mat fibo_mat_n
