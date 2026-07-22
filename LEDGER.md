# LEDGER.md — connectome-hippocampus Requirements Ledger (HIPPO series)

> The Connectome program's method is to BUILD a region and let the build surface
> what PrologAI cannot yet express. This memory region rests on two enforced
> PrologAI invariants delivered in earlier waves — **N6** (bind a pack's layer to
> its stratum ordinal) and **N8** (the membership contract) — and records here what
> a growing, recalling MEMORY STORE forced PrologAI to lack.
>
> Series **HIPPO-1, HIPPO-2, …** so findings never collide with the spike's
> L-series, PrologAI's N-series, the slice's P-series, or the ATOMIC / LOOPS /
> STRATA / ARBITER series. Each finding names the construct that forced it, what
> PrologAI could not express, the evidence (file:line), and the minimum remedy.
> Parents are cited for second sightings.
>
> The region was built at a PINNED PrologAI commit, **a1b2343** (main, Wave 10 Stage 1, the Causalontology 3.0.0 adoption), reused read-only through `PROLOGAI_HOME`; PrologAI
> was not modified. A gap is a Ledger entry, never a commit against PrologAI.

Legend: **S** = severity for the Connectome plan (H/M/L).
Status: **OPEN** (recorded, not fixed here) · **CLOSED**.

---

## What the enforced invariants carried (the positive result)

Two things the region needed, PrologAI already gave it — so they are NOT findings,
they are the program working as designed. Recording them keeps the Ledger honest
about what did NOT need inventing:

- **No-confabulation was a single declaration, not a hand-rolled guard.** The Wave 4
  arbiter proved its membership invariant by hand — a guard predicate, a throwing
  emit, and a 532-attempt battery. This region obtains the same guarantee for
  RECALL by DECLARING PrologAI's membership contract (N8) on one predicate
  (`packs/region_stratum/prolog/region_stratum.pl:289`,
  `:- membership_contract_enforce(region_stratum_recall/3, 3, 1, no_recall)`).
  A recalled memory is a member of the stored set or the explicit `no_recall`;
  a phantom is refused by the contract, not by code the region author wrote. The
  no-confabulation battery inspects 255 attempts with 0 escapes and 88 phantoms
  refused. This is exactly the remedy ARBITER-1 asked for, now used in anger.
- **The reentrant CA3 loop needed nothing the closure hybrid did not already give.**
  Pattern completion is a genuine reentrant loop, and it rode the Lattice cleanly:
  the completion tick awaits a numbered cue, does one settling step, and RE-POSTS
  its own cue (the recurrent collateral is a Lattice write), reentering via
  stigmergy plus notification — never an in-process recursion (proved non-vacuously
  by `bin/check_no_coupling.sh`). Convergence is provable: the estimate only grows
  (monotone), so it settles on a stored pattern or reaches its bound (an explicit
  no-recall, never a hang).
- **N10 did not bite.** PrologAI's contract enforces per-solution (Ledger gap N10);
  recall is deterministic (one answer), so per-solution enforcement is exactly
  right here. N10 is confirmed to be scoped to nondeterministic producers, not to
  selectors/recall — no finding.

---

## HIPPO-1 — a growing memory store is not a plain list, but the membership contract requires one · S=M · **OPEN** (second sighting of N9)

- **The construct that forced it.** RECALL, declaring the membership contract (N8).
- **What PrologAI could not express.** The membership contract's offered-set
  argument must be a **plain list** at call time: `membership_contract_check/4`
  throws `membership_contract_input_not_a_list` when its input set is not a proper
  list (PrologAI `packs/membership_contract/prolog/membership_contract.pl:129`,
  `\+ is_list(In)`). But a memory store is naturally a **growing set of independent
  facts**, not a list — here, one `stored/2` node-fact per memory on the Lattice
  (stigmergy), which is how deposits accumulate and how a content-addressed store
  would work. There is no way to hand the contract "the current stored set on the
  Lattice" directly; it must first be flattened.
- **Evidence.** `packs/region_stratum/prolog/region_stratum.pl:265`
  (`region_stratum_store_patterns/2`) enumerates every `stored/2` fact
  (`:267`, `findall(Pattern, lattice_get(Nexus, stored, [Pattern,_], _), Raw)`) and
  sorts it into a plain list **at the recall boundary**, purely so the contract can
  check membership against it. That materialisation is the whole finding.
- **The honest workaround, recorded as a workaround.** Materialise the growing store
  to a list once per recall, at the boundary. It is O(store size) per recall and
  copies the whole set each time — acceptable for a small demo, wrong for a large or
  streaming store.
