% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeLinearExpectations( I )
  % Inputs: An influence diagram I with a single decision node and one or more utility nodes.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  % You may assume that there is a unique optimal decision.
  %
  % This is similar to OptimizeMEU except that we will have to account for
  % multiple utility factors.  We will do this by calculating the expected
  % utility factors and combining them, then optimizing with respect to that
  % combined expected utility factor.  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  U =  I.UtilityFactors;
  num_u = length(U);
  num_Pa = length(I.DecisionFactors.var)-1;
  num_d = I.DecisionFactors.card(1);
  %EUF = zeros(prod(I.DecisionFactors.card),length(I.DecisionFactors.card));
  EUF = zeros(1,prod(I.DecisionFactors.card));
  for i = 1:num_u
    I_i = I;
    I_i.UtilityFactors = U(i);
    EUFi = CalculateExpectedUtilityFactor(I_i);
    index = AlignVar(EUFi.var,I.DecisionFactors.var, EUFi.card);
    EUFi.var = I.DecisionFactors.var;
    tmp = EUFi.val;
    for k = 1:length(EUFi.val)
        EUFi.val(k) = tmp(index(k));
    end
    EUF = EUF + EUFi.val;
  end
  OptimalDecisionRule = struct('var', I.DecisionFactors.var, 'card', I.DecisionFactors.card, 'val', zeros(prod(I.DecisionFactors.card),1));
  MEU = 0;
  for i = 1:prod(I.DecisionFactors.card(2:num_Pa+1))
    [MEU_i, decision] = max(EUF(num_d*(i-1)+1:num_d*i));
    MEU = MEU + MEU_i;
    OptimalDecisionRule.val(decision+num_d*(i-1)) = 1;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
