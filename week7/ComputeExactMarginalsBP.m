%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code
N = length(F);
vars = [];
for i = 1:N
    vars = union(vars, F(i).var);
end
num_var = length(vars);
M = repmat(struct('var', [], 'card', [], 'val', []), num_var, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE

P = CreateCliqueTree(F, E);
P = CliqueTreeCalibrate(P, isMax);
for i = 1:num_var
    cluster_index = FindCluster(P, i);
    if ~isMax
        M(i) = FactorMarginalization(P.cliqueList(cluster_index), setdiff(P.cliqueList(cluster_index).var, i));
        M(i).val = M(i).val./sum(M(i).val);
    else
        M(i) = FactorMaxMarginalization(P.cliqueList(cluster_index), setdiff(P.cliqueList(cluster_index).var, i));
    end
end


% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

function cluster_index = FindCluster(P, var)
cluster_index = 0;
for i = 1:length(P.cliqueList)
    if(ismember(var, P.cliqueList(i).var))
        cluster_index = i;
        return
    end
end
end