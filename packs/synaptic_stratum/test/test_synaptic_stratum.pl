% Test suite for the synaptic_stratum pack — the plasticity write (encode).
% These tests confirm encoding writes a trace whose pattern is exactly the input, labile by default.
% Load the synaptic_stratum module under test.
:- use_module(library(synaptic_stratum)).
% Load the macromolecular cascade to confirm a written trace can be consolidated to durable.
:- use_module(library(macromolecular_stratum)).
% Load PrologAI's schema validator for the structure records.
:- use_module(library(schema_check)).
% Load the PLUnit testing framework.
:- use_module(library(plunit)).
% Load list utilities.
:- use_module(library(lists)).

% Open the test block for the synaptic_stratum pack.
:- begin_tests(synaptic_stratum).

% Encoding writes a trace whose pattern is EXACTLY the input (no invention) and is labile.
test(encode_writes_the_exact_pattern) :-
    % Encode an input pattern.
    synaptic_stratum_encode([a,b,c], mem(P, S)),
    % The stored pattern is exactly the input — encoding never conjures a different memory.
    assertion(P == [a,b,c]),
    % The freshly written trace is labile (not yet durable).
    assertion(\+ macromolecular_stratum_is_durable(mem(P, S))).

% A written trace can be consolidated by the macromolecular cascade to durable.
test(encoded_trace_consolidates_to_durable) :-
    % Encode a pattern to a labile trace.
    synaptic_stratum_encode([x,y], T0),
    % One consolidation pass takes it to durable.
    macromolecular_stratum_consolidate(T0, T1),
    % The trace is now durable.
    assertion(macromolecular_stratum_is_durable(T1)).

% Long-term potentiation raises a synaptic strength monotonically, capped at 1.0.
test(potentiation_is_monotone_capped) :-
    % One potentiation step raises the strength.
    synaptic_stratum_potentiate(0.4, S1),
    assertion(S1 > 0.4),
    % A high strength is capped at 1.0.
    synaptic_stratum_potentiate(0.95, S2),
    assertion(S2 =< 1.0).

% The four structure records are all schema-valid.
test(records_valid) :-
    % Fetch the labelled records.
    synaptic_stratum_records(Records),
    % There are exactly four of them.
    length(Records, 4),
    % Each validates against its kind's schema.
    forall(member(record(_, Kind, Dict), Records),
           co_validate_schema(Dict, Kind, true, [])).

% Close the test block.
:- end_tests(synaptic_stratum).
