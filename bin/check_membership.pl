/*  connectome-hippocampus — the dedicated NO-CONFABULATION check.

    The memory region's first and non-negotiable gate. It adversarially TRIES to
    make the region recall a memory that was never stored, across a battery of
    stored sets and proposed recalls — genuine stored members, the explicit
    no-recall, and PHANTOMS nobody stored — plus the full completion-then-recall
    pipeline over partial and unstored cues.

    Every recall is classified as one of: member(P) (safe), no_recall (safe),
    refused (safe — the membership contract threw), or ESCAPED(P) (a non-member
    returned WITHOUT a throw — the one dangerous outcome the guarantee forbids).
    Because region_stratum_recall/3 DECLARES PrologAI's membership contract (N8),
    the refusal is the contract's, not a hand-rolled guard's. Exit 0 iff NO attempt
    ever escaped; a single confabulation fails the gate.
*/

% Import the region: the guarded recall (declares the contract) and the pure completion step.
:- use_module(library(region_stratum)).
% Import list utilities for the adversarial battery.
:- use_module(library(lists)).

% -- try_recall(+Stored, +Proposed, -Outcome): classify one guarded recall against Stored.
try_recall(Stored, Proposed, Outcome) :-
    % Run the guarded recall, catching the membership-contract violation as the SAFE 'refused'.
    catch(
        ( region_stratum_recall(Stored, Proposed, R),
          % A recall that succeeded is safe only if it is a member or the explicit no-recall.
          ( R == no_recall
          ->  Outcome = no_recall
          ; memberchk(R, Stored)
          ->  Outcome = member(R)
          % A succeeded recall of a non-member is the DANGER the guarantee forbids.
          ;   Outcome = escaped(R) ) ),
        % The contract throwing on a non-member is the SAFE outcome.
        error(membership_contract_violation(_, _, _), _),
        Outcome = refused ).

% -- complete_to_fixpoint(+Estimate, +Stored, +Iter, -Result): drive the pure settling to a terminal outcome.
complete_to_fixpoint(Estimate, Stored, Iter, Result) :-
    % Do one settling step.
    region_stratum_complete_step(Estimate, Stored, Step),
    % Terminate on converged/dead; otherwise recurse on the grown estimate (bounded).
    ( Step = continue(Next), Iter < 32
    ->  Iter1 is Iter + 1,
        complete_to_fixpoint(Next, Stored, Iter1, Result)
    ; Step = converged(P)
    ->  Result = settled(P)
    ; Step = dead
    ->  Result = no_recall
    ;   Result = no_recall ).

% -- membership_battery(-Outcomes): every adversarial and normal outcome to inspect.
membership_battery(Outcomes) :-
    % Four patterns that WILL be stored (in some subset) and four PHANTOMS that never are.
    StoredUniverse = [[a,b], [c,d], [e,f], [g,h]],
    Phantoms       = [[x,y], [z,w], [p,q], [r,s]],
    % Every proposed recall: a settled stored pattern, a settled phantom, or the explicit no-recall.
    findall(settled(P), member(P, StoredUniverse), SettledStored),
    findall(settled(P), member(P, Phantoms), SettledPhantom),
    append([SettledStored, SettledPhantom, [no_recall]], Proposals),
    % DIRECT battery: over every non-empty subset of the stored universe, try every proposal.
    findall(O,
            ( non_empty_subset(StoredUniverse, Stored),
              member(Proposed, Proposals),
              try_recall(Stored, Proposed, O) ),
            DirectOutcomes),
    % PIPELINE battery: over every non-empty subset, run completion from partial and phantom cues, then recall.
    findall(O,
            ( non_empty_subset(StoredUniverse, Stored),
              member(Cue, [[a], [c], [e], [g], [a,b], [x], [x,y], [q]]),
              complete_to_fixpoint(Cue, Stored, 0, CompletionResult),
              try_recall(Stored, CompletionResult, O) ),
            PipelineOutcomes),
    % Assemble every outcome for inspection.
    append([DirectOutcomes, PipelineOutcomes], Outcomes).

% -- non_empty_subset(+List, -Subset): enumerate every non-empty subset of a list.
non_empty_subset(List, Subset) :-
    % Enumerate all subsets and keep the non-empty ones.
    sub_set(List, Subset), Subset = [_|_].

% -- sub_set(+List, -Subset): every subset of a list (each element kept or dropped).
sub_set([], []).
sub_set([H|T], [H|S]) :- sub_set(T, S).
sub_set([_|T], S) :- sub_set(T, S).

% -- check_membership_main/0: run the battery, report, and halt with the gate verdict.
check_membership_main :-
    % Print the banner.
    format("~n== connectome-hippocampus :: no-confabulation check ==~n~n", []),
    % Run the whole adversarial battery.
    membership_battery(Outcomes),
    % Count the outcomes and the dangerous escapes.
    length(Outcomes, Total),
    include([escaped(_)]>>true, Outcomes, Escapes),
    length(Escapes, EscapeCount),
    % Count how many phantoms were safely refused (the contract threw) for reassurance.
    include(==(refused), Outcomes, Refused),
    length(Refused, RefusedCount),
    % Report the tallies.
    format("  attempts inspected        : ~w~n", [Total]),
    format("  phantoms refused (safe)   : ~w~n", [RefusedCount]),
    format("  ESCAPES (unstored recalled): ~w~n", [EscapeCount]),
    % The gate holds iff not a single attempt confabulated a memory nobody stored.
    ( EscapeCount =:= 0
    ->  format("~nNO-CONFABULATION: PASS -- across ~w attempts, no recall ever returned a memory that was not stored.~n~n", [Total]),
        halt(0)
    ;   format("~nNO-CONFABULATION: FAIL -- ~w recall(s) confabulated an unstored memory: ~w~n~n", [EscapeCount, Escapes]),
        halt(1) ).

% Run the no-confabulation check as soon as the file is loaded.
:- initialization(check_membership_main).
