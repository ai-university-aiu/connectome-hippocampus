/*  connectome-hippocampus — region_stratum (ordinal 9 -> pack layer 3): THE HIPPOCAMPAL CIRCUIT.

    The memory region's heart: the DENTATE -> CA3 -> CA1 circuit, at the region
    stratum (Causalontology ordinal 9). Under the Wave 3 verdict's rule it is one
    pack per stratum on the OUTSIDE, and one construct per module on the INSIDE:
    the circuit's machinery is THREE independently testable internal sub-modules —
      - SEPARATE  (region_stratum_separate/2): the DENTATE-GYRUS role — sparse
                  conjunctive expansion of a pattern (its features AND their
                  pairwise conjunctions), so similar inputs get well-separated
                  codes and near-duplicates do not collide on the way in.
      - COMPLETE  (region_stratum_complete_step/3 + region_stratum_complete_tick/1):
                  the CA3 AUTO-ASSOCIATIVE role — pattern completion is a REENTRANT
                  settling loop. A partial/noisy cue is fed back through the
                  recurrent collaterals (here: re-posted on the Lattice) one
                  recruited feature at a time until it CONVERGES on a stored
                  pattern, or the settling bound is reached (an explicit no-recall,
                  not a hang). Monotone: the estimate only grows, so it settles or
                  bounds — provably, never loops forever.
      - RECALL    (region_stratum_recall/3): the constrained selection — return a
                  stored pattern or the explicit no-recall. RECALL DECLARES THE
                  MEMBERSHIP CONTRACT (PrologAI's N8): its output must be a member
                  of the stored-memory set, or the declared abstention no_recall.
                  The region is therefore INCAPABLE OF CONFABULATION — it can never
                  return a memory it never stored, even if completion produced a
                  phantom, because the contract refuses a non-member.

    NO-CONFABULATION IS THE SAFETY PROPERTY THIS REGION CONTRIBUTES, and the
    membership contract is exactly the language guarantee for it. Unlike the Wave 4
    arbiter — which hand-rolled its membership guard because N8 did not yet exist —
    this region DECLARES the contract and hand-rolls nothing (see the directive
    below region_stratum_recall/3).

    THE MEMORY STORE lives on the Lattice as one fact per stored memory (stigmergy):
    encoding DEPOSITS a stored/2 fact; recall MATERIALISES the growing set into a
    plain list at the boundary. That materialisation is a second sighting of Ledger
    gap N9 (the contract wants a plain list, a growing store is not one) — see
    LEDGER.md HIPPO-1.

    Its STRUCTURE is grounded in Causalontology 2.0.0: the region stratum, the
    hippocampus bearer, the separation/completion/recall occurrents, the storage
    disposition, the cue and recall ports, the region-internal recall CRO, the
    computational recall conduit, the CROSS-STRATAL consolidation CRO (macromolecular
    durable trace -> region recall, skips:true — the same honest skip the slice and
    arbiter recorded), and a signed provenance assertion over it.

    It coordinates its completion loop ONLY through the Lattice, by numbered cue,
    and never names another stratum's runtime tick. It imports the synaptic write
    (Layer 2) and the macromolecular cascade (Layer 1) — DOWNWARD edges — for the
    encode pipeline and the cross-stratal grounding, plus the minting vocabulary,
    the Lattice, and PrologAI's membership_contract construct. Its layer(3),
    matching ordinal 9 as the coarsest stratum the region touches, passes both the
    layer rule and the N6 binding.
*/

