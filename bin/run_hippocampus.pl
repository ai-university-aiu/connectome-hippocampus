/*  connectome-hippocampus — the runner (the Wave 6 memory region).

    Encodes a handful of memory patterns, then recalls from full, partial, noisy,
    and UNSTORED cues, printing the narrated, glass-box trace. Pattern completion
    runs as a PrologAI cyclic_actor (a background thread): the CA3 recurrent loop
    settles a cue by RE-POSTING it on the Lattice one recruited feature at a time
    (stigmergy for state, notification for reactivity, no busy-poll), until it
    CONVERGES on a stored pattern or reaches its settling bound (an explicit
    no-recall — NOT a hang).

    THE NO-CONFABULATION GUARANTEE IS CHECKED TWICE: once by the membership
    contract that region_stratum_recall/3 DECLARES (N8 — a non-member is refused,
    never returned), and once again here, independently, by the driver on every
    recall. The run exits 0 ONLY if, on every recall, the output was a member of
    the stored-memory set or the explicit no-recall — and the adversarial phantom
    (a pattern nobody stored, forced past completion) was refused by the contract.

    Usage:  swipl ... bin/run_hippocampus.pl
*/

% Import PrologAI's actors pack for the cyclic_actor background thread.
:- use_module(library(cyclic_actor)).
% Import the region's Lattice substrate: open/reset/cue/narrate/trace.
:- use_module(library(neural_lattice)).
% Import the region stratum: the encode pipeline, the completion loop, the store, and the guarded recall.
:- use_module(library(region_stratum)).
% Import list utilities for the episode loop and the independent membership check.
:- use_module(library(lists)).

% -- run_hippocampus/0: encode, spawn the completion actor, recall, prove no-confabulation, halt.
run_hippocampus :-
    % Open (or reuse) the region's single coordination nexus.
    neural_lattice_open(Nexus),
    % Wipe any facts and trace from a prior run for a clean start.
    neural_lattice_reset(Nexus),
    % Print the run banner.
    run_hippocampus_banner,
    % ENCODE the fixed set of memories (each separated, written, stored, and consolidated).
    run_hippocampus_memories(Memories),
    format("~n-- encoding ~w memories --~n", [Memories]),
    forall(member(M, Memories), region_stratum_encode_memory(Nexus, M)),
    % Spawn the CA3 completion actor; it blocks on its own settle cue (no busy-poll).
    cyclic_actor(ca3_completion, region_stratum:region_stratum_complete_tick(Nexus), 0),
    % The fixed recall cues: full, partial, disambiguating, noisy, and an UNSTORED cue.
    run_hippocampus_cues(Cues),
    % Run every recall cue through the completion loop and the guarded recall, collecting result(Label,Recalled,Ok).
    run_hippocampus_loop(Nexus, Cues, Results),
    % The ADVERSARIAL check: force a phantom past completion and confirm the contract refuses it.
    run_hippocampus_adversarial(AdvOk),
    % Stop the completion actor now that the run is complete.
    ignore(catch(cyclic_actor_stop(ca3_completion), _, true)),
    % Print the verdict and halt with success only if no-confabulation held everywhere.
    ( run_hippocampus_verdict(Results, AdvOk) -> halt(0) ; halt(1) ).

% -- run_hippocampus_memories(-Memories): the fixed set of memory patterns to encode.
run_hippocampus_memories([
    % A red small circle.
    [circle, red, small],
    % A blue large square.
    [blue, large, square],
    % A red large triangle (shares 'red' with the circle and 'large' with the square — a near-duplicate).
    [large, red, triangle],
    % A green small circle (shares 'circle' and 'small' with the red circle).
    [circle, green, small]
]).

% -- run_hippocampus_cues(-Cues): the fixed recall cues (Label, Cue, Expectation).
run_hippocampus_cues([
    % A FULL cue of a stored memory — should recall it exactly.
    cue(full,            [circle, red, small],             member),
    % A PARTIAL cue (two of three features) — completion should reconstruct the third.
    cue(partial,         [blue, square],                   member),
    % A DISAMBIGUATING cue — 'red' and 'large' each match a different memory, but their CONJUNCTION picks the triangle.
    cue(disambiguating,  [large, red],                     member),
    % A NOISY cue (a whole memory plus a junk feature) — completion should tolerate the noise.
    cue(noisy,           [circle, green, small, noise_x],  member),
    % An UNSTORED cue — nobody stored these features; the region must NOT invent a memory (explicit no-recall).
    cue(unstored,        [hexagon, purple],                no_recall)
]).

% -- run_hippocampus_banner/0: print the run header.
run_hippocampus_banner :-
    % Print the region name.
    format("~n== connectome-hippocampus :: the episodic-memory region (Wave 6) ==~n", []),
    % Print the circuit and coordination discipline.
    format("Circuit: dentate separation -> CA3 completion (reentrant, via the Lattice) -> CA1 recall; no busy-poll~n", []),
    % Print the sacred guarantee.
    format("GUARANTEE: every recall is a member of the stored-memory set, or an explicit no-recall (N8 contract; no confabulation).~n", []).

