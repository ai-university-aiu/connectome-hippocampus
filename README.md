# connectome-hippocampus

**A minimal, honest episodic-memory region — encode, pattern-separate,
pattern-complete, and recall — built stratum-primary on PrologAI's two enforced
invariants (the N6 layer-to-stratum binding and the N8 membership contract), whose
recall is incapable of confabulating a memory it never stored.**

> **THE DELIVERABLE IS THE FINDING** — especially about what a growing, recalling
> MEMORY STORE forces PrologAI to lack. The region runs and its no-confabulation
> guarantee holds; but the point of building it is the [LEDGER.md](LEDGER.md)
> (series HIPPO-1, HIPPO-2, …). The headline finding: a memory store is a **growing
> set**, and PrologAI's membership contract wants a **plain list**, so recall must
> materialise the store at the boundary — a second sighting of Ledger gap N9. The
> other gap: consolidation over time has no scheduled construct. A thin Ledger is a
> legitimate result — it means the enforced invariants really did carry the region.

This is **Wave 6** of the Connectome program: the first region whose job is to
**store and recall**, not to relay or select. It is built under the Wave 3 verdict
(`WAVE_3_VERDICT.txt`): **stratum-primary on the outside, atomic-style construct
sub-modules on the inside**, exactly as `connectome-arbiter` was. It is the first
region to rest on the **membership contract (N8)**, as the arbiter was the first to
rest on the **binding (N6)**.

## The four operations

- **Encode** — write an input pattern as a memory (synaptic long-term potentiation
  lays down a labile trace, which the macromolecular cascade consolidates toward
  durable).
- **Pattern separation** (the dentate-gyrus role) — sparse conjunctive expansion,
  so similar inputs get well-separated codes and near-duplicates do not collide.
- **Pattern completion** (the CA3 auto-associative role) — recover a whole stored
  pattern from a partial or noisy cue, as a **reentrant settling loop**.
- **Recall** — return a stored memory, or an explicit **no-recall**. Recall is a
  **constrained selection**: its output must be a member of the stored-memory set.

## No confabulation is the safety property — and it is DECLARED, not hand-rolled

Recall must never return a memory that was never stored. The Wave 4 arbiter proved
its membership invariant by hand (a guard, a throwing emit, a bespoke battery).
This region instead **declares** PrologAI's membership contract on one predicate:

```prolog
% recall returns a stored pattern or the explicit no_recall; the contract enforces it.
region_stratum_recall(_StoredPatterns, CompletionResult, Recalled) :- ... .
% argument 3 (the output) must be a member of argument 1 (the stored set), or no_recall.
:- membership_contract_enforce(region_stratum_recall/3, 3, 1, no_recall).
```

Even if pattern completion produced a phantom, the contract **refuses** it — the
region is structurally incapable of confabulation. This is exactly the remedy the
arbiter's ARBITER-1 finding asked for, now used in anger.

## The decomposition — one pack per stratum, sub-modules inside

| pack | layer | stratum (ordinal) | role · sub-modules |
|---|---|---|---|
| `neural_lattice` | 0 | — (substrate, unbound) | stigmergy + await/notify closure substrate (reused verbatim) |
| `causal_grounding` | 0 | — (substrate, unbound) | the shared Causalontology 3.0.0 minting vocabulary (reused verbatim) |
| `macromolecular_stratum` | 1 | macromolecular (4) | **consolidate** — the calcium-driven cascade, labile → durable (native) |
| `synaptic_stratum` | 2 | synaptic (7) | **encode** — the plasticity write that lays down a trace (native) |
| `region_stratum` | 3 | region (9) | **separate**, **complete** (reentrant), **recall** (membership-contracted) |

The cellular stratum (ordinal 6) is **deliberately not occupied** — no construct in
this cut lives there. Each stratum pack declares both its `layer(N)` (L4) and its
`stratum(Label)` (N6); the binding checker confirms the layers are order-preserving
with the ordinals (4 < 7 < 9 ↔ layers 1 < 2 < 3).

