% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU, OptimalDecisionRule] = OptimizeWithJointUtility( I )
  % Inputs: An influence diagram I with a single decision node and one or more utility nodes.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  % You may assume that there is a unique optimal decision.
    
  % This is similar to OptimizeMEU except that we must find a way to 
  % combine the multiple utility factors.  Note: This can be done with very
  % little code.
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    combin_I = I;
    combin_I.UtilityFactors = JointUtility(I);
    [MEU, OptimalDecisionRule] = OptimizeMEU( combin_I );
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
end

function joint_utility = JointUtility( I )
U =  I.UtilityFactors;
num_u = length(U);
joint_utility.var = [];
for i = 1:num_u
    joint_utility.var = union(joint_utility.var, U(i).var);
end
joint_utility.var  = joint_utility.var';
joint_utility.card = zeros(1, length(joint_utility.var));

[dummy, mapi] = ismember(U(1).var, joint_utility.var);
map = cell(1,num_u);
map{1} = mapi;
joint_utility.card(mapi) = U(1).card;
for i = 2:num_u
    [dummy, mapi] = ismember(U(i).var, joint_utility.var);
    map{i} = mapi;
    joint_utility.card(mapi) = U(i).card;
end

joint_utility.val = zeros(1,prod(joint_utility.card));

assignments = IndexToAssignment(1:prod(joint_utility.card), joint_utility.card);
for i = 1:prod(joint_utility.card)
    joint_utility.val(i) = 0;
    for j = 1:num_u
    indxi = AssignmentToIndex(assignments(i, map{j}), U(j).card);
    joint_utility.val(i) = joint_utility.val(i) + U(j).val(indxi);
    end
end

end