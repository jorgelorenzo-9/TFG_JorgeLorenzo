function [idx, centros,coeficiente_silueta] = clusterizacion(alfa, gamma, delta, num_clusters)
    X = [alfa', gamma', delta'];
  
    [idx, centros] = kmeans(X, num_clusters);
    % Calcular el coeficiente de silueta
    coeficiente_silueta = silhouette(X, idx);
    
end

