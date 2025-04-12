function [alpha_params] = alphas(ventanas_15mins,num_ventanas)

for i=1:num_ventanas
    Parametros_AlphaStable = fitdist(ventanas_15mins(:,i), 'Stable');
    alpha = Parametros_AlphaStable.alpha;
    beta = Parametros_AlphaStable.beta;
    gamma = Parametros_AlphaStable.gam;
    delta = Parametros_AlphaStable.delta;
    alpha_params(:,i) = [alpha, beta, gamma, delta];
end

end

