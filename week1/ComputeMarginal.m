%ComputeMarginal Computes the marginal over a set of given variables
%   M = ComputeMarginal(V, F, E) computes the marginal over variables V
%   in the distribution induced by the set of factors F, given evidence E
%
%   M is a factor containing the marginal over variables V
%   V is a vector containing the variables in the marginal e.g. [1 2 3] for
%     X_1, X_2 and X_3.
%   F is a vector of factors (struct array) containing the factors 
%     defining the distribution
%   E is an N-by-2 matrix, each row being a variable/value pair. 
%     Variables are in the first column and values are in the second column.
%     If there is no evidence, pass in the empty matrix [] for E.


function M = ComputeMarginal(V, F, E)

% Check for empty factor list
if (numel(F) == 0)
      warning('Warning: empty factor list');
      M = struct('var', [], 'card', [], 'val', []);      
      return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE:
% M should be a factor
% Remember to renormalize the entries of M!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = struct('var', [], 'card', [], 'val', []); % Returns empty factor. Change this.
M = ComputeJointDistribution(F);
M = ObserveEvidence(M, E);
M.val(:) = M.val(:)/sum(M.val(:));
%{
F = ObserveEvidence(F, E);
for i = 1:length(F) % normalization
    conditions = prod(F(i).card(2:-1));
    targets = F(i).card(1);
    for j = 1:conditions
        if(~(sum(F(i).val((j-1)*targets+1:j*targets))==0))
            F(i).val((j-1)*targets+1:j*targets) = F(i).val((j-1)*targets+1:j*targets)/sum(F(i).val((j-1)*targets+1:j*targets));
            F(i).val((j-1)*targets+1:j*targets)
        else
            print('error');
        end
    end
end
M = ComputeJointDistribution(F);
%}
num_reduce = 0;
for i = 1:length(M.var)
    if (~ismember(M.var(i-num_reduce),V))
        M = FactorMarginalization(M, M.var(i-num_reduce));
        num_reduce = num_reduce+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
