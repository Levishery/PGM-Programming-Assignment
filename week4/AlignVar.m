function index = AlignVar(VarA, VarB, Acard)
%% factorsA(i) = factorsB(index(i))
      [dummy, map] = ismember(VarA, VarB);
      assignments = IndexToAssignment(1:prod(Acard), Acard);
      assignments_tmp = assignments;
      for i = 1:length(map)
          assignments_tmp(:, i) = assignments(:, map(i));
      end
      index = AssignmentToIndex(assignments_tmp, Acard);
      
end