- **Minimum remedy.** An accessor form of the contract (Ledger gap N9's proposed
  remedy): let a contract name a deterministic goal that PRODUCES the offered set
  (e.g. `region_stratum_store_patterns(Nexus, -List)`), so the set need not already
  be a bare list argument and need not be materialised eagerly. **Parent: N9**
  (first sighted while building the Wave 5 contract; this is its first sighting in
  a real consumer — a growing store is exactly the case N9 anticipated).

## HIPPO-2 — consolidation over time has no temporal or scheduled construct · S=M · **OPEN** (new gap)

- **The construct that forced it.** CONSOLIDATION (the macromolecular cascade) and
  the encode pipeline that invokes it.
- **What PrologAI could not express.** Real systems consolidation is DELAYED — a
  labile trace becomes durable over time (sleep-time replay), not instantly. The
  region can represent the delay only as **data**: the consolidation CRO carries an
  honest, wide temporal window (`packs/macromolecular_stratum/prolog/macromolecular_stratum.pl:116`,
  `minimum_delay:1, maximum_delay:3600, unit:"seconds"`). But nothing SCHEDULES a
  deferred consolidation. The Lattice is reactive (await/notify on writes) with no
  timer, no wall-clock wakeup, and no scheduled reactivation; and there is no
  PrologAI construct for "run this process after a delay" or "reactivate this trace
  later." So the region consolidates **synchronously**, right after the synaptic
  write.
- **Evidence.** `packs/region_stratum/prolog/region_stratum.pl:300`
  (`region_stratum_encode_memory/2`) calls `macromolecular_stratum_consolidate/2`
  immediately after the store deposit (`:313`) — one pass to durable, in the same
  breath as encoding. The delay lives in the CRO's temporal field but is never
  enacted.
- **Minimum remedy.** A scheduled/temporal affordance PrologAI lacks: either a
  Lattice timer (a `lattice_await` with a scheduled wakeup that fires without a
  write), or a small "deferred reactivation" construct that re-posts a
  consolidation cue after a modelled delay. Until then, delayed consolidation
  (and any time-based memory process — decay, spaced repetition, replay) can be
  described as data but not run. Recorded, not closed.

## HIPPO-3 — the cross-stratal consolidation seam skips intervening strata with no modelled mechanism · S=L · **OPEN** (recurrence of P1/P2)

- **The construct that forced it.** The cross-stratal consolidation CRO
  (macromolecular durable trace, ordinal 4 → region recall, ordinal 9).
- **What PrologAI could not express (that this cut chose not to).** The relation
  jumps from the macromolecular stratum to the region stratum, skipping the
  cellular (6) and synaptic (7) strata between them. This region does not model the
  intervening cellular/synaptic pathway that actually carries consolidation upward,
  so the CRO carries `skips:true` honestly and classifies as a clean skip with no
  gap (validated: `skipping`, `skip-gaps=[]`). The ABSENCE of a modelled
  intervening mechanism across strata is the same unmanaged cross-stratal seam the
  slice (P1/P2) and the strata arm recorded — surfaced again wherever a process
  legitimately spans non-adjacent strata.
- **Evidence.** `packs/region_stratum/prolog/region_stratum.pl:413`
  (`cm_cro([ODurable.id], [ORecall.id], [skips-true], Out)`), validated by
  `region_stratum_skip_check/2` and `bin/validate_structure.sh`.
- **Minimum remedy.** As P1/P2 named it: either model the intervening strata (mint
  the cellular and synaptic occurrents the consolidation actually flows through, so
  the relation is a chain of adjacent-stratum steps rather than one skip), or a
  first-class "managed seam" construct that records an intentional cross-stratal
  jump as more than a boolean flag. Recorded as an honest skip, not closed.
  **Parents: P1, P2** (the slice's unmanaged-seam findings).

---

## Summary

Three findings, all OPEN, none blocking — a **thin** Ledger, which is the honest
result when the enforced invariants really did carry the region. N6 aligned the
three stratum packs' layers with their ordinals with zero strain; N8 made
no-confabulation a one-line declaration. The two substantive gaps are about a
memory store specifically: **HIPPO-1** (a growing store is not the plain list the
contract wants — the reason this region was chosen, and a second sighting of N9)
and **HIPPO-2** (consolidation over time has no scheduled construct). **HIPPO-3**
is the familiar cross-stratal seam recurring. These stay open and honestly
recorded; they are the product of the program, not defects to hide.
