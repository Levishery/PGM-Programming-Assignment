% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU, OptimalDecisionRule] = OptimizeMEU( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  
  % We assume I has a single decision node.
  % You may assume that there is a unique optimal decision.
  D = I.DecisionFactors(1);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  EUF = CalculateExpectedUtilityFactor(I);
  index = AlignVar(EUF.var,I.DecisionFactors.var, EUF.card);
  EUF.var = I.DecisionFactors.var;
  tmp = EUF.val;
  for i = 1:length(EUF.val)
      EUF.val(i) = tmp(index(i));
  end
  %condition_P = CalculatePaMargin(I);
  num_Pa = length(I.DecisionFactors.var)-1;
  num_d = I.DecisionFactors.card(1);
  %index = AlignVar(I.DecisionFactors.var(2:num_pa+1),condition_P.var, I.DecisionFactors.card(2:num_pa+1));
  OptimalDecisionRule = struct('var', I.DecisionFactors.var, 'card', I.DecisionFactors.card, 'val', zeros(prod(I.DecisionFactors.card),1));
  MEU = 0;
  for i = 1:prod(I.DecisionFactors.card(2:num_Pa+1))
    [MEU_i, decision] = max(EUF.val(num_d*(i-1)+1:num_d*i));
    MEU = MEU + MEU_i;
    OptimalDecisionRule.val(decision+num_d*(i-1)) = 1;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  

end
