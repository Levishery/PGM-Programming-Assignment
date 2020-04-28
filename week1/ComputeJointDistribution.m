%ComputeJointDistribution Computes the joint distribution defined by a set
% of given factors
%
%   Joint = ComputeJointDistribution(F) computes the joint distribution
%   defined by a set of given factors
%
%   Joint is a factor that encapsulates the joint distribution given by F
%   F is a vector of factors (struct array) containing the factors 
%     defining the distribution
%

function Joint = ComputeJointDistribution(F)

  % Check for empty factor list
  if (numel(F) == 0)
      warning('Error: empty factor list');
      Joint = struct('var', [], 'card', [], 'val', []);      
      return;
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE:
% Compute the joint distribution defined by F
% You may assume that you are given legal CPDs so no input checking is required.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
Joint = struct('var', [], 'card', [], 'val', []); % Returns empty factor. Change this.
for i = 1:length(F)
    Joint.var = union(Joint.var, F(i).var);
end
Joint.card = zeros(1, length(Joint.var));
root = [];
for i = 1:length(F)
    [dummy, mapi] = ismember(F(i).var, Joint.var);
    Joint.card(mapi) = F(i).card;
    if(length(F(i).var)==1)
        root = [root i];
    end
end

inter = F(root(1));
for i = 2:length(root)
     inter = FactorProduct(inter, F(root(i)));
end
inter_root = root;
for i = 1:(length(Joint.var)-length(root))
    for j = 1:(length(Joint.var))
        if (~ismember(j, inter_root)) % havn't been computed
            condition = F(j).var;
            condition = condition(2:-1);
            if(all(ismember(condition, inter.var)))
                inter = FactorProduct(inter, F(j));
                inter_root = [inter_root j];
                break
            end
        end
        if (j==length(Joint.var))
            warning('cant continue computing!');
        end
    end
end
Joint = inter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

