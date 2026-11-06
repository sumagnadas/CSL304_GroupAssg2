/*  Problem 3 - Royal Archive Access Verification using Resolution Refutation

    Run:   swipl royal_archive_access.pl
    then:  ?- run.
    (or)   swipl -g run -t halt royal_archive_access.pl

    Notation used for formulas
      all(v(X), F)     for all X, F
      exists(v(X), F)  there exists X such that F
      imp(A, B)        A -> B
      and(A, B), or(A, B), neg(A)
      v(x) is a logic variable, plain atoms like mira / scroll_7 are constants

    Predicates
      archivist(P)       P is an archivist
      verifies(P, R)     P verifies record R
      trusted(P)         P is trusted
      has_access(P, R)   P has access to record R
      sealed(R)          R is a sealed record
      permitted(P, R)    P is permitted to inspect R   (not the same as inspecting)
      inspects(P, R)     P actually inspects R
      finds_mark(P, R)   P finds a hidden mark in R
      stored(R)          R is stored in the royal archive

    Constants: mira, scroll_7         Variables: x, r
*/

:- use_module(library(lists)).


% =====================================================================
% Step 1: Predicate logic representation
% =====================================================================

% 1. Every archivist who verifies a record is trusted.
fol(1, all(v(x), imp(and(archivist(v(x)), exists(v(r), verifies(v(x), v(r)))),
                     trusted(v(x))))).

% 2. Every trusted person who has access to a sealed record is permitted to inspect it.
fol(2, all(v(x), all(v(r), imp(and(trusted(v(x)), and(has_access(v(x), v(r)), sealed(v(r)))),
                               permitted(v(x), v(r)))))).

% 3. Anyone who inspects a record and finds a hidden mark in it verifies that record.
fol(3, all(v(x), all(v(r), imp(and(inspects(v(x), v(r)), finds_mark(v(x), v(r))),
                               verifies(v(x), v(r)))))).

% 4. Every record stored in the royal archive is sealed.
fol(4, all(v(r), imp(stored(v(r)), sealed(v(r))))).

% 5 - 8. Facts
fol(5, stored(scroll_7)).
fol(6, has_access(mira, scroll_7)).
fol(7, and(inspects(mira, scroll_7), finds_mark(mira, scroll_7))).
fol(8, archivist(mira)).

goal(trusted(mira)).


% =====================================================================
% Step 2: Negation of goal
% =====================================================================

negated_goal(9, neg(G)) :- goal(G).

% every formula that goes into the knowledge base for refutation
kb_formula(N, F) :- fol(N, F).
kb_formula(N, F) :- negated_goal(N, F).


% =====================================================================
% Step 3: Implication removal      A -> B   becomes   not A or B
% =====================================================================

remove_imp(imp(A, B), or(NA, B1)) :- !, remove_imp(neg(A), NA), remove_imp(B, B1).
remove_imp(and(A, B), and(A1, B1)) :- !, remove_imp(A, A1), remove_imp(B, B1).
remove_imp(or(A, B), or(A1, B1))   :- !, remove_imp(A, A1), remove_imp(B, B1).
remove_imp(neg(A), neg(A1))        :- !, remove_imp(A, A1).
remove_imp(all(X, A), all(X, A1))  :- !, remove_imp(A, A1).
remove_imp(exists(X, A), exists(X, A1)) :- !, remove_imp(A, A1).
remove_imp(Atom, Atom).

step3(N, F) :- kb_formula(N, F0), remove_imp(F0, F).


% =====================================================================
% Step 4: Moving negation inward (De Morgan and quantifier flipping)
% =====================================================================

move_neg(neg(neg(A)), F)      :- !, move_neg(A, F).
move_neg(neg(and(A, B)), or(F1, F2)) :- !, move_neg(neg(A), F1), move_neg(neg(B), F2).
move_neg(neg(or(A, B)), and(F1, F2)) :- !, move_neg(neg(A), F1), move_neg(neg(B), F2).
move_neg(neg(all(X, A)), exists(X, F)) :- !, move_neg(neg(A), F).
move_neg(neg(exists(X, A)), all(X, F)) :- !, move_neg(neg(A), F).
move_neg(and(A, B), and(F1, F2)) :- !, move_neg(A, F1), move_neg(B, F2).
move_neg(or(A, B), or(F1, F2))   :- !, move_neg(A, F1), move_neg(B, F2).
move_neg(all(X, A), all(X, F))   :- !, move_neg(A, F).
move_neg(exists(X, A), exists(X, F)) :- !, move_neg(A, F).
move_neg(F, F).

