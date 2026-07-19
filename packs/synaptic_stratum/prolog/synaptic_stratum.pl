/*  connectome-hippocampus — synaptic_stratum (ordinal 7 -> pack layer 2): ENCODE.

    THE PLASTICITY THAT WRITES A MEMORY, at the synaptic stratum (Causalontology
    ordinal 7). Under the Wave 3 verdict's rule (one pack per stratum on the
    OUTSIDE, one construct per module on the INSIDE) this pack IS the synaptic
    stratum. Its ONE construct is ENCODE: long-term potentiation at the
    mossy-fiber / Schaffer-collateral synapses WRITES an input pattern as a memory
    trace and sets its initial (labile) strength. That is DYNAMICS, kept native (a
    potentiation rate law, never a causal_relation_object, per the grounding rule)
    — a single sub-module, synaptic_stratum_encode/2, plus the raw potentiation
    step it is built from.

    A trace is mem(Pattern, Strength). Encoding sets Strength to the initial
    potentiated value (labile); the macromolecular cascade (a lower stratum, read
    downward by the region) later consolidates it toward durable. The PATTERN is
    the memory's identity and is written UNCHANGED — encoding never invents a
    pattern, so the set of stored patterns is exactly the set of encoded inputs.

    Its STRUCTURE is grounded in Causalontology 2.0.0: the synaptic stratum record,
    the mossy-fiber synapse continuant that bears the plasticity, the long-term-
    potentiation state-change occurrent, and the plasticity disposition.

    THE PACK IS PURE — no runtime tick, no Lattice coordination. Encoding is a
    downward mechanism the region invokes; the only reentrant actor is the region's
    CA3 completion loop. It imports the minting vocabulary (0) and nothing upward;
    its layer(2) matches ordinal 7 (the N6 binding check confirms it), above the
    macromolecular cascade (ordinal 4) it feeds.
*/

% Declare the module: the native encode, the potentiation step, the potentiation occurrent (referenced by the region), and the structure accessors.
:- module(synaptic_stratum, [
    % synaptic_stratum_encode/2: the native write — turn an input pattern into a labile memory trace.
    synaptic_stratum_encode/2,
    % synaptic_stratum_potentiate/2: the raw long-term-potentiation step on a synaptic strength.
    synaptic_stratum_potentiate/2,
    % synaptic_stratum_potentiation_occurrent/1: the LTP occurrent (the region's write-pathway endpoint).
    synaptic_stratum_potentiation_occurrent/1,
    % synaptic_stratum_stratum/1: the synaptic stratum record.
    synaptic_stratum_stratum/1,
    % synaptic_stratum_records/1: the labelled list of this stratum's four structure records.
    synaptic_stratum_records/1
]).

% Import the shared minting vocabulary (Layer 0).
:- use_module(library(causal_grounding)).

% ---------------------------------------------------------------------------
% The native dynamics (kept native per the grounding rule — no CRO for a rate law).
% ---------------------------------------------------------------------------

% The initial synaptic strength set by one encoding bout of potentiation (labile — below the durable threshold).
synaptic_stratum_initial_strength(0.4).
% The strength added by one further long-term-potentiation step.
synaptic_stratum_potentiation_step(0.2).

% -- synaptic_stratum_encode(+Pattern, -Trace): write an input pattern as a labile memory trace.
% The pattern is carried through UNCHANGED as the memory's identity; only the strength is set.
synaptic_stratum_encode(Pattern, mem(Pattern, Strength)) :-
    % Read the initial potentiated (labile) strength.
    synaptic_stratum_initial_strength(Strength).

% -- synaptic_stratum_potentiate(+Strength0, -Strength1): one long-term-potentiation step.
synaptic_stratum_potentiate(Strength0, Strength1) :-
    % Read the potentiation increment.
    synaptic_stratum_potentiation_step(Step),
    % Raise the strength by one step, capped at 1.0.
    Raised is Strength0 + Step,
    % Clamp to the [0.0, 1.0] range.
    ( Raised > 1.0 -> Strength1 = 1.0 ; Strength1 = Raised ).

% ---------------------------------------------------------------------------
% The structure records (co-located with the pack, the verdict's stratum-primary stance).
% ---------------------------------------------------------------------------

% -- synaptic_stratum_stratum(-Out): the synaptic stratum record (ordinal 7).
synaptic_stratum_stratum(Out) :-
    % Mint the synaptic stratum with the anatomy's fields (the shared neuroendocrine ladder).
    cm_stratum("synaptic", "neuroendocrine", 7, "synapse", ["synaptic_physiology"], Out).

% -- synaptic_stratum_synapse_continuant(-Out): the mossy-fiber synapse bearer.
synaptic_stratum_synapse_continuant(Out) :-
    % Mint the mossy-fiber synapse continuant (the dentate -> CA3 encoding synapse).
    cm_cnt("mossy_fiber_synapse", "object", Out).

% -- synaptic_stratum_potentiation_occurrent(-Out): the long-term-potentiation event, stamped at the synaptic stratum.
synaptic_stratum_potentiation_occurrent(Out) :-
    % Read this pack's own stratum id.
    synaptic_stratum_stratum(SSyn),
    % Mint the long-term-potentiation occurrent (the write event that lays down a trace).
    cm_occ("long_term_potentiation", "state_change", SSyn.id, Out).

% -- synaptic_stratum_plasticity_realizable(-Out): the plasticity disposition of the synapse.
synaptic_stratum_plasticity_realizable(Out) :-
    % Read the synapse bearer id.
    synaptic_stratum_synapse_continuant(CSyn),
    % Mint the plasticity disposition it bears.
    cm_rlz(CSyn.id, "disposition", "synaptic_plasticity", Out).

% -- synaptic_stratum_records(-Records): this stratum's four structure records.
synaptic_stratum_records(Records) :-
    % Mint the stratum, the synapse bearer, the potentiation occurrent, and the plasticity disposition.
    synaptic_stratum_stratum(SSyn),
    synaptic_stratum_synapse_continuant(CSyn),
    synaptic_stratum_potentiation_occurrent(OPot),
    synaptic_stratum_plasticity_realizable(RPlast),
    % Assemble the labelled record list.
    Records = [
        record(stratum_synaptic,            stratum,     SSyn),
        record(continuant_mossy_fiber_synapse, continuant, CSyn),
        record(occurrent_long_term_potentiation, occurrent, OPot),
        record(realizable_synaptic_plasticity, realizable, RPlast)
    ].