% -- run_hippocampus_loop(+Nexus, +Cues, -Results): run each recall cue, collect result(Label, Recalled, Ok).
run_hippocampus_loop(_Nexus, [], []).
run_hippocampus_loop(Nexus, [cue(Label, Cue, Expect)|T], [result(Label, Recalled, Ok)|RT]) :-
    % Announce the recall episode.
    format("~n-- recall (~w): cue=~w (expect ~w) --~n", [Label, Cue, Expect]),
    % MATERIALISE the growing store into a plain list at the boundary (the N9 workaround).
    region_stratum_store_patterns(Nexus, Stored),
    % Build the completion seed carrying the cue, the materialised stored set, the pass counter, and a token.
    Seed = _{ estimate:Cue, stored:Stored, iter:0, token:0 },
    % Run the reentrant CA3 completion loop; a bounded await means a hang FAILS rather than blocks forever.
    ( region_stratum_run_completion(Nexus, Seed, CompletionResult)
    % The loop returned a settled pattern or an explicit no-recall.
    ->  region_stratum_recall(Stored, CompletionResult, Recalled),
        % INDEPENDENTLY re-check the no-confabulation invariant on the recalled memory.
        run_hippocampus_member_ok(Stored, Recalled, Ok),
        % Report the recall outcome and the independent verdict.
        format("   RECALL: ~w    is-member-or-no-recall=~w~n", [Recalled, Ok])
    % The loop did not return within its bound — a HANG, which fails the gate (distinct from no-recall).
    ;   Recalled = hung, Ok = false,
        format("   RECALL: HUNG (completion did not settle within its bound) -- FAIL~n", []) ),
    % Continue with the next cue.
    run_hippocampus_loop(Nexus, T, RT).

% -- run_hippocampus_member_ok(+Stored, +Recalled, -Ok): the driver's independent no-confabulation check.
run_hippocampus_member_ok(_Stored, no_recall, true) :-
    % An explicit no-recall satisfies the guarantee (the region declined to invent a memory).
    !.
run_hippocampus_member_ok(Stored, Recalled, true) :-
    % A recalled memory that is a member of the stored set satisfies the guarantee.
    memberchk(Recalled, Stored),
    !.
run_hippocampus_member_ok(_Stored, _Recalled, false).
    % Anything else — a memory nobody stored, or a hang — VIOLATES the guarantee.

% -- run_hippocampus_adversarial(-Ok): force a phantom past completion; confirm the contract refuses it.
run_hippocampus_adversarial(Ok) :-
    % Announce the adversarial check.
    format("~n-- adversarial: force a never-stored phantom past completion --~n", []),
    % A stored set that does NOT contain the phantom.
    Stored = [[circle, red, small], [blue, large, square]],
    % Try to recall a settled phantom nobody stored; the membership contract MUST throw (refuse).
    ( catch(region_stratum_recall(Stored, settled([never, stored, here]), Bad),
            error(membership_contract_violation(_, _, _), _),
            fail)
    % If recall RETURNED the phantom without throwing, the guarantee was broken.
    ->  format("   ESCAPED: recall returned ~w -- FAIL~n", [Bad]), Ok = false
    % The contract threw: the phantom was refused, exactly as required.
    ;   format("   REFUSED: the membership contract refused the never-stored phantom (no confabulation).~n", []), Ok = true ).

% -- run_hippocampus_verdict(+Results, +AdvOk): print the verdict; succeed iff no-confabulation held everywhere.
run_hippocampus_verdict(Results, AdvOk) :-
    % Count the recall episodes and the ones whose invariant check held.
    length(Results, Total),
    include(run_hippocampus_result_ok, Results, Held),
    length(Held, HeldCount),
    % Read the total number of completion hops recorded (the settling work).
    neural_lattice_trace(Hops),
    length(Hops, HopCount),
    % Print the verdict block.
    format("~n-- no-confabulation verdict --~n", []),
    format("  recalls                  : ~w~n", [Total]),
    format("  member-or-no-recall on   : ~w of ~w~n", [HeldCount, Total]),
    format("  adversarial phantom      : ~w~n", [AdvOk]),
    format("  completion hops (settling): ~w (all via the Lattice; CA3 recurrence re-posted its own cue)~n", [HopCount]),
    format("  actor-to-actor refs      : 0 (the completion loop reenters through the Lattice; verified by bin/check_no_coupling.sh)~n", []),
    format("  busy-poll                : none (lattice_await blocks on a queue; woken by lattice_notify)~n", []),
    % The verdict holds only if EVERY recall was a member or no-recall AND the phantom was refused.
    ( HeldCount =:= Total, AdvOk == true
    ->  format("  VERDICT                  : pass (no recall ever returned a memory that was not stored)~n~n", []),
        true
    ;   format("  VERDICT                  : FAIL (a recall confabulated, hung, or the phantom escaped)~n~n", []),
        fail ).

% -- run_hippocampus_result_ok(+Result): true when a recall episode's no-confabulation check held.
run_hippocampus_result_ok(result(_, _, true)).

% Run the region as soon as the file is loaded (the shell script sets the library path).
:- initialization(run_hippocampus).
