/-
## THIS FILE SHOULD EVENTUALLY BE REMOVED AND THE REFERENCES IN COHN-ELKIES MUST BE REPLACED WITH
## THE RIGHT ONES (NOT THE ONES FROM HERE). THIS FILE IS JUST A TEMPORARY SOLUTION TO MAKE THE
## COHN-ELKIES FILE WORK.
-/
import Mathlib.Algebra.Module.Zlattice.Basic
import Mathlib.Algebra.Module.Zlattice.Covolume
import Mathlib.Analysis.Fourier.FourierTransform
import SpherePacking.Basic.SpherePacking

open BigOperators

variable {d : ℕ}
variable (Λ : AddSubgroup (EuclideanSpace ℝ (Fin d))) [DiscreteTopology Λ] [IsZlattice ℝ Λ]

noncomputable section Dual_Lattice

/-
This section defines the Dual Lattice of a Lattice. Taken from `SpherePacking/ForMathlib/Dual.lean`.
-/

def DualLattice : AddSubgroup (EuclideanSpace ℝ (Fin d)) where
  carrier := { x | ∀ l : Λ, ∃ n : ℤ, ⟪x, l⟫_ℝ = ↑n }
  zero_mem' := by
    simp only [Subtype.forall, Set.mem_setOf_eq, inner_zero_left]
    intro a _
    use 0
    rw [Int.cast_zero]
  add_mem' := by
    intros x y hx hy l
    obtain ⟨n, hn⟩ := hx l
    obtain ⟨m, hm⟩ := hy l
    use n + m
    simp only [inner_add_left, hn, hm, Int.cast_add]
  neg_mem' := by
    intros x hx l
    obtain ⟨n, hn⟩ := hx l
    use -n
    simp only [inner_neg_left, hn, Int.cast_neg]

end Dual_Lattice

open scoped FourierTransform

open Complex Real

noncomputable section PSF_L

/-
This section defines the Poisson Summation Formual, Lattice Version (`PSF_L`). This is a direct
dependency of the Cohn-Elkies proof.
-/

def PSF_Conditions (f : EuclideanSpace ℝ (Fin d) → ℂ) : Prop :=
  /-
    Mention here all the conditions we decide to impose functions on which to define the PSF-L.
    For example, this could be that they must be Schwartz (cf. blueprint) or admissible (cf. Cohn-
    Elkies). This is a placeholder for now, as is almost everything in this file.
  -/
  sorry

theorem PSF_L {f : EuclideanSpace ℝ (Fin d) → ℂ} (hf : PSF_Conditions f)
  (v : EuclideanSpace ℝ (Fin d)) :
  ∑' ℓ : Λ, f (ℓ + v) = (1 / Zlattice.covolume Λ) * ∑' m : DualLattice Λ, (𝓕 f m) *
  cexp (2 * π * I * ⟪v, m⟫_ℝ) :=
  sorry

-- The version below is on the blueprint. I'm pretty sure it can be removed.
theorem PSF_L' {f : EuclideanSpace ℝ (Fin d) → ℂ} (hf : PSF_Conditions f) :
  ∑' ℓ : Λ, f ℓ = (1 / Zlattice.covolume Λ) * ∑' m : DualLattice Λ, (𝓕 f m) := by
have := PSF_L Λ hf (0 : EuclideanSpace ℝ (Fin d))
simp only [add_zero, inner_zero_left, ofReal_zero, mul_zero, Complex.exp_zero, mul_one] at this
exact this

end PSF_L

open scoped ENNReal
open SpherePacking Metric BigOperators Pointwise Filter MeasureTheory Zspan

section Periodic_Packings

/-
This section consists of two results:
1. The formula for the density of a periodic packing
2. The periodic sphere packing constant is the supremum over packings of separation radius 1
These can be moved to the file `SpherePacking/Basic/PeriodicPacking.lean` being worked on in #25 or
to the file `SpherePacking/Basic/SpherePacking.lean`.
-/

