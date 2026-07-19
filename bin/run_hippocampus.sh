#!/usr/bin/env bash
# run_hippocampus.sh — exercise the episodic-memory region and prove no-confabulation.
#
# Assembles the SWI-Prolog library path over the region's packs plus the PrologAI
# packs reused UNMODIFIED (lattice = the stigmergy + await/notify substrate; actors
# = the cyclic_actor thread; causal_core + the signing harness = the grounding
# engine the stratum packs load; membership_contract = the N8 construct the region's
# recall DECLARES). Exit 0 ONLY if every recall was a member of the stored set or an
# explicit no-recall, and the adversarial phantom was refused by the contract.
set -u
# Resolve the region repository root from this script's location.
cd "$(dirname "$0")/.." || exit 2
# Resolve the PrologAI checkout (honour PROLOGAI_HOME, else the local default).
PROLOGAI_HOME="${PROLOGAI_HOME:-/home/ccaitwo/PrologAI}"
# Confirm the PrologAI checkout exists before building the library path.
if [ ! -d "$PROLOGAI_HOME/packs/lattice/prolog" ]; then
  echo "run_hippocampus.sh: cannot find PrologAI at $PROLOGAI_HOME (set PROLOGAI_HOME)" >&2
  exit 2
fi
# Confirm the N8 membership_contract construct the region rests on is reachable — a missing gate is a failed build.
if [ ! -f "$PROLOGAI_HOME/packs/membership_contract/prolog/membership_contract.pl" ]; then
  echo "run_hippocampus.sh: cannot find PrologAI's library(membership_contract) (N8) at $PROLOGAI_HOME — the region must rest on it (set PROLOGAI_HOME)" >&2
  exit 2
fi
# Start the library path with every region pack's prolog directory.
LIB=""
for d in packs/*/prolog; do LIB="$LIB -p library=$d"; done
# Add the reused PrologAI packs: the Lattice, the actors, and the N8 membership contract.
LIB="$LIB -p library=$PROLOGAI_HOME/packs/lattice/prolog"
LIB="$LIB -p library=$PROLOGAI_HOME/packs/actors/prolog"
LIB="$LIB -p library=$PROLOGAI_HOME/packs/membership_contract/prolog"
# Add the grounding engine and signing harness (the stratum packs co-locate structure with runtime).
LIB="$LIB -p library=$PROLOGAI_HOME/packs/causal_core/prolog"
LIB="$LIB -p library=$PROLOGAI_HOME/tests/causalontology_conformance"
# Run the driver; its initialization goal runs the recalls and halts with the verdict code.
swipl -q $LIB bin/run_hippocampus.pl
# Propagate the driver's exit code (0 = no-confabulation held on every recall).
exit $?
