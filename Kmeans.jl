using Random

function NaiveCluster(cluster)
    first_cluster = Array{Int64, 1}(undef, 0)
    second_cluster = Array{Int64, 1}(undef, 0)
    n = length(cluster[1])
    for i in 1:n
        class = rand(1:2)
        if class == 1
            push!(first_cluster, cluster[1][i])
        else
            push!(second_cluster, cluster[1][i])
        end
    end

    if first_cluster == [] || second_cluster == []
        return NaiveCluster(cluster)
    else
        return [first_cluster, second_cluster]
    end

end

function CentroidInit(dataset, instance::Int64, list_var)
    """
    output: Center, assigned as array{Float64}
    This is an auxiliar function used to initialize a centroid of a cluster. It takes one instance and create an array with the same elements of dataset[instance].
    """
    
    num_var = length(list_var)
    center = []
    for i in 1:num_var
        var = list_var[i]
        push!(center, dataset[instance, var])
    end

    return center

end

function Distance(dataset, instance, list_var, center)

    n = length(list_var)
    dist = 0

    for i in 1:length(list_var)
        a = dataset[instance, list_var[i]]
        b = center[i]
        dist += (a-b)^2
    end

    return dist

end


function UpdateCentroid(dataset, centroid_list, centroid_index, cluster_dict, list_var)
    new_centroid = zeros(length(list_var))
    for i in 1:length(list_var)
        for j in 1:length(cluster_dict[centroid_index])
            index_instance = cluster_dict[centroid_index][j]
            element = dataset[index_instance, i]
            new_centroid[i] += element
        end
    end

    new_centroid = new_centroid/(length(list_var))

    centroid_list[centroid_index] = new_centroid

end


function UpdateCluster(dataset, cluster_dict, list_centroids, list_var, list_inst)
    
    new_dicio = Dict{Int64, Vector{Int64}}()
    for i in 1:length(list_centroids)
        new_dicio[i] = []
    end

    for instance in list_inst
        dist = Distance(dataset, instance, list_var, list_centroids[1])
        ind = 1

        #find the centroid to which the distance to the instance is the least:
        for index in 1:length(list_centroids)
            new_distance = Distance(dataset, instance, list_var, list_centroids[index])
            if new_distance < dist
                ind = index
                dist = new_distance
            end            
        end

        #now, the instance is put in cluster_dict[ind], where ind is the position of the centroid in list_centroid:
        push!(new_dicio[ind], instance)
   end

   cluster_dict = new_dicio

end


function Kmeans(dataset, list_var, list_inst, K=3, iterations=100)
    """
    output: Dictionary where keys are the K classes (range from 1 to K) and values are arrays of indexes of instances.
    """

    cluster_dict = Dict{Int64, Vector{Int64}}()

    num_instances = length(list_inst)
    num_var = length(list_var)


    #if there are only two instances, change the number of clusters:
    if length(list_inst) == 2
        K = 2
    end


    #define the clusters (classes):
    for i in 1:K
        cluster_dict[i] = []
    end


    #define the centroids (firstly, as instances) and put them in a list:
    list_centroids = []         #each index i in this list correspond to the centroid of cluster number i (1::K)
    for j in 1:K
        inst = rand(1:num_instances)
        centroid = CentroidInit(dataset, inst, list_var)
        push!(list_centroids, centroid)
    end


    #first, every instance is put on a class:
    for instance in list_inst
        dist = Distance(dataset, instance, list_var, list_centroids[1])
        ind = 1

        #find the centroid to which the distance to the instance is the least:
        for index in 1:length(list_centroids)
            new_distance = Distance(dataset, instance, list_var, list_centroids[index])
            if new_distance < dist
                ind = index
            end            
        end

        #now, the instance is put in cluster_dict[ind], where ind is the position of the centroid in list_centroid:
        push!(cluster_dict[ind], instance)
   end

   #now, the centroids are updated for the first time (as the mean of the arrays of its cluster):
   for index in 1:length(list_centroids)
        UpdateCentroid(dataset, list_centroids, index, cluster_dict, list_var)
   end


    for batch in 1:iterations
        UpdateCluster(dataset, cluster_dict, list_centroids, list_var, list_inst)
        for index in 1:length(list_centroids)
            UpdateCentroid(dataset, list_centroids, index, cluster_dict, list_var)
       end
    end
    

    #now, we exclude the keys that have empty arrays as values:
    for key in keys(cluster_dict)
        if cluster_dict[key] == []
            delete!(cluster_dict, key)
        end
    end


    #lastly, we create an array where each element is the value of a key in cluster_dict.
    #Basically, the elements of cluster_list are a partition of list_inst.
    cluster_list = []
    for key in keys(cluster_dict)
        push!(cluster_list, cluster_dict[key])
    end


    if length(cluster_list) != 1
        return cluster_list
    else
        return NaiveCluster(cluster_list)
    end
end