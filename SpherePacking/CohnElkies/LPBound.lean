import SpherePacking.CohnElkies.Prereqs

open scoped FourierTransform ENNReal
open SpherePacking Metric BigOperators Pointwise Filter MeasureTheory Complex Real Zspan

variable {d : ℕ} [Fact (0 < d)] -- Is `Fact` right here?

/-
# Potential Design Complications:

* What we have in Mathlib on Fourier Transforms seems to deal with complex-valued functions. I've
  dealt with it for now by giving an assumption that the imaginary part of `f` is always zero and
  stating everything else in terms of the real part of `f`. The real-valuedness may not even be
  necessary, as we could simply apply the Cohn-Elkies theorem to the real part of any complex-valued
  function whose real part satisfies the Cohn-Elkies Conditions `hCohnElkies₁` and `hCohnElkies₂`.
  If the hypothesis does go unused (as I expect it will), I will remove it.

# TODOs:

* The summations do not seem to be allowing a ≠ type condition on the index variable. We need this
  in order to be able to split sums up and deem one of the parts nonpositive or something.
* Everything in `Prereqs.lean` is either a TODO or has already been done (eg. in #25) (to reflect
  which the corresponding refs must be updated).
-/

variable {f : EuclideanSpace ℝ (Fin d) → ℂ} (hPSF : PSF_Conditions f)
variable (hReal : ∀ x : EuclideanSpace ℝ (Fin d), (f x).im = 0)
variable (hCohnElkies₁ : ∀ x : EuclideanSpace ℝ (Fin d), ‖x‖ ≥ 1 → (f x).re ≤ 0)
variable (hCohnElkies₂ : ∀ x : EuclideanSpace ℝ (Fin d), (𝓕 f x).re ≥ 0)

-- We (locally) denote the Complex Conjugate of some `z : ℂ` by `conj z`
-- Idea taken from https://github.com/leanprover-community/mathlib4/blob/75cc36e80cb9fe76f894b7688be1e0c792ae55d9/Mathlib/Analysis/Complex/UnitDisc/Basic.lean#L21
local notation "conj" => starRingEnd ℂ

section Basis

/-
In this section, we will prove that the density of every periodic sphere packing of separation 1 is
bounded above by the Cohn-Elkies bound.
-/

variable {P : PeriodicSpherePacking d} (hP : P.separation = 1) (b : Basis (Fin d) ℤ P.Λ)