% Declare the module: the reentrant completion tick, the three sub-modules, the store, recall, the encode pipeline, and the structure accessors.
:- module(region_stratum, [
    % region_stratum_separate/2: the dentate-gyrus sparse conjunctive separation code of a pattern.
    region_stratum_separate/2,
    % region_stratum_best_match/4: the stored pattern whose separation code overlaps a cue's most.
    region_stratum_best_match/4,
    % region_stratum_complete_step/3: ONE CA3 settling step — converged / dead / continue.
    region_stratum_complete_step/3,
    % region_stratum_complete_tick/1: the reentrant completion actor — settles via the Lattice.
    region_stratum_complete_tick/1,
    % region_stratum_recall/3: the constrained selection — a stored pattern or no_recall (membership-contracted).
    region_stratum_recall/3,
    % region_stratum_store_encode/3: deposit one stored memory fact on the Lattice.
    region_stratum_store_encode/3,
    % region_stratum_store_patterns/2: materialise the growing store into a plain list (the N9 boundary).
    region_stratum_store_patterns/2,
    % region_stratum_encode_memory/2: the full encode pipeline (separate -> synaptic write -> store -> consolidate).
    region_stratum_encode_memory/2,
    % region_stratum_run_completion/3: drive the reentrant completion loop for one cue and read its outcome.
    region_stratum_run_completion/3,
    % region_stratum_recall_occurrent/1: the memory-recall occurrent (cross-stratal CRO effect endpoint).
    region_stratum_recall_occurrent/1,
    % region_stratum_stratum/1: the region stratum record (its ordinal is read by the skip check).
    region_stratum_stratum/1,
    % region_stratum_consolidation_cro/1: the cross-stratal consolidation CRO (macromolecular -> region, skips:true).
    region_stratum_consolidation_cro/1,
    % region_stratum_skip_check/2: the skip classification of the cross-stratal consolidation CRO.
    region_stratum_skip_check/2,
    % region_stratum_signed_assertion/1: the Ed25519-signed provenance over the consolidation CRO.
    region_stratum_signed_assertion/1,
    % region_stratum_records/1: the labelled list of this stratum's twelve structure records.
    region_stratum_records/1
]).

% Import the shared minting vocabulary (Layer 0).
:- use_module(library(causal_grounding)).
% Import the Lattice substrate (Layer 0) for the reentrant settling loop and the memory store.
:- use_module(library(neural_lattice)).
% Import the synaptic write (Layer 2) for the encode pipeline and the potentiation occurrent the cue port accepts.
:- use_module(library(synaptic_stratum)).
% Import the macromolecular cascade (Layer 1) for consolidation and the durable-trace occurrent the cross-stratal CRO names.
:- use_module(library(macromolecular_stratum)).
% Import PrologAI's Causalontology engine (external) for the skip classification.
:- use_module(library(causal_core)).
% Import PrologAI's MEMBERSHIP CONTRACT construct (N8, external) — recall DECLARES the contract with it.
:- use_module(library(membership_contract)).
% Import PrologAI's Lattice directly: deposit a stored-memory fact, enumerate the store, and the BOUNDED result await.
:- use_module(library(lattice), [lattice_put/4, lattice_get/4, lattice_await/5, lattice_take/4]).
% Import list utilities for the set operations.
:- use_module(library(lists)).

% ---------------------------------------------------------------------------
% SEPARATE — the dentate-gyrus sparse conjunctive expansion.
% ---------------------------------------------------------------------------

% -- region_stratum_separate(+Pattern, -SepCode): the separation code of a pattern.
% The code is the pattern's own features (unary cells) PLUS every pairwise conjunction
% (conjunctive cells). Two patterns that share single features but differ in their
% conjunctions get well-separated codes — the dentate's role — while a partial cue of P
% still overlaps P's code most. Sorted and deduplicated so overlap is a set operation.
region_stratum_separate(Pattern, SepCode) :-
    % Sort and deduplicate the raw pattern so the code is canonical.
    sort(Pattern, Feats),
    % The unary cells: one u(F) per feature.
    findall(u(F), member(F, Feats), Unary),
    % The conjunctive cells: one p(X,Y) per ordered feature pair X < Y.
    findall(p(X, Y), (member(X, Feats), member(Y, Feats), X @< Y), Pairs),
    % The separation code is the union of the unary and conjunctive cells, sorted.
    append(Unary, Pairs, Code0),
    sort(Code0, SepCode).

% -- region_stratum_overlap(+CodeA, +CodeB, -Count): the number of shared separation cells.
region_stratum_overlap(CodeA, CodeB, Count) :-
    % Intersect the two sorted codes and count the shared cells.
    ord_intersection(CodeA, CodeB, Shared),
    length(Shared, Count).

