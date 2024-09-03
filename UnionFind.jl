mutable struct UnionFindNode
    index::Int64                        #index in the dataset of the node.
    rank::Int64                         #length of the subtree, starting on the node. Initially it is set to 0.
    children::Vector{UnionFindNode}        #list of UnionFindNode elements that are children of the node.
    parent::UnionFindNode                  #parent of the node. Initially set to nothing. If the node gets a parent, it changes to the UnionFindNode parent.

    UnionFindNode(index) = (node=new(); node.index = index ; node.rank=0; node.children=[]; node.parent=node)

end


function Find(node::UnionFindNode)
    """
    return the root of the node.
    Also, when called, this function sets the root of the node as its parent, so the tree gets smaller. This process is called path compression.
    """

    if node.parent == node       #node does not have a parent
        return node
    else
        node.parent = Find(node.parent)
    end
end


function Union(node1::UnionFindNode, node2::UnionFindNode)
    root1, root2 = Find(node1), Find(node2)
    if root1 == root2
        return
    else
        if root1.rank == root2.rank
            root2.parent = root1
            push!(root1.children, root2)
            root1.rank += 1
        elseif root1.rank > root2.rank
            root2.parent = root1
            push!(root1.children, root2)
        else
            root1.parent = root2
            push!(root2.children, root1)
        end
    end

end


function CountComponents(nodes_list::Vector{Any})
    nodes_dict = Dict{Int64, Vector{Int64}}()
    n = length(nodes_list)
    for i in 1:n
        root = Find(nodes_list[i])
        node_index = nodes_list[i].index
        root_index = root.index
        if root_index in keys(nodes_dict)
            push!( nodes_dict[root_index], node_index )
        else
            nodes_dict[root_index] = [node_index]
        end
    end

    list_independent_index = []
    for key in keys(nodes_dict)
        push!(list_independent_index, nodes_dict[key])
    end


    return list_independent_index
end