% Copyright (C) Daphne Koller, Stanford University, 2012

function EUF = CalculateExpectedUtilityFactor( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: A factor over the scope of the decision rule D from I that
  % gives the conditional utility given each assignment for D.var
  %
  % Note - We assume I has a single decision node and utility node.
  numD = prod(I.DecisionFactors.card);
  EUF = struct('var', I.DecisionFactors.var, 'card', I.DecisionFactors.card, 'val', zeros(numD,1));
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
  condition_P = [];
  EliminatFactors = [];
  EliminatFactors_w = [];
  for i = 1:length(I.RandomFactors)
      if ~(ismember(I.DecisionFactors.var, I.RandomFactors(i).var(1)))
          EliminatFactors_w = [EliminatFactors_w I.RandomFactors(i).var(1)];
        if ~ismember(I.UtilityFactors.var, I.RandomFactors(i).var(1))
            EliminatFactors = [EliminatFactors I.RandomFactors(i).var(1)];
        end
      end
  end
  EliminatFactors_w = [EliminatFactors_w I.DecisionFactors.var(1)];
  for i = 1:length(I.RandomFactors)
    condition_P = [condition_P FactorMarginalization(I.RandomFactors(i), EliminatFactors_w)];
  end
  Fnew = VariableElimination(I.RandomFactors, EliminatFactors);
  if(length(I.DecisionFactors.var)>1)
    condition_P = ComputeJointDistribution(condition_P);
    condition_P.val = condition_P.val./sum(condition_P.val);
    index_condition = AlignVar(I.DecisionFactors.var(2:length(I.DecisionFactors.card)),condition_P.var, I.DecisionFactors.card(2:length(I.DecisionFactors.card)));
  end
  num = 1;
  P_con = 1;
  for i=1:prod(I.DecisionFactors.card(2:length(I.DecisionFactors.card)))
      E_condition = [];
      Eliminate = [];
      if (length(I.DecisionFactors.var)>1)
        P_con = condition_P.val(index_condition(i));
      end
      assignment = AssignmentToIndex(i, I.DecisionFactors.card(2:length(I.DecisionFactors.card)));
      for k = 1:length(I.DecisionFactors.var)-1
        E_condition = [E_condition; I.DecisionFactors.var(k+1) assignment(k)];
        if ~ismember(I.UtilityFactors.var, I.DecisionFactors.var(k+1))
            Eliminate = [Eliminate I.DecisionFactors.var(k+1)];
        end
      end
      for j = 1:I.DecisionFactors.card(1)
        F_i = ObserveEvidence([Fnew], E_condition, 1);
        D = struct('var', [I.DecisionFactors.var(1)], 'card', [I.DecisionFactors.card(1)], 'val', zeros(1, I.DecisionFactors.card(1)));
        D.val(1,j) = 1;
        if ~ismember(I.UtilityFactors.var, I.DecisionFactors.var(1))
            Eliminate = [Eliminate I.DecisionFactors.var(k+1)];
        end
        F_i = VariableElimination(F_i, Eliminate);
        F_i = ComputeJointDistribution([F_i D]);
        index = AlignVar(F_i.var,I.UtilityFactors.var, F_i.card);
        EU = 0;
        for l = 1:prod(I.UtilityFactors.card)
            EU = EU + F_i.val(l)*I.UtilityFactors.val(index(l))*P_con;
        end
        EUF.val(num) = EU;
        num = num+1;
      end
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  ChildOfD = FindUpper(I);
  condition_P = [];
  EliminatFactors = [];
  EliminatFactors_w = [];
  for i = 1:length(I.RandomFactors)
      if ~(ismember(I.DecisionFactors.var, I.RandomFactors(i).var(1)))
          EliminatFactors_w = [EliminatFactors_w I.RandomFactors(i).var(1)];
        if ~ismember(I.UtilityFactors.var, I.RandomFactors(i).var(1))
            EliminatFactors = [EliminatFactors I.RandomFactors(i).var(1)];
        end
      end
  end
  EliminatFactors_w = [EliminatFactors_w I.DecisionFactors.var(1)];
  %F_condition = FactorMarginalization([I.RandomFactors I.DecisionFactors], EliminatFactors_w);
  %EliminatFactors_w = [EliminatFactors_w I.DecisionFactors.var(1)];
  %for i = 1:length(I.RandomFactors)
    %condition_P = [condition_P FactorMarginalization(I.RandomFactors(i), EliminatFactors_w)];
  %end
  %if(length(condition_P)>1)
   % Fhelp = condition_P(1);
    %for  n = 1:length(condition_P)-1
     % Fhelp = FactorProduct(Fhelp, condition_P(n+1));
    %end
    %F_condition = Fhelp;
  %end
  upfactors = [];
  for i = 1:length(I.RandomFactors)
      if ~ismember(I.RandomFactors(i).var, ChildOfD)
        upfactors = [upfactors I.RandomFactors(i)];
      end
  end
  
  F_condition = ComputeMarginal(I.DecisionFactors.var(2:length(I.DecisionFactors.card)), upfactors, []);
  %F_condition = ComputeMarginal([1], upfactors, []);

  %F_condition = VariableElimination(I.RandomFactors, EliminatFactors_w);
  %if(length(F_condition)>1)
    %Fhelp = F_condition(1);
    %for  n = 1:length(F_condition)-1
        %Fhelp = FactorProduct(Fhelp, F_condition(n+1));
    %end
    %F_condition = Fhelp;
  %end
  %F_condition.val = F_condition.val./sum(F_condition.val);
  index_condition = AlignVar(I.DecisionFactors.var(2:length(I.DecisionFactors.card)),F_condition.var, I.DecisionFactors.card(2:length(I.DecisionFactors.card)));
  %Fnew = VariableElimination(I.RandomFactors, EliminatFactors);
  %if(length(I.DecisionFactors.var)>1)
    %condition_P = ComputeJointDistribution(condition_P);
    %condition_P.val = condition_P.val./sum(condition_P.val);
    %index_condition = AlignVar(I.DecisionFactors.var(2:length(I.DecisionFactors.card)),condition_P.var, I.DecisionFactors.card(2:length(I.DecisionFactors.card)));
  %end
  num = 1;
  P_con = 1;
  %EliminatFactors = [EliminatFactors I.DecisionFactors.var(1)];
  for i=1:prod(I.DecisionFactors.card(2:length(I.DecisionFactors.card)))
      E_condition = [];
      Eliminate = EliminatFactors;
      if (length(I.DecisionFactors.var)>1)
        P_con = F_condition.val(index_condition(i));
      end
      assignment = AssignmentToIndex(i, I.DecisionFactors.card(2:length(I.DecisionFactors.card)));
      for k = 1:length(I.DecisionFactors.var)-1
        E_condition = [E_condition; I.DecisionFactors.var(k+1) assignment(k)];
        if ~ismember(I.UtilityFactors.var, I.DecisionFactors.var(k+1))
            Eliminate = [Eliminate I.DecisionFactors.var(k+1)];
        end
      end
        if ~ismember(I.UtilityFactors.var, I.DecisionFactors.var(1))
            Eliminate = [Eliminate I.DecisionFactors.var(1)];
        end
      for j = 1:I.DecisionFactors.card(1)
        %E = [E_condition; I.DecisionFactors.var(1) j];
        F_i = ObserveEvidence([I.RandomFactors], E_condition, 1);
        D = struct('var', [I.DecisionFactors.var(1)], 'card', [I.DecisionFactors.card(1)], 'val', zeros(1, I.DecisionFactors.card(1)));
        D.val(1,j) = 1;
        F_i = VariableElimination([F_i D] , Eliminate);
        if(length(F_i)>1)
            Fhelp = F_i(1);
            for  n = 1:length(F_i)-1
                Fhelp = FactorProduct(Fhelp, F_i(n+1));
            end
            F_i = Fhelp;
        end
        
        %if any(ismember(I.UtilityFactors.var, I.DecisionFactors.var(1)))
        %    F_i = ComputeJointDistribution([F_i D]);
        %end
        index = AlignVar(F_i.var,I.UtilityFactors.var, F_i.card);
        EU = 0;
        for l = 1:prod(I.UtilityFactors.card)
            EU = EU + F_i.val(l)*I.UtilityFactors.val(index(l))*P_con;
        end
        EUF.val(num) = EU;
        num = num+1;
      end
  end
 
%end  

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
    %}
  EUF = struct('var', [], 'card', [], 'val', []);

  F = [ I.RandomFactors I.UtilityFactors ];
  D = I.DecisionFactors(1);

  Vars = unique([ F(:).var ]);
  Eliminate = setdiff(Vars, D.var);
  factors = VariableElimination(F, Eliminate);

  PD = factors(1);
  for i = 2:length(factors)
    PD = FactorProduct(PD, factors(i));
  end

  EUF = PD;
  
end  

%{
function ChildOfD = FindUpper(I)
D = I.DecisionFactors.var(1);
ChildOfD = [D];
ChildOfD = Findchild(I, ChildOfD);
end
function ChildOfD = Findchild(I, ChildOfD)
    ChildOfD = unique(ChildOfD);
    flag = 0;
    for i = 1:length(I.RandomFactors)
        if any(ismember(ChildOfD,I.RandomFactors(i).var(2:length(I.RandomFactors(i).var))))
            if ~ismember(ChildOfD, I.RandomFactors(i).var(1))
                ChildOfD = [ChildOfD I.RandomFactors(i).var(1)];
                flag = 1;
            end
        end
    end
    if ~(flag == 0)
        ChildOfD = Findchild(I, ChildOfD);
    end    
end
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