% -- region_stratum_best_match(+CueCode, +StoredPatterns, -Best, -Overlap): the top-overlapping stored pattern.
% Best is the stored pattern whose separation code shares the most cells with CueCode;
% Overlap is that count. Deterministic: ties keep the earliest stored pattern.
region_stratum_best_match(CueCode, [P0|Ps], Best, Overlap) :-
    % Score the first stored pattern.
    region_stratum_separate(P0, C0),
    region_stratum_overlap(CueCode, C0, O0),
    % Fold the rest, keeping whichever pattern overlaps the cue more.
    foldl(region_stratum_keep_closer(CueCode), Ps, P0-O0, Best-Overlap).

% -- region_stratum_keep_closer(+CueCode, +P, +Best0-O0, -Best1-O1): keep the higher-overlap pattern.
region_stratum_keep_closer(CueCode, P, _Best0-O0, P-O1) :-
    % Score this candidate pattern.
    region_stratum_separate(P, C),
    region_stratum_overlap(CueCode, C, O1),
    % It strictly beats the incumbent on overlap.
    O1 > O0, !.
region_stratum_keep_closer(_CueCode, _P, Best0-O0, Best0-O0).
    % Otherwise the incumbent best is retained (ties keep the earlier pattern).

% ---------------------------------------------------------------------------
% COMPLETE — one CA3 settling step (pure), classified converged / dead / continue.
% ---------------------------------------------------------------------------

% The settling bound: the maximum number of recurrent passes before an explicit no-recall.
region_stratum_settling_bound(16).

% -- region_stratum_complete_step(+Estimate, +StoredPatterns, -Outcome): one auto-associative pass.
% Find the best-matching stored pattern; if the cue overlaps nothing stored it is a DEAD cue
% (no_recall); if the estimate already contains the whole best pattern it has CONVERGED on it;
% otherwise recruit one missing feature of the best pattern and CONTINUE (the estimate grows).
region_stratum_complete_step(Estimate, StoredPatterns, Outcome) :-
    % Separate the current estimate into its code.
    region_stratum_separate(Estimate, ECode),
    % Find the best-matching stored pattern and its overlap.
    region_stratum_best_match(ECode, StoredPatterns, Best, Overlap),
    % Canonicalise the estimate as a set for the subset test.
    sort(Estimate, ESet),
    % Canonicalise the best pattern as a set.
    sort(Best, BestSet),
    % Classify the step.
    ( Overlap =:= 0
    % The cue shares no separation cell with any stored memory — a dead cue, no recall.
    ->  Outcome = dead
    ; ord_subtract(BestSet, ESet, [])
    % The estimate already contains every feature of the best pattern — converged on it.
    ->  Outcome = converged(Best)
    ; ord_subtract(BestSet, ESet, [Missing|_])
    % Recruit the first missing feature of the best pattern into the estimate (monotone growth).
    ->  ord_union(ESet, [Missing], Estimate1),
        Outcome = continue(Estimate1)
    ).

% ---------------------------------------------------------------------------
% COMPLETE — the reentrant runtime actor, closed with the Lattice hybrid.
% ---------------------------------------------------------------------------

