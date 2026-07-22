/*  connectome-hippocampus — macromolecular_stratum (ordinal 4 -> pack layer 1): CONSOLIDATION.

    THE MOLECULAR CONSOLIDATION CASCADE, at the macromolecular stratum
    (Causalontology ordinal 4). Under the Wave 3 verdict's rule (one pack per
    stratum on the OUTSIDE, one construct per module on the INSIDE) this pack IS
    the macromolecular stratum. Its ONE runtime construct is CONSOLIDATION: the
    calcium-driven molecular cascade that turns a LABILE trace (freshly written by
    synaptic potentiation) into a DURABLE one. That is DYNAMICS, kept native (a
    rate law, never a causal_relation_object, per the grounding rule) — a single
    sub-module, macromolecular_stratum_consolidate/2.

    Its STRUCTURE is grounded in Causalontology 3.0.0: the macromolecular stratum
    record, the calcium/calmodulin-kinase cascade continuant that bears the
    consolidation, the labile- and durable-trace state-change occurrents, the
    consolidation disposition, and the consolidation causal_relation_object
    (labile -> durable, both at the macromolecular stratum — no cross-stratal span
    here; the region owns the cross-stratal consolidation relation).

    THE PACK IS PURE — it has no runtime tick and never coordinates on the Lattice.
    Consolidation is a downward mechanism the region invokes during encoding; the
    only reentrant actor in the region is the CA3 completion loop. It imports the
    minting vocabulary (0) and nothing upward; its layer(1) is the lowest stratum
    layer, matching ordinal 4 as the finest stratum the region touches (the N6
    binding check confirms it).
*/

