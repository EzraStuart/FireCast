# Wildfire Forecasting: project plan

Rebuilt 2026-11-08 (grill session). The previous plan (C++ first, California fire, Cambridge work sample) is archived in `docs/archive/longTermPlan-2026-10-28.md`; its numerical conventions and references still apply where not overridden here.

Probabilistic wildfire spread and risk modelling around a verified level-set fire-spread solver. Part-time personal project by Ezra: **~5 h/week**, plus the **leave week of 23 Nov 2026 (20–30 h)**.

## Why this project exists
- The main computational evidence for my **Imperial MSc Applied Mathematics (SCML) application, part-time, Round 2, 6 Jan 2027**. No work sample is required; the statement cites results (v1 by 30 Nov, final by 15 Dec).
- The story is **rigour and application**, matching the course's 50/50 coursework/exam modules: numerical and geometric analysis I prove myself, each confirmed by a numerical experiment, then applied to a **real UK fire**.
- I enjoy the numerical and geometric analysis most; protect it.
- Gaps it closes: no numerical-analysis or PDE modules on my transcript.

## Phase 1 definition of done (MATLAB, by 20 Dec)
**Language:** MATLAB for everything in phase 1 (my strongest; Imperial's Computational PDEs accepts MATLAB). C++ port after January (see Later).

### Theory, each paired with a test (core)
| # | Result | Paired experiment | Est. |
|---|---|---|---|
| T1 | Why markers fail: swallowtails / entropy condition (Sethian ch. 2) | The existing marker tracker (`Fire.m`) tangling: one figure | 3 h |
| T2 | Stability of first-order upwind: von Neumann → C ≤ 1, then the per-component CFL | Run at C = 0.9 vs 1.1: stable vs blow-up | 4 h |
| T3 | Observed order of accuracy (Roy 2005); why kinks drop L∞ below order 1 but not L1 | Circle + ellipse convergence tables | 2 h |
| T4 | Monotone schemes converge to the viscosity solution (Crandall–Lions, O(√Δx)); the scheme is monotone under CFL | Two merging circles: the correct (entropy) front vs the markers | 5 h |
| T5 | Is H(∇φ) = F(n)\|∇φ\| convex for the ellipse speed? Is per-component upwinding monotone for it? | Ellipse test | 4 h (optional) |

Geometric thread for the write-up: front normal n = ∇φ/|∇φ|, curvature κ = ∇·n, and the |∇φ| drift without reinitialisation. This is where differential geometry meets numerics.

### Verification
- [ ] **Circle test:** constant F, still air, φ₀ = |x − x₀| − r₀; exact φ = |x − x₀| − r₀ − Ft. 4 grids doubling, CFL fixed, last step shortened to land on T, L1/L∞ in a band around the front, observed order ≈ 1.
- [ ] **Ellipse test:** constant wind; initialise from the exact arrival-time solution φ = τ(x) − t₀ (never grow a circle); same 4 grids; the head runs downwind.
- [ ] **Smoke test:** wind from 270° → the fire heads east.

### Application: one real UK fire
- [ ] **Fire choice (by 22 Nov):** lead candidate **Saddleworth Moor 2018** (Copernicus EMS EMSR291: repeated burn-scar delineations). Initialise φ from one delineated perimeter, simulate to the next, and compare (Sørensen + overlay). Backups: Tintwistle Moor (EMSR897), Holt Heath 2022 (Sentinel-2 burn scar). Check: EMS vectors downloadable, delineation timestamps, peat/firefighting caveats.
- [ ] **Inputs:** DEM (OS Terrain 50 or Copernicus DEM), fuel = heather/moorland Rothermel fuel model (GA-calibrated Calluna model; iForest 2024 northern-European heathland models), weather = ERA5 (already downloaded; check the domain).
- [ ] **Spread rates:** a 1-hour spike before the leave week: a library (Pyretechnics custom fuel / R `Rothermel`) vs my own Rothermel in MATLAB (Andrews 2018, ~4–6 h). Decide on the spike result.
- [ ] At most one calibration knob (e.g. a wind multiplier), tuning capped at ~3 h, reported.
- **Fallback if no usable perimeter:** real UK terrain + heather fuel + ERA5 weather, showing plausible behaviour, **no validation score**, said plainly.

### Write-up (by 20 Dec)
Format TBD (decide by the end of the leave week). Default: a **technical report, ~8–12 pp**, so the proofs get room; LaTeX (Overleaf or `fire.tex`). Structure: geometry of fronts → scheme + stability → convergence/verification → UK application → limitations. 4–6 figures, each made by one script.

## Schedule (~50 h total)
| When | Hours | Do |
|---|---|---|
| 9–15 Nov | 5 | MATLAB level-set core (upwind, CFL, φ, n) + **circle test**; start T2 |
| 16–22 Nov | 5 | **Ellipse test**, T3; fire choice + EMS data check (1 h); spread-rate spike (1 h) |
| **23–29 Nov (leave)** | 25 | T1, T4; data pipeline (DEM, fuel map, ERA5 → grid); spread rates; **real-fire run + figures** |
| 30 Nov | – | Statement v1 cites the verification + first real-fire result |
| 1–20 Dec | 15 | **Write-up** (10 h), T5 if time, polish figures |

### Checkpoints
- **22 Nov:** if the circle test isn't passing with observed order ≈ 1, the leave week becomes verification + theory + the fallback (no real-fire validation). Never drop the theory–test pairs.
- **27 Nov:** if the real-fire run isn't working, use the fallback and write it up honestly.
- 5 h weeks can turn into 3 h: if a week slips, cut T5 first, then polish.

## Out of scope for phase 1
C++, OpenMP, scaling, ensembles and probabilistic scoring, ML, TensorStore/Zarr/TileDB, the viz viewer (spare time only, off the critical path), pybind11, WENO/high-order schemes, crown fire, peat/smouldering.

## Later (after 6 Jan 2027)
1. **C++ port** of the verified MATLAB solver (same tests via `ctest`, CMake), then OpenMP and an honest strong-scaling study (Hoefler & Belli). Learning C++ is a goal in itself.
2. **Ensemble + probabilistic scoring:** perturbed wind/moisture → burn-probability map, Brier skill score, reliability.
3. **ML emulator / Bayesian calibration** (old phase 2).
4. **Risk:** burn probability × exposure × damage → loss distributions (VaR/CVaR). The bridge to the climate-risk and compound-event interest (t-copulas) and to the employer, who is keen on wildfire work.
5. Public paper/repo when phase 1 is solid.

## How to work with me
- Solver and maths: teach, explain, review; I write the code and the proofs. Viz: generating code is fine.
- Small steps that end in something runnable; give rough time estimates; flag anything threatening the 30 Nov / 20 Dec dates.
- Point to sources (e.g. "Roy 2005 §2.3.2"). UK English.
- Keep a clear record of my code vs any library's.

## Numerical conventions (unchanged)
φ < 0 inside the burned area; front at φ = 0; n = ∇φ/|∇φ| (always normalise; no reinitialisation in phase 1). Advective form φ_t + U·∇φ = 0, U = F(n) n, upwinded per component. Elliptical normal speed with ignition at the rear focus: F = R/(1+e) · (e cos θ + √(1 − e² sin² θ)). Forward Euler; C = Δt · max(|U_x|/Δx + |U_y|/Δy) ≤ 1, recomputed every step. SI units; azimuths clockwise from grid north; wind direction = where it comes *from*. For UK data, use the British National Grid (EPSG:27700) as the grid, and convert ERA5 true-north winds to the grid frame.

## Key references
Rehm & McDermott, NIST TN 1611 (2009); Sethian, *Level Set Methods and Fast Marching Methods* (1999); Roy, J. Comput. Phys. (2005); Crandall & Lions (1984); Andrews, RMRS-GTR-371 (2018); Davies et al., GA-calibrated Rothermel fuel models for Calluna heathland; iForest 17:109–119 (2024), northern-European heathland fuel models; Copernicus EMS EMSR291 (Saddleworth Moor 2018).