## The reentrant CA3 loop, closed with the hybrid

Pattern completion is a real reentrant loop: a partial cue is fed back through the
recurrent collaterals until it converges. Here that recurrence is **stigmergic** —
the completion tick (`region_stratum_complete_tick/1`, a PrologAI `cyclic_actor`)
awaits a numbered cue on the Lattice, recruits one feature toward the best-matching
stored pattern, and **re-posts its own cue** (the recurrent collateral is a Lattice
write), reentering via notification with no busy-poll and no in-process recursion.
It **provably settles or explicitly no-recalls, never hangs**: the estimate only
grows (monotone), so it reaches a stored pattern or its settling bound. A settled
recall is a decision; a bounded no-recall is legal and narrated; a timeout would be
a hang (a distinct failure the runner reports).

## Cross-repo provenance

The region reuses PrologAI **read-only, by checkout** — no vendoring, no fork. It is
pinned to PrologAI commit **`a1b2343`** (main, Wave 10 Stage 1, the Causalontology 3.0.0 adoption). Every gate resolves PrologAI through the **`PROLOGAI_HOME`** environment
variable (default `/home/ccaitwo/PrologAI`) and stops with a clear message if
PrologAI — or specifically the N8 `membership_contract` construct — is not reachable.

## Running it

```bash
# Point at a PrologAI checkout at (or after) commit a1b2343.
export PROLOGAI_HOME=/path/to/PrologAI

# Encode a handful of memories, then recall from full, partial, noisy, and UNSTORED cues.
bin/run_hippocampus.sh        # exit 0 iff every recall was a member or an explicit no-recall
```

The run narrates, glass-box, every encode (separation, write, consolidation) and
every recall: each CA3 recurrent pass ("recruited a feature, re-entering via the
Lattice"), the settled memory (or the explicit no-recall for an unstored cue), and
the adversarial phantom being **refused** by the contract.

## The gates (all must hold; a skipped safety gate is a failed build)

```bash
bin/check_membership.sh        # 1. NO CONFABULATION — the flagship, non-negotiable gate (the contract refuses every non-member)
bin/run_tests.sh               # every pack's in-pack PLUnit suite, incl. the region's no-confabulation tests
bin/validate_structure.sh      # 22 newly-minted Causalontology 3.0.0 records valid; the cross-stratal skip and the signature verify
bin/check_layers.sh            # L4 — zero upward edges among the declared packs
bin/check_layer_binding.sh     # N6 — every pack's layer is order-preserving with its stratum's ordinal
bin/check_no_coupling.sh       # closure — the CA3 loop reenters through the Lattice; 0 actor-to-actor refs; no busy-poll
```

Plus the mini regression via PrologAI's own harness
(`$PROLOGAI_HOME/bin/run_mini_regression.sh`), in the honest ten-percent form:
ARC-AGI-1 40/40 and ARC-AGI-2 12/12 (a spot-check; the full regression stays
deferred — this is not 400/400).

## What is reused, what is new

- **Reused** (verbatim / read-only): the `neural_lattice` substrate and
  `causal_grounding` vocabulary; the closure hybrid; the structure-minting and
  validation discipline; PrologAI's Lattice, actors, Causalontology engine, and the
  N8 membership contract.
- **New**: the encode / separate / complete / recall / consolidate constructs; a
  Lattice-resident memory store; and the region's own **22** newly-minted
  Causalontology 3.0.0 structure records (not a copy of the slice's twenty-eight).

## What this repository does not do

It does not modify PrologAI, Mentova, the frozen `prologai-loops` spike,
`connectome-proto-agi`, the three frozen Wave 3 arms, or `connectome-arbiter`. It
does not scale to the full connectome or become a general memory framework. It is
one region, built stratum-primary. Open HIPPO Ledger gaps stay open and honestly
recorded.