private lemma calc_aux_1 :
  ∑' x : P.centers, ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)), (f (x - ↑y)).re
  ≤ ↑(P.numReps' b) * (f 0).re := sorry
  -- calc
  -- ∑' x : P.centers, ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)), (f (x - ↑y)).re
  -- _ = (∑' (x : P.centers) (y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)))
  --     (_ : (y : EuclideanSpace ℝ (Fin d)) ≠ ↑x),
  --     (f (x - ↑y)).re) +
  --     (∑' (x : P.centers) (y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)))
  --     (_ : (y : EuclideanSpace ℝ (Fin d)) = ↑x),
  --     (f (x - ↑y)).re)
  --       := sorry
  -- _ ≤ (∑' (x : P.centers) (y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)))
  --     (_ : (y : EuclideanSpace ℝ (Fin d)) = ↑x),
  --     (f (x - ↑y)).re)
  --       := sorry
  --   _ = ∑' (y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _))), (f (y - ↑y)).re
  --       := sorry
  --   _ = ↑(P.numReps' b) * (f 0).re
  --       := sorry

set_option maxHeartbeats 2000000
private lemma calc_steps :
  ↑(P.numReps' b) * (f 0).re ≥ ↑(P.numReps' b) ^ 2 * (𝓕 f 0).re /
  Zlattice.covolume P.Λ := calc
  ↑(P.numReps' b) * (f 0).re
  _ ≥ ∑' x : P.centers,
      ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      (f (x - ↑y)).re
        := by
            rw [ge_iff_le]
            exact calc_aux_1 b
  _ = ∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      ∑' ℓ : P.Λ, (f (↑x - ↑y + ↑ℓ)).re
        :=  by sorry
  -- We now take the real part out so we can apply the PSF-L to the stuff inside.
  -- The idea would be to say, in subsequent lines, that "it suffices to show that the numbers
  -- whose real parts we're taking are equal as complex numbers" and then apply the PSF-L and
  -- other complex-valued stuff.
  _ = (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      ∑' ℓ : P.Λ, f (↑x - ↑y + ↑ℓ)).re
        := by sorry
  _ = (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)), (1 / Zlattice.covolume P.Λ) *
      ∑' m : DualLattice P.Λ, (𝓕 f m) *
      cexp (2 * π * I * ⟪↑x - ↑y, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ)).re
        := by
            -- First, we apply the fact that two sides are equal if they're equal in ℂ.
            apply congrArg re
            -- Next, we apply the fact that two sums are equal if their summands are.
            apply congrArg _ _
            ext x
            apply congrArg _ _
            ext y
            -- Now that we've isolated the innermost sum, we can use the PSF-L.
            exact PSF_L P.Λ hPSF (x - ↑y)
  _ = ((1 / Zlattice.covolume P.Λ) * ∑' m : DualLattice P.Λ, (𝓕 f m).re * (
      ∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      cexp (2 * π * I * ⟪↑x - ↑y, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ))).re
        := by
            apply congrArg re
            sorry
  _ = ((1 / Zlattice.covolume P.Λ) * ∑' m : DualLattice P.Λ, (𝓕 f m).re * (
      ∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      ∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      cexp (2 * π * I * ⟪↑x, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ) *
      cexp (2 * π * I * ⟪-↑y, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ))).re
        := by
            -- As before, we have to go through a bunch of `congrArg`s to isolate the expressions we
            -- are really trying to show are equal.
            apply congrArg re
            apply congrArg _ _
            apply congrArg _ _
            ext m
            apply congrArg _ _
            apply congrArg _ _
            ext x
            apply congrArg _ _
            ext y

            sorry
  _ = ((1 / Zlattice.covolume P.Λ) * ∑' m : DualLattice P.Λ, (𝓕 f m).re *
      (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      cexp (2 * π * I * ⟪↑x, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ)) *
      (∑' y : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      cexp (-(2 * π * I * ⟪↑y, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ)))).re
        := by sorry
  _ = ((1 / Zlattice.covolume P.Λ) * ∑' m : DualLattice P.Λ, (𝓕 f m).re *
      (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      cexp (2 * π * I * ⟪↑x, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ)) *
      conj (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      cexp (2 * π * I * ⟪↑x, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ)) -- Need its complex conjugate
      ).re
        := by sorry
  _ = (1 / Zlattice.covolume P.Λ) * ∑' m : DualLattice P.Λ, (𝓕 f m).re *
      (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      Complex.abs (cexp (2 * π * I * ⟪↑x, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ)) ^ 2)
        := by sorry
  _ = (1 / Zlattice.covolume P.Λ) * (
      (∑' (m : DualLattice P.Λ) , (𝓕 f m).re * -- Need to add a `(hm : m ≠ 0)` into the sum
      (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      Complex.abs (cexp (2 * π * I * ⟪↑x, (m : EuclideanSpace ℝ (Fin d))⟫_ℝ)) ^ 2))
      +
      (𝓕 f (0 : EuclideanSpace ℝ (Fin d))).re *
      (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      Complex.abs (cexp (2 * π * I * ⟪↑x, (0 : EuclideanSpace ℝ (Fin d))⟫_ℝ)) ^ 2))
        := by sorry
  _ ≥ (1 / Zlattice.covolume P.Λ) * (𝓕 f (0 : EuclideanSpace ℝ (Fin d))).re *
      (∑' x : ↑(P.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)),
      Complex.abs (cexp (2 * π * I * ⟪↑x, (0 : EuclideanSpace ℝ (Fin d))⟫_ℝ)) ^ 2)
        := sorry
  _ = (1 / Zlattice.covolume P.Λ) * (𝓕 f (0 : EuclideanSpace ℝ (Fin d))).re *
      ↑(P.numReps' b) ^ 2
        := by sorry
  _ = ↑(P.numReps' b) ^ 2 * (𝓕 f 0).re /
  Zlattice.covolume P.Λ volume
        := by sorry

theorem LinearProgrammingBound' : P.density ≤
  (f 0).re / (𝓕 f 0).re * volume (ball (0 : EuclideanSpace ℝ (Fin d)) (1 / 2)) := by
  rw [P.periodic_density_formula' b]
  suffices hCalc : (P.numReps' b) * (f 0).re ≥ (P.numReps' b)^2 * (𝓕 f 0).re / Zlattice.covolume P.Λ
  · rw [hP]
    rw [ge_iff_le] at hCalc
    cases eq_or_ne (𝓕 f 0) 0
    · case inl h𝓕f =>
      rw [h𝓕f]
      -- simp only [zero_re, div_zero]
      -- Why does `div_zero` replace the value with `0` instead of `⊤`? I'd like `⊤`!
      have h : ∀ a : ENNReal, a / 0 = ⊤ := by
        
        sorry
      sorry
    · case inr h𝓕f =>
      sorry
  exact calc_steps hPSF b

end Basis

section Basis_Independent

theorem LinearProgrammingBound : SpherePackingConstant d ≤
  (f 0).re / (𝓕 f 0).re * volume (ball (0 : EuclideanSpace ℝ (Fin d)) (1 / 2)) := by
  rw [← periodic_constant_eq_constant (Fact.out),
    periodic_constant_eq_periodic_constant_normalized (Fact.out)]
  apply iSup_le
  intro P
  rw [iSup_le_iff]
  intro hP
  -- We choose a ℤ-basis for the lattice and feed it into `LinearProgramingBound'`.
  exact LinearProgrammingBound' hPSF hP (((Zlattice.module_free ℝ P.Λ).chooseBasis).reindex
    (PeriodicSpherePacking.basis_index_equiv P))

end Basis_Independent
