type 'a concurrent_queue = {
  lock : Mutex.t;
  queue : 'a Queue.t
}

let create () = {
  lock = Mutex.create ();
  queue = Queue.create ()
}

let push x q = 
  Mutex.lock q.lock;
  Queue.push x q.queue;
  Mutex.unlock q.lock

let iter f q =
  Mutex.lock q.lock;
  Queue.iter f q.queue;
  Mutex.unlock q.lock

let _take_opt q =
  Mutex.lock q.lock;
  let res = 
    if Queue.is_empty q.queue then None
    else Some (Queue.pop q.queue)
  in
  Mutex.unlock q.lock;
  res

let file_ajouter_100 (f: int concurrent_queue) : unit =
  for i = 1 to 100 do
    push i f;
  done

let afficher_file (f: int concurrent_queue) : unit =
  iter (Printf.printf "%d ") f;
  Printf.printf "\n"

let () = 
  let q = create () in
  let threads = Array.init 3 (fun _ -> Thread.create file_ajouter_100 q) in 
  Array.iter Thread.join threads;
  afficher_file q