theorem periodic_constant_eq_periodic_constant_normalized (hd : 0 < d) :
    PeriodicSpherePackingConstant d = ⨆ (S : PeriodicSpherePacking d) (_ : S.separation = 1),
    S.density := by
  -- Argument almost identical to `constant_eq_constant_normalized`, courtesy Gareth
  rw [iSup_subtype', PeriodicSpherePackingConstant]
  apply le_antisymm
  · apply iSup_le
    intro S
    have h := inv_mul_cancel S.separation_pos.ne.symm
    have := le_iSup (fun x : { x : PeriodicSpherePacking d // x.separation = 1 } ↦ x.val.density)
        ⟨S.scale (inv_pos.mpr S.separation_pos), h⟩
    rw [← scale_density hd]
    · exact this
    · rw [inv_pos]
      exact S.separation_pos
  · apply iSup_le
    intro ⟨S, _⟩
    simp only
    exact le_iSup_iff.mpr fun b a ↦ a S

-- Adapted from #25
-- Reason: Need specific set of representatives for proof of Cohn-Elkies. Choice doesn't matter,
-- so might as well choose a convenient one.

instance (S : PeriodicSpherePacking d) : Fintype (Quotient S.instAddAction.orbitRel) := sorry

noncomputable def PeriodicSpherePacking.numReps (S : PeriodicSpherePacking d) : ℕ :=
  Fintype.card (Quotient S.instAddAction.orbitRel)

instance (S : PeriodicSpherePacking d) : DiscreteTopology ↥S.Λ := S.Λ_discrete

instance (S : PeriodicSpherePacking d) : IsZlattice ℝ S.Λ := S.Λ_lattice

instance (S : PeriodicSpherePacking d) (b : Basis (Fin d) ℤ S.Λ) :
  Fintype ↑(S.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _)) := sorry

noncomputable def PeriodicSpherePacking.numReps'
  (S : PeriodicSpherePacking d) (b : Basis (Fin d) ℤ S.Λ) : ℕ :=
  Fintype.card ↑(S.centers ∩ fundamentalDomain (b.ofZlatticeBasis ℝ _))

-- I hope these aren't outright wrong
instance HDivENNReal : HDiv ENNReal ℝ ENNReal := sorry
instance HMulENNReal : HMul ℝ ENNReal ENNReal := sorry

@[simp]
theorem PeriodicSpherePacking.periodic_density_formula (S : PeriodicSpherePacking d) :
  S.density = (S.numReps : ENNReal) /
    (Zlattice.covolume S.Λ) * volume (ball (0 : EuclideanSpace ℝ (Fin d)) (S.separation / 2)) := by
  sorry

@[simp]
theorem PeriodicSpherePacking.periodic_density_formula'
  (S : PeriodicSpherePacking d) (b : Basis (Fin d) ℤ S.Λ) :
  S.density = (S.numReps' b : ENNReal) /
    (Zlattice.covolume S.Λ) * volume (ball (0 : EuclideanSpace ℝ (Fin d)) (S.separation / 2)) := by
  sorry

theorem periodic_constant_eq_constant (hd : 0 < d) :
    PeriodicSpherePackingConstant d = SpherePackingConstant d := by
  sorry

end Periodic_Packings

noncomputable section Misc

-- Vocab from #25: `Quotient S.addAction.orbitRel` is the set of _representatives_

variable {d : ℕ} (P : PeriodicSpherePacking d)
-- local notation "ℝᵈ" => EuclideanSpace ℝ (Fin d)

-- The following surely makes sense: subtracting a point in the fundamental domain from another
-- should yield a point in the ambient space. But why does this need to be mentioned explicitly?
instance HSubFundamentalDomain : HSub
  (Quotient (P.instAddAction.orbitRel))
  (Quotient (P.instAddAction.orbitRel))
  (EuclideanSpace ℝ (Fin d)) :=
  sorry

instance HSubInter (b : Basis (Fin d) ℤ P.Λ): HSub
  (↑(P.centers ∩ fundamentalDomain (Basis.ofZlatticeBasis ℝ P.Λ b)))
  (↑(P.centers ∩ fundamentalDomain (Basis.ofZlatticeBasis ℝ P.Λ b)))
  (EuclideanSpace ℝ (Fin d)) :=
  sorry

-- instance coe_quotient_to_ambient : Coe (Quotient (P.instAddAction.orbitRel))
--   (EuclideanSpace ℝ (Fin d)) := sorry

end Misc
