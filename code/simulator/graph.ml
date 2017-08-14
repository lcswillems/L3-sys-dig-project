exception Cycle
type mark = NotVisited | InProgress | Visited

exception Has_cycle

type 'a graph =
  { mutable g_nodes : 'a node list }
and 'a node = {
  n_label : 'a;
  mutable n_mark : mark;
  mutable n_link_to : 'a node list;
  mutable n_linked_by : 'a node list;
}

let mk_graph () = { g_nodes = [] }

let add_node g x =
  let n = { n_label = x; n_mark = NotVisited; n_link_to = []; n_linked_by = [] } in
  g.g_nodes <- n::g.g_nodes

let node_for_label g x =
  List.find (fun n -> n.n_label = x) g.g_nodes

let add_edge g id1 id2 =
  let n1 = node_for_label g id1 in
  let n2 = node_for_label g id2 in
  n1.n_link_to <- n2::n1.n_link_to;
  n2.n_linked_by <- n1::n2.n_linked_by

let clear_marks g =
  List.iter (fun n -> n.n_mark <- NotVisited) g.g_nodes

let find_roots g =
  List.filter (fun n -> n.n_linked_by = []) g.g_nodes

let topological g = 
  clear_marks g;
  let l = ref [] in
  let rec parcours nodes = List.iter(fun n ->
    if n.n_mark = InProgress then raise Has_cycle
    else if (n.n_mark = NotVisited) then (
      n.n_mark <- InProgress;
      parcours n.n_link_to;
      l := n.n_label :: !l;
      n.n_mark <- Visited
    )
  ) nodes
  in parcours g.g_nodes;
  !l