step4(N, F) :- step3(N, F0), move_neg(F0, F).


% =====================================================================
% Step 5: Standardization of variables
%         every formula gets its own variable names, x -> x1, r -> r3 ...
% =====================================================================

rename(v(X), N, v(Y)) :- !, atom_concat(X, N, Y).
rename(T, _, T) :- atomic(T), !.
rename(T, N, T1) :-
    T =.. [F | Args],
    maplist([A, A1] >> rename(A, N, A1), Args, Args1),
    T1 =.. [F | Args1].

step5(N, F) :- step4(N, F0), rename(F0, N, F).


% =====================================================================
% Step 6: Skolemization
%         exists X inside the scope of universals U1..Un  ->  sk_N(U1..Un)
%         exists X with no universal outside              ->  constant sk_N
%         after that the universal quantifiers are dropped
% =====================================================================

skolem(all(X, A), Univ, F)   :- !, skolem(A, [X | Univ], F).
skolem(exists(v(X), A), Univ, F) :- !,
    atom_concat(sk_, X, Name),
    reverse(Univ, U),
    ( U == [] -> Sk = Name ; Sk =.. [Name | U] ),
    replace(A, v(X), Sk, A1),
    skolem(A1, Univ, F).
skolem(and(A, B), U, and(F1, F2)) :- !, skolem(A, U, F1), skolem(B, U, F2).
skolem(or(A, B), U, or(F1, F2))   :- !, skolem(A, U, F1), skolem(B, U, F2).
skolem(F, _, F).

replace(T, Old, New, New) :- T == Old, !.
replace(T, _, _, T) :- atomic(T), !.
replace(T, Old, New, T1) :-
    T =.. [F | Args],
    maplist([A, A1] >> replace(A, Old, New, A1), Args, Args1),
    T1 =.. [F | Args1].

step6(N, F) :- step5(N, F0), skolem(F0, [], F).

has_existential(exists(_, _)) :- !.
has_existential(T) :- compound(T), T =.. [_ | Args], member(A, Args), has_existential(A), !.


% =====================================================================
% Step 7: CNF clauses
%         distribute "or" over "and", then split into a list of clauses.
%         A clause is a list of literals, each literal is pos(Atom) or neg(Atom).
% =====================================================================

cnf(and(A, B), and(A1, B1)) :- !, cnf(A, A1), cnf(B, B1).
cnf(or(A, B), F) :- !, cnf(A, A1), cnf(B, B1), distribute(A1, B1, F).
cnf(F, F).

distribute(and(A, B), C, and(F1, F2)) :- !, distribute(A, C, F1), distribute(B, C, F2).
distribute(A, and(B, C), and(F1, F2)) :- !, distribute(A, B, F1), distribute(A, C, F2).
distribute(A, B, or(A, B)).

conjuncts(and(A, B), L) :- !, conjuncts(A, L1), conjuncts(B, L2), append(L1, L2, L).
conjuncts(A, [A]).

literals(or(A, B), L) :- !, literals(A, L1), literals(B, L2), append(L1, L2, L).
literals(neg(A), [neg(A)]) :- !.
literals(A, [pos(A)]).

step7(N, Clauses) :-
    step6(N, F0), cnf(F0, F),
    conjuncts(F, Cs),
    maplist(literals, Cs, Clauses).

% numbered clause list, e.g. c(7a, [pos(inspects(mira, scroll_7))])
clause_list(All) :-
    findall(N-Cs, (kb_formula(N, _), step7(N, Cs)), Groups),
    findall(c(Id, Lits),
            ( member(N-Cs, Groups), length(Cs, K), nth1(I, Cs, Lits),
              clause_id(N, I, K, Id) ),
            All).

clause_id(N, _, 1, Id) :- !, atom_number(Id, N).
clause_id(N, I, _, Id) :- nth1(I, [a, b, c, d], L), atom_concat(N, L, Id).


% =====================================================================
% Step 8: Resolution implementation and execution
% =====================================================================

% Clause variables v(Name) are turned into real Prolog variables so that
% unification does the substitution. The names are kept for printing.
to_prolog(Lits, PLits, Names) :-
    term_vnames(Lits, VNs0), sort(VNs0, VNs),
    findall(Name = _, member(Name, VNs), Names0),
    substitute(Lits, Names0, PLits),
    maplist(upcase_name, Names0, Names).          % X1, R3 ... for printing

