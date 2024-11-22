let rec ignore_comment = function
  | '*' :: ')' :: tl -> tl 
  | _ :: (_ :: _ as tl) -> ignore_comment tl
  | _ :: _ | [] -> failwith "Comment not closed"

let list_of_string = Fun.compose List.of_seq String.to_seq