% Declare the module: the native consolidation, the durable-trace occurrent (referenced by the region), and the structure accessors.
:- module(macromolecular_stratum, [
    % macromolecular_stratum_consolidate/2: the native cascade — raise a trace's strength toward durable.
    macromolecular_stratum_consolidate/2,
    % macromolecular_stratum_is_durable/1: true when a trace has reached the durable threshold.
    macromolecular_stratum_is_durable/1,
    % macromolecular_stratum_durable_occurrent/1: the durable-trace occurrent (the region's cross-stratal CRO effect endpoint).
    macromolecular_stratum_durable_occurrent/1,
    % macromolecular_stratum_stratum/1: the macromolecular stratum record (its ordinal is read by the region's cross-stratal skip check).
    macromolecular_stratum_stratum/1,
    % macromolecular_stratum_records/1: the labelled list of this stratum's six structure records.
    macromolecular_stratum_records/1
]).

% Import the shared minting vocabulary (Layer 0).
:- use_module(library(causal_grounding)).

% ---------------------------------------------------------------------------
% The native dynamics (kept native per the grounding rule — no CRO for a rate law).
% ---------------------------------------------------------------------------

% The consolidation increment per cascade pass (the calcium-driven step toward durability).
macromolecular_stratum_consolidation_step(0.5).
% The strength at or above which a trace is considered durable (long-term memory).
macromolecular_stratum_durable_threshold(0.9).

% -- macromolecular_stratum_consolidate(+Trace0, -Trace1): one consolidation pass on a trace.
% A trace is mem(Pattern, Strength); consolidation raises the strength toward 1.0 (durable),
% leaving the Pattern (the memory's identity) untouched — so consolidation NEVER alters WHICH
% memory is stored, only how durable it is (the membership set of patterns is preserved).
macromolecular_stratum_consolidate(mem(Pattern, Strength0), mem(Pattern, Strength1)) :-
    % Read the calcium-driven consolidation increment.
    macromolecular_stratum_consolidation_step(Step),
    % Raise the strength by one step, capped at fully durable (1.0).
    Raised is Strength0 + Step,
    % Clamp to the [0.0, 1.0] durability range.
    ( Raised > 1.0 -> Strength1 = 1.0 ; Strength1 = Raised ).

% -- macromolecular_stratum_is_durable(+Trace): true when the trace has reached the durable threshold.
macromolecular_stratum_is_durable(mem(_Pattern, Strength)) :-
    % Read the durability threshold.
    macromolecular_stratum_durable_threshold(Threshold),
    % The trace is durable once its strength is at or above the threshold.
    Strength >= Threshold.

% ---------------------------------------------------------------------------
% The structure records (co-located with the pack, the verdict's stratum-primary stance).
% ---------------------------------------------------------------------------

% -- macromolecular_stratum_stratum(-Out): the macromolecular stratum record (ordinal 4).
macromolecular_stratum_stratum(Out) :-
    % Mint the macromolecular stratum with the anatomy's fields (the shared neuroendocrine ladder).
    cm_stratum("macromolecular", "neuroendocrine", 4, "macromolecule", ["molecular_neuroscience"], Out).

% -- macromolecular_stratum_cascade_continuant(-Out): the calcium/calmodulin-kinase cascade bearer.
macromolecular_stratum_cascade_continuant(Out) :-
    % Mint the calcium-calmodulin-dependent kinase continuant (the molecular basis of long-term memory).
    cm_cnt("calcium_calmodulin_dependent_kinase", "object", Out).

% -- macromolecular_stratum_labile_occurrent(-Out): the labile-trace state, stamped at the macromolecular stratum.
macromolecular_stratum_labile_occurrent(Out) :-
    % Read this pack's own stratum id.
    macromolecular_stratum_stratum(SMacro),
    % Mint the labile-trace occurrent (the freshly written, not-yet-durable trace).
    cm_occ("labile_trace", "state_change", SMacro.id, Out).

% -- macromolecular_stratum_durable_occurrent(-Out): the durable-trace state, stamped at the macromolecular stratum.
macromolecular_stratum_durable_occurrent(Out) :-
    % Read this pack's own stratum id.
    macromolecular_stratum_stratum(SMacro),
    % Mint the durable-trace occurrent (the consolidated, long-term trace).
    cm_occ("durable_trace", "state_change", SMacro.id, Out).

% -- macromolecular_stratum_consolidation_realizable(-Out): the consolidation disposition of the cascade.
macromolecular_stratum_consolidation_realizable(Out) :-
    % Read the cascade bearer id.
    macromolecular_stratum_cascade_continuant(CCascade),
    % Mint the consolidation disposition it bears.
    cm_rlz(CCascade.id, "disposition", "trace_consolidation", Out).

% -- macromolecular_stratum_consolidation_cro(-Out): the consolidation CRO (labile -> durable, macromolecular-internal).
macromolecular_stratum_consolidation_cro(Out) :-
    % The cause is the labile-trace occurrent.
    macromolecular_stratum_labile_occurrent(OLabile),
    % The effect is the durable-trace occurrent (both at the macromolecular stratum — no cross-stratal span).
    macromolecular_stratum_durable_occurrent(ODurable),
    % Mint the consolidation CRO; its temporal window is honestly WIDE — consolidation is slow (this is a
    % standing note toward the HIPPO Ledger's consolidation-over-time finding: the window is data, not a schedule).
    cm_cro([OLabile.id], [ODurable.id],
           [modality-"sufficient", temporal-_{minimum_delay:1, maximum_delay:3600, unit:"seconds"}],
           Out).

% -- macromolecular_stratum_records(-Records): this stratum's six structure records.
macromolecular_stratum_records(Records) :-
    % Mint the stratum, the cascade bearer, and the two trace-state occurrents.
    macromolecular_stratum_stratum(SMacro),
    macromolecular_stratum_cascade_continuant(CCascade),
    macromolecular_stratum_labile_occurrent(OLabile),
    macromolecular_stratum_durable_occurrent(ODurable),
    % Mint the consolidation disposition and the consolidation CRO.
    macromolecular_stratum_consolidation_realizable(RCons),
    macromolecular_stratum_consolidation_cro(CroCons),
    % Assemble the labelled record list.
    Records = [
        record(stratum_macromolecular,       stratum,                SMacro),
        record(continuant_consolidation_cascade, continuant,         CCascade),
        record(occurrent_labile_trace,       occurrent,              OLabile),
        record(occurrent_durable_trace,      occurrent,              ODurable),
        record(realizable_consolidation,     realizable,             RCons),
        record(cro_consolidation_cascade,    causal_relation_object, CroCons)
    ].
