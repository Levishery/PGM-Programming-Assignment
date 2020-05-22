function condition_P = CalculatePaMargin(I)
  condition_P = [];
  EliminatFactors_w = [];
  for i = 1:length(I.RandomFactors)
      if ~(ismember(I.DecisionFactors.var, I.RandomFactors(i).var(1)))
          EliminatFactors_w = [EliminatFactors_w I.RandomFactors(i).var(1)];
      end
  end
  EliminatFactors_w = [EliminatFactors_w I.DecisionFactors.var(1)];
  for i = 1:length(I.RandomFactors)
    condition_P = [condition_P FactorMarginalization(I.RandomFactors(i), EliminatFactors_w)];
  end
  if(length(I.DecisionFactors.var)>1)
    condition_P = ComputeJointDistribution(condition_P);
    condition_P.val = condition_P.val./sum(condition_P.val);
  end
end