% -- region_stratum_complete_tick(+Nexus): one CA3 recurrent pass, coordinated through the Lattice.
% Awaits the numbered settle cue (phase 1), does ONE settling step, and either POSTS THE NEXT
% SETTLE CUE (reentry through the Lattice — the recurrent collateral) or posts the settled result
% (phase 2). It NEVER calls itself in-process: the recurrence is the cyclic_actor re-firing on the
% Lattice cue it re-posts, which is why this loop is stigmergic, not a stack recursion.
region_stratum_complete_tick(Nexus) :-
    % Block with no busy-poll until the settle cue (phase 1) exists, then take it.
    neural_lattice_await_cue(Nexus, 1, State0),
    % Read the current estimate, the stored patterns, the pass counter, and the token.
    get_dict(estimate, State0, Estimate),
    get_dict(stored, State0, StoredPatterns),
    get_dict(iter, State0, Iter0),
    get_dict(token, State0, Token0),
    % Do ONE auto-associative settling step.
    region_stratum_complete_step(Estimate, StoredPatterns, Step),
    % Advance the token by one for this recurrent hop.
    Token is Token0 + 1,
    % Record and print the completion hop; the beat arrived VIA the Lattice.
    neural_lattice_hop(lattice, ca3_completion, Token),
    % Read the settling bound.
    region_stratum_settling_bound(Bound),
    % Route the step to a reentry or a result.
    ( Step = converged(S)
    % Converged: narrate and post the settled stored pattern on phase 2.
    ->  format(string(L1), "CA3: settled after ~w recurrent pass(es) — converged on a stored pattern", [Iter0]),
        neural_lattice_narrate('      ', L1),
        State1 = State0.put(_{result: settled(S), token: Token}),
        neural_lattice_post_cue(Nexus, 2, State1)
    ; Step = dead
    % Dead cue: narrate the explicit no-recall (not a hang) and post it on phase 2.
    ->  neural_lattice_narrate('      ', "CA3: the cue matched no stored memory — explicit no-recall"),
        State1 = State0.put(_{result: no_recall, token: Token}),
        neural_lattice_post_cue(Nexus, 2, State1)
    ; Step = continue(_AtBound),
      Iter0 >= Bound
    % The settling bound was reached without converging: an explicit no-recall, still not a hang.
    ->  neural_lattice_narrate('      ', "CA3: reached the settling bound without converging — explicit no-recall"),
        State1 = State0.put(_{result: no_recall, token: Token}),
        neural_lattice_post_cue(Nexus, 2, State1)
    ; Step = continue(Estimate1)
    % Not yet converged: recruit one feature and RE-ENTER by re-posting the settle cue on the Lattice.
    ->  Iter1 is Iter0 + 1,
        format(string(L2), "CA3: recurrent pass ~w — recruited a feature, re-entering via the Lattice", [Iter1]),
        neural_lattice_narrate('      ', L2),
        State1 = State0.put(_{estimate: Estimate1, iter: Iter1, token: Token}),
        neural_lattice_post_cue(Nexus, 1, State1)
    ).

% -- region_stratum_run_completion(+Nexus, +CompletionSeed, -Result): post the cue, await the settled result.
% Seeds the reentrant loop with the cue and the (already materialised) stored patterns, then blocks
% (BOUNDED) for the phase-2 result — settled(Pattern) or no_recall. A timeout would be a HANG (a
% failure distinct from no_recall), which the runner reports; a clean run always yields a result.
region_stratum_run_completion(Nexus, CompletionSeed, Result) :-
    % Post the initial settle cue (phase 1) — the partial/noisy cue enters the recurrent loop.
    neural_lattice_post_cue(Nexus, 1, CompletionSeed),
    % Block (BOUNDED, 30 s) for the phase-2 settled result; on timeout this FAILS (a hang the runner
    % reports) rather than blocking forever — the settling always posts a result within its bound.
    lattice_await(Nexus, phase_2, 30, _, _),
    % Consume exactly one phase-2 result cue.
    lattice_take(Nexus, phase_2, [Done], _),
    % Read the completion result the tick posted (settled(Pattern) or no_recall).
    get_dict(result, Done, Result).

% ---------------------------------------------------------------------------
% THE MEMORY STORE — one fact per stored memory on the Lattice (stigmergy).
% ---------------------------------------------------------------------------

% -- region_stratum_store_encode(+Nexus, +Pattern, +Strength): deposit one stored memory fact.
region_stratum_store_encode(Nexus, Pattern, Strength) :-
    % Put a stored/2 node-fact carrying the memory's pattern and its current strength.
    lattice_put(Nexus, stored, [Pattern, Strength], []).

% -- region_stratum_store_patterns(+Nexus, -Patterns): materialise the growing store into a plain list.
% THE N9 BOUNDARY. The store is a growing set of independent Lattice facts (stigmergy); the membership
% contract needs a PLAIN LIST. So the current stored set is enumerated and flattened to a list here,
% at the recall boundary — the honest workaround recorded in LEDGER.md HIPPO-1 (a second sighting of N9).
region_stratum_store_patterns(Nexus, Patterns) :-
    % Enumerate every stored memory fact currently on the Lattice (lattice_get backtracks over matches).
    findall(Pattern, lattice_get(Nexus, stored, [Pattern, _Strength], _), Raw),
    % Deduplicate into the canonical stored-pattern list the contract will check membership against.
    sort(Raw, Patterns).

