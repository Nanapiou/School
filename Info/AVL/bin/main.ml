type 'a arbre = Vide | Noeud of { eq: int; cle: int; v: 'a; g: 'a arbre; d: 'a arbre }

let rec recherche e = function
  | Vide -> failwith "Not found"
  | Noeud {eq = _; cle; v; g; d} ->
    if e = cle then v
    else if e > cle then recherche e d
    else recherche e g 

let rotation_droite = function
  | Noeud { eq = _; cle = cle1; v = v1; g = Noeud { eq = _; cle = cle2; v = v2; g = u; d = v }; d = w } ->
    Noeud { eq = 0; cle = cle2; v = v2; g = u; d = Noeud { eq = 0; cle = cle1; v = v1; g = v; d = w } }
  | _ -> failwith "Rotation droite impossible"


let rotation_gauche = function
  | Noeud { eq = _; cle = cle1; v = v1; d = Noeud { eq = _; cle = cle2; v = v2; g = v; d = w }; g = u } ->
    Noeud { eq = 0; cle = cle2; v = v2; d = w; g = Noeud { eq = 0; cle = cle1; v = v1; g = u; d = v } }
  | _ -> failwith "Rotation gauche impossible"

let a = Noeud {eq = 0; cle = 5; v = "pan"; g = Noeud {eq = 0; cle = 2; v = "paf"; g = Noeud { eq = 0; cle = 1; v = "Pouf"; g = Vide; d = Vide}; d = Noeud { eq = 0; cle = 3; v = "Bim|"; g = Vide; d = Vide }}; d = Noeud { eq = 0; cle = 7; v = "Chiantos"; g = Vide; d = Vide }}
let () = print_endline (recherche 3 a)