upcase_name(N = V, Up = V) :- upcase_atom(N, Up).

term_vnames(v(X), [X]) :- !.
term_vnames(T, []) :- atomic(T), !.
term_vnames(T, L) :- T =.. [_ | Args], maplist(term_vnames, Args, Ls), append(Ls, L).

substitute(v(X), Names, V) :- !, memberchk(X = V, Names).
substitute(T, _, T) :- atomic(T), !.
substitute(T, Names, T1) :-
    T =.. [F | Args], substitute_all(Args, Names, Args1),
    T1 =.. [F | Args1].

substitute_all([], _, []).
substitute_all([A | As], Names, [B | Bs]) :- substitute(A, Names, B), substitute_all(As, Names, Bs).

complement(pos(A), neg(A)).
complement(neg(A), pos(A)).

% one resolution step between the current clause and an input clause.
% Theta is the mgu, written out as text at the moment it is found.
resolve(cl(_, Lits1, Names1), cl(Id2, Lits2, Names2), ThetaText, cl(Id2, Res, Names)) :-
    copy_term(Lits2-Names2, L2-N2),            % fresh copy, keeps clauses standardized apart
    select(Lit1, Lits1, Rest1),
    select(Lit2, L2, Rest2),
    complement(Lit1, C),
    append(Names1, N2, AllNames),
    unbound_names(AllNames, Free),
    unify_with_occurs_check(C, Lit2),
    theta_text(Free, ThetaText),
    append(Rest1, Rest2, Res0),
    remove_dups(Res0, Res),
    term_variables(Res, Vs),
    names_still_used(AllNames, Vs, Names).

unbound_names([], []).
unbound_names([N = V | T], [N = V | R]) :- var(V), !, unbound_names(T, R).
unbound_names([_ | T], R) :- unbound_names(T, R).

names_still_used([], _, []).
names_still_used([N = V | T], Vs, [N = V | R]) :-
    var(V), member(W, Vs), W == V,
    \+ (member(_ = V2, T), V2 == V), !,          % two names for one variable: keep only the last
    names_still_used(T, Vs, R).
names_still_used([_ | T], Vs, R) :- names_still_used(T, Vs, R).

% Free holds every variable that was unbound before unifying.
% A variable now bound to a term gives Name/Term, two variables joined give Name/OtherName.
theta_text(Free, Text) :-
    findall(Bit,
            ( nth1(I, Free, Name = Val),
              (   nonvar(Val)
              ->  with_output_to(atom(VT), write_term(Val, [variable_names(Free)]))
              ;   nth1(J, Free, Other = V2), J < I, V2 == Val, VT = Other
              ),
              format(atom(Bit), "~w/~w", [Name, VT]) ),
            Bits),
    (   Bits == []
    ->  Text = '{}'
    ;   atomic_list_concat(Bits, ', ', Inner),
        format(atom(Text), "{~w}", [Inner])
    ).

remove_dups([], []).
remove_dups([L | Ls], R) :- member(M, Ls), M == L, !, remove_dups(Ls, R).
remove_dups([L | Ls], [L | R]) :- remove_dups(Ls, R).

% linear input resolution starting from the negated goal, iterative deepening
refute(Start, Input, Proof) :-
    between(1, 10, Depth),
    refute(Start, Input, Depth, Proof), !.

refute(cl(_, [], _), _, _, []) :- !.
refute(Current, Input, Depth, [step(Id, ThetaText, NextText) | Rest]) :-
    Depth > 0,
    member(Other, Input),
    resolve(Current, Other, ThetaText, Next),
    Next = cl(Id, _, _),
    with_output_to(atom(NextText), pp_clause(Next)),   % snapshot of the resolvent right now
    D1 is Depth - 1,
    refute(Next, Input, D1, Rest).

% ---------------------------------------------------------------------
% printing
% ---------------------------------------------------------------------

lit_text(pos(A), A).
lit_text(neg(A), '~'(A)).

pp(Term, Names) :- write_term(Term, [variable_names(Names), quoted(false)]).

pp_clause(cl(_, [], _)) :- !, write('[]   <-- empty clause').
pp_clause(cl(_, Lits, Names)) :-
    maplist(lit_text, Lits, Ts),
    pp_or(Ts, Names).

pp_or([T], N) :- !, pp_lit(T, N).
pp_or([T | Ts], N) :- pp_lit(T, N), write(' v '), pp_or(Ts, N).

pp_lit('~'(A), N) :- !, write('~'), pp(A, N).
pp_lit(A, N) :- pp(A, N).

