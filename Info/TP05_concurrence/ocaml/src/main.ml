let file_ajouter_100 (f: int Queue.t) : unit =
  for i = 1 to 10_000 do
    Queue.push i f
  done

let afficher_file (f: int Queue.t) : unit =
  Queue.iter (Printf.printf "%d ") f;
  Printf.printf "\n"

let () = 
  let q = Queue.create () in
  let threads = Array.init 3 (fun _ -> Thread.create file_ajouter_100 q) in 
  Array.iter Thread.join threads;
  afficher_file q