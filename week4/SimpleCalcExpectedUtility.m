% Copyright (C) Daphne Koller, Stanford University, 2012

function EU = SimpleCalcExpectedUtility(I)

  % Inputs: An influence diagram, I (as described in the writeup).
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return Value: the expected utility of I
  % Given a fully instantiated influence diagram with a single utility node and decision node,
  % calculate and return the expected utility.  Note - assumes that the decision rule for the 
  % decision node is fully assigned.

  % In this function, we assume there is only one utility node.
  F = [I.RandomFactors I.DecisionFactors];
  U = I.UtilityFactors(1);
  EU = [];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  EliminatFactors = [];
  for i = 1:length(I.RandomFactors)
      if ~(ismember(I.UtilityFactors.var, I.RandomFactors(i).var(1)))
        EliminatFactors = [EliminatFactors I.RandomFactors(i).var(1)];
      end
  end
  if ~(ismember(I.UtilityFactors.var, I.DecisionFactors.var(1)))
      EliminatFactors = [EliminatFactors I.DecisionFactors.var(1)];
  end
  Fnew = VariableElimination(F, EliminatFactors);
  %if ~(length(Fnew)==length(U.var))
  %   error('length(Fnew)!=length(U.var)');
  %end
  EU = 0;
  
  if length(Fnew)>1
    Fnew = ComputeJointDistribution(Fnew);
  end
  
  index = AlignVar(Fnew.var,U.var, Fnew.card);
  for i = 1:prod(U.card)
      EU = EU + Fnew.val(i)*U.val(index(i));
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
end
