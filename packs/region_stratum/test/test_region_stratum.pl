% Test suite for the region_stratum pack — separate, complete, and the membership-contracted recall.
% These tests confirm the region recovers stored memories from partial cues and, above all, CANNOT
% confabulate: recall returns a stored memory or the explicit no_recall, and a non-member is refused.
% Load the region_stratum module under test (its load also DECLARES the membership contract on recall).
:- use_module(library(region_stratum)).
% Load PrologAI's schema validator for the structure records.
:- use_module(library(schema_check)).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load list utilities.
:- use_module(library(lists)).

% Open the test block for the region_stratum pack.
:- begin_tests(region_stratum).

% SEPARATE gives near-duplicate inputs well-separated codes (the dentate role).
test(separation_decorrelates_near_duplicates) :-
    % Two patterns that share two of three features.
    region_stratum_separate([a,b,c], CodeA),
    region_stratum_separate([a,b,d], CodeB),
    % Each code is non-empty (unary plus conjunctive cells).
    assertion(CodeA \== []),
    assertion(CodeB \== []),
    % The codes are NOT identical — the conjunctions differ, so the stored attractors are distinct.
    assertion(CodeA \== CodeB).

% A partial cue overlaps its own stored pattern's code more than a different pattern's.
test(partial_cue_matches_its_own_pattern) :-
    % The stored patterns.
    Stored = [[a,b,c], [d,e,f]],
    % A partial cue of the first pattern.
    region_stratum_separate([a,b], CueCode),
    % The best match is the pattern the cue came from.
    region_stratum_best_match(CueCode, Stored, Best, Overlap),
    assertion(Best == [a,b,c]),
    assertion(Overlap > 0).

% COMPLETE settles a partial cue onto the whole stored pattern (auto-association).
test(completion_reconstructs_from_partial_cue) :-
    % The stored patterns.
    Stored = [[a,b,c,d], [e,f,g,h]],
    % Iterate the settling steps from a partial cue until convergence or no-recall.
    complete_to_fixpoint([a,b], Stored, 0, Outcome),
    % It converged on the full stored pattern the cue was part of.
    assertion(Outcome == converged([a,b,c,d])).

% COMPLETE reports a DEAD cue (no-recall) when the cue matches nothing stored.
test(completion_dead_on_unstored_cue) :-
    % The stored patterns.
    Stored = [[a,b,c], [d,e,f]],
    % A cue built from features nobody stored.
    region_stratum_complete_step([x,y], Stored, Outcome),
    % The step classifies it as dead (an explicit no-recall, not a hang).
    assertion(Outcome == dead).

% RECALL returns a stored member for a settled pattern (the normal, safe recall).
test(recall_returns_a_member) :-
    % The stored-memory set (a plain list — the materialised store).
    Stored = [[a,b,c], [d,e,f]],
    % A completion that settled on a stored pattern.
    region_stratum_recall(Stored, settled([a,b,c]), R),
    % The recalled memory is exactly that stored pattern.
    assertion(R == [a,b,c]).

% RECALL returns the explicit no_recall (the declared abstention) and the contract permits it.
test(recall_abstains_cleanly) :-
    % The stored-memory set.
    Stored = [[a,b,c]],
    % A completion that did not converge.
    region_stratum_recall(Stored, no_recall, R),
    % Recall yields the explicit no_recall.
    assertion(R == no_recall).

% NO CONFABULATION: a settled phantom that was never stored is REFUSED by the membership contract.
test(recall_refuses_confabulation,
     [throws(error(membership_contract_violation(_, [g,h,o,s,t], _), _))]) :-
    % The stored-memory set — it does NOT contain the phantom.
    Stored = [[a,b,c], [d,e,f]],
    % Even if completion (bugged or adversarial) settled on a pattern nobody stored, recall must refuse it.
    region_stratum_recall(Stored, settled([g,h,o,s,t]), _R).

% The twelve structure records are all schema-valid, including the cross-stratal consolidation CRO.
test(records_valid) :-
    % Fetch the labelled records.
    region_stratum_records(Records),
    % There are exactly twelve of them.
    length(Records, 12),
    % Each validates against its kind's schema.
    forall(member(record(_, Kind, Dict), Records),
           co_validate_schema(Dict, Kind, true, [])),
    % The recall conduit is present and computational (carries a transform).
    memberchk(record(conduit_recall, conduit, K), Records),
    get_dict(transform, K, _).

% The cross-stratal consolidation CRO classifies as a clean skip (macromolecular 4 -> region 9, skips:true).
test(consolidation_cro_is_a_clean_skip) :-
    % Classify the cross-stratal CRO and read its skip-gaps.
    region_stratum_skip_check(Class, Gaps),
    % It classifies as skipping.
    assertion(Class == skipping),
    % And carries no skip-gap (skips:true makes the absent mechanism a positive finding).
    assertion(Gaps == []).

% Close the test block.
:- end_tests(region_stratum).

% -- complete_to_fixpoint(+Estimate, +Stored, +Iter, -Outcome): drive the pure settling to a terminal outcome.
% A test-only driver of the same steps the reentrant tick runs, so completion can be checked without threads.
complete_to_fixpoint(Estimate, Stored, Iter, Outcome) :-
    % Do one settling step.
    region_stratum_complete_step(Estimate, Stored, Step),
    % Terminate on a converged or dead step; otherwise recurse on the grown estimate (bounded by pattern size).
    ( Step = continue(Next), Iter < 32
    ->  Iter1 is Iter + 1,
        complete_to_fixpoint(Next, Stored, Iter1, Outcome)
    ;   Outcome = Step ).
