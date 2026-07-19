% Test suite for the macromolecular_stratum pack — the molecular consolidation cascade.
% These tests confirm consolidation raises a trace toward durable WITHOUT altering the memory it holds.
% Load the macromolecular_stratum module under test.
:- use_module(library(macromolecular_stratum)).
% Load PrologAI's schema validator for the structure records.
:- use_module(library(schema_check)).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load list utilities.
:- use_module(library(lists)).

% Open the test block for the macromolecular_stratum pack.
:- begin_tests(macromolecular_stratum).

% One consolidation pass raises the strength but keeps the memory pattern identical.
test(consolidate_raises_strength_keeps_pattern) :-
    % Consolidate a freshly written, labile trace.
    macromolecular_stratum_consolidate(mem([a,b,c], 0.4), mem(P1, S1)),
    % The pattern (the memory's identity) is unchanged — consolidation never rewrites WHICH memory is stored.
    assertion(P1 == [a,b,c]),
    % The strength rose toward durable.
    assertion(S1 > 0.4).

% Consolidation is monotone and saturates at fully durable (1.0), never exceeding it.
test(consolidate_saturates_at_one) :-
    % A trace already near durable.
    macromolecular_stratum_consolidate(mem([x], 0.8), mem(_, S1)),
    % Its strength is capped at 1.0.
    assertion(S1 =< 1.0),
    % A second pass keeps it at the cap.
    macromolecular_stratum_consolidate(mem([x], S1), mem(_, S2)),
    assertion(S2 =< 1.0).

% A trace that has crossed the durable threshold is reported durable; a labile one is not.
test(durability_threshold) :-
    % A fully consolidated trace is durable.
    assertion(macromolecular_stratum_is_durable(mem([a], 1.0))),
    % A freshly written trace is NOT yet durable.
    assertion(\+ macromolecular_stratum_is_durable(mem([a], 0.4))).

% Two consolidation passes from labile reach the durable threshold (the cascade completes).
test(two_passes_reach_durable) :-
    % First pass.
    macromolecular_stratum_consolidate(mem([a,b], 0.4), T1),
    % Second pass.
    macromolecular_stratum_consolidate(T1, T2),
    % The trace is now durable.
    assertion(macromolecular_stratum_is_durable(T2)).

% The six structure records are all schema-valid, including the consolidation CRO.
test(records_valid) :-
    % Fetch the labelled records.
    macromolecular_stratum_records(Records),
    % There are exactly six of them.
    length(Records, 6),
    % Each validates against its kind's schema.
    forall(member(record(_, Kind, Dict), Records),
           co_validate_schema(Dict, Kind, true, [])),
    % The consolidation CRO is present and carries an honest (wide) temporal window.
    memberchk(record(cro_consolidation_cascade, causal_relation_object, Cro), Records),
    get_dict(temporal, Cro, _).

% Close the test block.
:- end_tests(macromolecular_stratum).