heading(Title) :- nl, write('-----------------------------------------------------------'), nl,
                  write(Title), nl,
                  write('-----------------------------------------------------------'), nl.

show_stage(Title, Pred) :-
    heading(Title),
    forall(kb_formula(N, _), ( call(Pred, N, F), format("  ~w. ", [N]), print_formula(F), nl )).

print_formula(F) :- pretty(F, Text), write(Text).

pretty(all(v(X), A), T)    :- !, pretty(A, TA), format(atom(T), "forall ~w ~w", [X, TA]).
pretty(exists(v(X), A), T) :- !, pretty(A, TA), format(atom(T), "exists ~w ~w", [X, TA]).
pretty(imp(A, B), T) :- !, pretty(A, TA), pretty(B, TB), format(atom(T), "(~w -> ~w)", [TA, TB]).
pretty(and(A, B), T) :- !, pretty(A, TA), pretty(B, TB), format(atom(T), "(~w & ~w)", [TA, TB]).
pretty(or(A, B), T)  :- !, pretty(A, TA), pretty(B, TB), format(atom(T), "(~w v ~w)", [TA, TB]).
pretty(neg(A), T)    :- !, pretty(A, TA), format(atom(T), "~~~w", [TA]).
pretty(A, T) :- strip_v(A, A1), format(atom(T), "~w", [A1]).

strip_v(v(X), X) :- !.
strip_v(T, T) :- atomic(T), !.
strip_v(T, T1) :- T =.. [F | As], maplist(strip_v, As, As1), T1 =.. [F | As1].


% =====================================================================
% main
% =====================================================================

run :-
    show_stage('Step 1 + 2: FOL knowledge base with the negated goal (9)', [N, F] >> kb_formula(N, F)),
    show_stage('Step 3: Implication removal', step3),
    show_stage('Step 4: Negation moved inward', step4),
    show_stage('Step 5: Standardized variables', step5),
    heading('Step 6: Skolemization'),
    ( ( kb_formula(N, _), step5(N, F), has_existential(F) )
      -> forall(kb_formula(M, _), (step6(M, G), format("  ~w. ", [M]), print_formula(G), nl))
      ;  write('  No existential quantifier is left after Step 4 (the "exists r" in rule 1'), nl,
         write('  became "forall r" when the negation moved in), so no Skolem functions are'), nl,
         write('  needed. Universal quantifiers are simply dropped:'), nl,
         forall(kb_formula(M, _), (step6(M, G), format("  ~w. ", [M]), print_formula(G), nl)) ),

    heading('Step 7: CNF clauses'),
    clause_list(Clauses),
    forall(member(c(Id, Lits), Clauses),
           ( to_prolog(Lits, PL, Names), format("  C~w: ", [Id]), pp_clause(cl(Id, PL, Names)), nl )),

    heading('Step 8: Resolution refutation'),
    write('  Linear input resolution: each step resolves the latest resolvent (D1, D2, ...)'), nl,
    write('  with one input clause. Input clauses are renamed apart on every use.'), nl,
    findall(cl(Id, PL, Names), (member(c(Id, Lits), Clauses), Id \== '9', to_prolog(Lits, PL, Names)), Input),
    member(c('9', GL), Clauses), to_prolog(GL, GPL, GN),
    write('  Start from the negated goal  C9: '), pp_clause(cl('9', GPL, GN)), nl,
    (   refute(cl('9', GPL, GN), Input, Proof)
    ->  print_proof(Proof, 'C9', 1),
        nl, write('  Empty clause derived, so KB + ~trusted(mira) is unsatisfiable.'), nl,
        write('  Therefore trusted(mira) follows from the facts and rules.  Q.E.D.'), nl,
        used_clauses(Proof)
    ;   write('  No refutation found.'), nl
    ).

print_proof([], _, _).
print_proof([step(Id, Theta, NextText) | Rest], CurName, K) :-
    format("~n  D~w = resolve(~w, C~w)   mgu = ~w~n", [K, CurName, Id, Theta]),
    format("       ~w~n", [NextText]),
    format(atom(NextName), "D~w", [K]),
    K1 is K + 1,
    print_proof(Rest, NextName, K1).

used_clauses(Proof) :-
    findall(Id, member(step(Id, _, _), Proof), Used),
    format("~n  Clauses used: C9 (negated goal), ~w~n", [Used]),
    write('  Rules 2 and 4 and facts 5 and 6 (access, sealed, permitted) were not needed.'), nl.