% ---------------------------------------------------------------------------
% RECALL — the constrained selection; DECLARES the membership contract (N8).
% ---------------------------------------------------------------------------

% -- region_stratum_recall(+StoredPatterns, +CompletionResult, -Recalled): the guarded recall.
% Returns the pattern the CA3 loop settled on, or the explicit no_recall. It is deliberately thin:
% the SAFETY comes from the membership contract declared below, not from a hand-rolled guard. Even a
% settled(Phantom) whose Phantom is not in StoredPatterns is refused by the contract — no confabulation.
region_stratum_recall(_StoredPatterns, CompletionResult, Recalled) :-
    % The explicit no-recall is the declared abstention; a settled pattern is returned as the recalled memory.
    % Deterministic (one clause, no leftover choicepoint); the contract below is what makes it safe.
    ( CompletionResult == no_recall
    ->  Recalled = no_recall
    ;   CompletionResult = settled(Recalled) ).

% DECLARE THE MEMBERSHIP CONTRACT: argument 3 (the recalled output) must be a member of argument 1
% (the stored-memory set), or the declared abstention no_recall. This is the N8 language guarantee
% that makes the region incapable of confabulating a memory it never stored — nothing is hand-rolled.
:- membership_contract_enforce(region_stratum_recall/3, 3, 1, no_recall).

% ---------------------------------------------------------------------------
% ENCODE PIPELINE — separate, write (synaptic, downward), store, consolidate (macromolecular, downward).
% ---------------------------------------------------------------------------

% -- region_stratum_encode_memory(+Nexus, +InputPattern): store one memory, separated, written, and consolidated.
% Feed-forward composition of downward sub-modules (permitted structural reuse, not runtime tick coupling):
% the dentate separates, the synaptic stratum writes a labile trace, the store deposits it, and the
% macromolecular cascade consolidates it toward durable. Consolidation here is SYNCHRONOUS — the region
% has no way to schedule a delayed, sleep-time consolidation; that limit is recorded in LEDGER.md HIPPO-2.
region_stratum_encode_memory(Nexus, InputPattern) :-
    % Canonicalise the input pattern as a set (the memory's identity).
    sort(InputPattern, Pattern),
    % SEPARATE: compute the dentate separation code (kept for narration; it decorrelates near-duplicates).
    region_stratum_separate(Pattern, SepCode),
    % Report the separation cell count in glass-box style.
    length(SepCode, NCells),
    format(string(LSep), "encode: dentate separated ~w into a ~w-cell sparse code", [Pattern, NCells]),
    neural_lattice_narrate('      ', LSep),
    % WRITE: the synaptic stratum potentiates a labile trace for this pattern (downward call).
    synaptic_stratum_encode(Pattern, mem(Pattern, Strength0)),
    % STORE: deposit the labile trace as a stored-memory fact on the Lattice.
    region_stratum_store_encode(Nexus, Pattern, Strength0),
    % CONSOLIDATE: the macromolecular cascade strengthens the labile trace toward durable (downward call).
    macromolecular_stratum_consolidate(mem(Pattern, Strength0), mem(Pattern, Strength1)),
    % Report the write-and-consolidate outcome, noting durability.
    ( macromolecular_stratum_is_durable(mem(Pattern, Strength1)) -> Durab = durable ; Durab = labile ),
    format(string(LEnc), "encode: synaptic write strength ~3f -> consolidated ~3f (~w)", [Strength0, Strength1, Durab]),
    neural_lattice_narrate('      ', LEnc).

% ---------------------------------------------------------------------------
% The structure records (co-located with the runtime, the verdict's stratum-primary stance).
% ---------------------------------------------------------------------------

% -- region_stratum_stratum(-Out): the brain-region stratum record (ordinal 9).
region_stratum_stratum(Out) :-
    % Mint the region stratum with the anatomy's fields (the shared neuroendocrine ladder).
    cm_stratum("region", "neuroendocrine", 9, "brain_region", ["systems_neuroscience"], Out).

% -- region_stratum_hippocampus_continuant(-Out): the hippocampus bearer (the memory circuit).
region_stratum_hippocampus_continuant(Out) :-
    % Mint the hippocampus continuant (the physical bearer of the dentate -> CA3 -> CA1 circuit).
    cm_cnt("hippocampus", "object", Out).

% -- region_stratum_separation_occurrent(-Out): the pattern-separation process, at the region stratum.
region_stratum_separation_occurrent(Out) :-
    % Read this pack's own stratum id.
    region_stratum_stratum(SRegion),
    % Mint the pattern-separation occurrent (the dentate decorrelation process).
    cm_occ("pattern_separation", "process", SRegion.id, Out).

% -- region_stratum_completion_occurrent(-Out): the pattern-completion process, at the region stratum.
region_stratum_completion_occurrent(Out) :-
    % Read this pack's own stratum id.
    region_stratum_stratum(SRegion),
    % Mint the pattern-completion occurrent (the CA3 auto-associative settling process).
    cm_occ("pattern_completion", "process", SRegion.id, Out).

% -- region_stratum_recall_occurrent(-Out): the memory-recall event, at the region stratum.
region_stratum_recall_occurrent(Out) :-
    % Read this pack's own stratum id.
    region_stratum_stratum(SRegion),
    % Mint the memory-recall occurrent (the constrained read-out event).
    cm_occ("memory_recall", "event", SRegion.id, Out).

% -- region_stratum_storage_realizable(-Out): the memory-storage disposition of the hippocampus.
region_stratum_storage_realizable(Out) :-
    % Read the hippocampus bearer id.
    region_stratum_hippocampus_continuant(CHippo),
    % Mint the storage/recall disposition it bears.
    cm_rlz(CHippo.id, "disposition", "memory_storage", Out).

% -- region_stratum_cue_input_port(-Out): the cue input, accepting separation and the synaptic write.
region_stratum_cue_input_port(Out) :-
    % The bearer is the hippocampus.
    region_stratum_hippocampus_continuant(CHippo),
    % The port accepts the pattern-separation occurrent.
    region_stratum_separation_occurrent(OSep),
    % It also accepts the synaptic long-term-potentiation occurrent (a downward reference to synaptic_stratum).
    synaptic_stratum_potentiation_occurrent(OPot),
    % Mint the input port accepting both the separation and the write (a cue enters and is written).
    cm_port(CHippo.id, "cue_input", "in", [OSep.id, OPot.id], Out).

% -- region_stratum_recall_output_port(-Out): the recalled-memory output port.
region_stratum_recall_output_port(Out) :-
    % The bearer is the hippocampus.
    region_stratum_hippocampus_continuant(CHippo),
    % The port emits the memory-recall occurrent.
    region_stratum_recall_occurrent(ORecall),
    % Mint the output port.
    cm_port(CHippo.id, "recall_output", "out", [ORecall.id], Out).

% -- region_stratum_recall_cro(-Out): the region-internal recall CRO (completion -> recall).
region_stratum_recall_cro(Out) :-
    % The cause is the pattern-completion occurrent.
    region_stratum_completion_occurrent(OComplete),
    % The effect is the memory-recall occurrent (both at the region stratum — no cross-stratal span).
    region_stratum_recall_occurrent(ORecall),
    % Mint the recall CRO with its modality and temporal window.
    cm_cro([OComplete.id], [ORecall.id],
           [modality-"sufficient", temporal-_{minimum_delay:0, maximum_delay:1, unit:"seconds"}],
           Out).

% -- region_stratum_recall_conduit(-Out): the COMPUTATIONAL recall pathway (transform = the recall CRO).
region_stratum_recall_conduit(Out) :-
    % The from-port is the cue input.
    region_stratum_cue_input_port(PIn),
    % The to-port is the recall output.
    region_stratum_recall_output_port(POut),
    % The carried occurrent is the pattern completion.
    region_stratum_completion_occurrent(OComplete),
    % The transform is the recall CRO — asserting the conduit computes (it completes and reads out, a wire cannot).
    region_stratum_recall_cro(CroRecall),
    % Mint the computational conduit.
    cm_conduit(PIn.id, POut.id, [OComplete.id], "recall_pathway", CroRecall.id, Out).

% -- region_stratum_consolidation_cro(-Out): the CROSS-STRATAL consolidation CRO (macromolecular durable -> region recall, skips:true).
region_stratum_consolidation_cro(Out) :-
    % The cause is the macromolecular durable-trace occurrent (ordinal 4) — a downward reference to macromolecular_stratum.
    macromolecular_stratum_durable_occurrent(ODurable),
    % The effect is this region's memory-recall occurrent (ordinal 9) — durable consolidation enables durable recall.
    region_stratum_recall_occurrent(ORecall),
    % Mint the CRO flagged skips:true — this cut jumps macromolecular 4 -> region 9 without modeling the intervening pathway.
    cm_cro([ODurable.id], [ORecall.id], [skips-true], Out).

% -- region_stratum_signed_assertion(-Signed): an Ed25519-signed provenance over the consolidation CRO.
region_stratum_signed_assertion(Signed) :-
    % Read the consolidation CRO's content-addressed id.
    region_stratum_consolidation_cro(CroCons),
    % Mint and sign the provenance assertion over that id.
    cm_signed_assertion_over(CroCons.id, Signed).

% -- region_stratum_skip_check(-Class, -Gaps): classify the cross-stratal consolidation CRO and read its skip-gaps.
region_stratum_skip_check(Class, Gaps) :-
    % Mint the consolidation CRO and its two endpoint occurrents.
    region_stratum_consolidation_cro(CroCons),
    macromolecular_stratum_durable_occurrent(ODurable),
    region_stratum_recall_occurrent(ORecall),
    % Mint the two strata the CRO spans (this region's, and the imported macromolecular).
    region_stratum_stratum(SRegion),
    macromolecular_stratum_stratum(SMacro),
    % Build the occurrent and stratum maps the classifier needs.
    cm_map_of([ODurable, ORecall], OccMap),
    cm_map_of([SRegion, SMacro], StratumMap),
    % Classify the cross-stratal relation (expected: skipping).
    causal_core_classify(CroCons, OccMap, StratumMap, Class),
    % Read the skip-gaps (expected: none — skips:true makes the absence of a modeled mechanism a positive finding).
    causal_core_skip_gaps(CroCons, Class, Gaps).

% -- region_stratum_records(-Records): this stratum's twelve structure records.
region_stratum_records(Records) :-
    % Mint the stratum, the bearer, and the three occurrents.
    region_stratum_stratum(SRegion),
    region_stratum_hippocampus_continuant(CHippo),
    region_stratum_separation_occurrent(OSep),
    region_stratum_completion_occurrent(OComplete),
    region_stratum_recall_occurrent(ORecall),
    % Mint the realizable, the two ports, the recall CRO, and the recall conduit.
    region_stratum_storage_realizable(RStore),
    region_stratum_cue_input_port(PIn),
    region_stratum_recall_output_port(POut),
    region_stratum_recall_cro(CroRecall),
    region_stratum_recall_conduit(KRecall),
    % Mint the cross-stratal consolidation CRO and the signed provenance over it.
    region_stratum_consolidation_cro(CroCons),
    region_stratum_signed_assertion(Signed),
    % Assemble the labelled record list.
    Records = [
        record(stratum_region,               stratum,                SRegion),
        record(continuant_hippocampus,        continuant,             CHippo),
        record(occurrent_pattern_separation,  occurrent,              OSep),
        record(occurrent_pattern_completion,  occurrent,              OComplete),
        record(occurrent_memory_recall,       occurrent,              ORecall),
        record(realizable_memory_storage,     realizable,             RStore),
        record(port_cue_input,                port,                   PIn),
        record(port_recall_output,            port,                   POut),
        record(cro_recall,                    causal_relation_object, CroRecall),
        record(conduit_recall,                conduit,                KRecall),
        record(cro_cross_stratal_consolidation, causal_relation_object, CroCons),
        record(assertion_consolidation_provenance, assertion,         Signed)
    ].
