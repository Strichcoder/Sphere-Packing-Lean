import Mathlib.Algebra.Field.Power
import Mathlib.Algebra.Group.Subgroup.Pointwise
import Mathlib.Analysis.Complex.LocallyUniformLimit
import Mathlib.Analysis.Complex.UpperHalfPlane.Basic
import Mathlib.Analysis.Complex.UpperHalfPlane.FunctionsBoundedAtInfty
import Mathlib.Analysis.Complex.UpperHalfPlane.Manifold
import Mathlib.Geometry.Manifold.MFDeriv.FDeriv
import Mathlib.Geometry.Manifold.SmoothManifoldWithCorners
import Mathlib.NumberTheory.ModularForms.Basic
import Mathlib.NumberTheory.ModularForms.CongruenceSubgroups
import Mathlib.NumberTheory.ModularForms.JacobiTheta.OneVariable
import Mathlib.NumberTheory.ModularForms.JacobiTheta.TwoVariable
import Mathlib.NumberTheory.ModularForms.SlashInvariantForms

import SpherePacking.ForMathlib.FunctionsBoundedAtInfty
import SpherePacking.ForMathlib.SlashActions
import SpherePacking.ForMathlib.UpperHalfPlane
import SpherePacking.ModularForms.SlashActionAuxil

/-!
# Jacobi theta functions

Define Jacobi theta functions Θ₂, Θ₃, Θ₄ and their fourth powers H₂, H₃, H₄.
Prove that H₂, H₃, H₄ are modualar forms of weight 2 and level Γ(2).
Also Jacobi identity: Θ₂^4 + Θ₄^4 = Θ₃^4.
-/

open UpperHalfPlane hiding I
open Complex Real Asymptotics Filter Topology Manifold SlashInvariantForm Matrix ModularGroup
  ModularForm MatrixGroups SlashAction

local notation "GL(" n ", " R ")" "⁺" => Matrix.GLPos (Fin n) R
local notation "Γ " n:100 => CongruenceSubgroup.Gamma n

/-- Define Θ₂, Θ₃, Θ₄ as series. -/
noncomputable def Θ₂ (τ : ℍ) : ℂ := ∑' n : ℤ, cexp (π * I * (n + 1 / 2 : ℂ) ^ 2 * τ)
noncomputable def Θ₃ (τ : ℍ) : ℂ := ∑' n : ℤ, cexp (π * I * (n : ℂ) ^ 2 * τ)
noncomputable def Θ₄ (τ : ℍ) : ℂ := ∑' n : ℤ, (-1) ^ n * cexp (π * I * (n : ℂ) ^ 2 * τ)
noncomputable def H₂ (τ : ℍ) : ℂ := (Θ₂ τ) ^ 4
noncomputable def H₃ (τ : ℍ) : ℂ := (Θ₃ τ) ^ 4
noncomputable def H₄ (τ : ℍ) : ℂ := (Θ₄ τ) ^ 4

/-- Theta functions as specializations of jacobiTheta₂ -/
theorem Θ₂_as_jacobiTheta₂ (τ : ℍ) :
    Θ₂ τ = cexp (π * I * τ / 4) * jacobiTheta₂ (-τ / 2) τ := by
  simp_rw [Θ₂, jacobiTheta₂, jacobiTheta₂_term, ← smul_eq_mul (a := cexp _)]
  rw [← (Equiv.subRight 1).tsum_eq, ← tsum_const_smul]
  · simp_rw [Equiv.subRight_apply]
    apply tsum_congr
    intro b
    have : ((b - 1 : ℤ) : ℂ) + 1 / 2 = b - 1 / 2 := by
      push_cast
      nth_rw 1 [← add_halves 1]
      ring_nf
    rw [this, smul_eq_mul, ← Complex.exp_add]
    ring_nf
  · exact (summable_jacobiTheta₂_term_iff _ _).mpr τ.prop

theorem Θ₃_as_jacobiTheta₂ (τ : ℍ) : Θ₃ τ = jacobiTheta₂ (0 : ℂ) τ := by
  simp_rw [Θ₃, jacobiTheta₂, jacobiTheta₂_term, mul_zero, zero_add]

theorem Θ₄_as_jacobiTheta₂ (τ : ℍ) : Θ₄ τ = jacobiTheta₂ (1 / 2 : ℂ) τ := by
  simp_rw [Θ₄, jacobiTheta₂, jacobiTheta₂_term]
  apply tsum_congr
  intro b
  ring_nf
  rw [Complex.exp_add, ← exp_pi_mul_I, ← exp_int_mul, mul_comm (b : ℂ)]

section H_SlashInvariant

/-- Slash action of various elements on H₂, H₃, H₄ -/
lemma H₂_negI_action : (H₂ ∣[(2 : ℤ)] negI) = H₂ := modular_slash_negI_of_even H₂ (2: ℤ) even_two
lemma H₃_negI_action : (H₃ ∣[(2 : ℤ)] negI) = H₃ := modular_slash_negI_of_even H₃ (2: ℤ) even_two
lemma H₄_negI_action : (H₄ ∣[(2 : ℤ)] negI) = H₄ := modular_slash_negI_of_even H₄ (2: ℤ) even_two

/-- These three transformation laws follow directly from tsum definition. -/
lemma H₂_T_action : (H₂ ∣[(2 : ℤ)] T) = -H₂ := by
  ext x
  suffices hΘ₂ : Θ₂ ((1 : ℝ) +ᵥ x) = cexp (π * I / 4) * Θ₂ x by
    simp_rw [modular_slash_T_apply, Pi.neg_apply, H₂, hΘ₂, mul_pow, ← Complex.exp_nat_mul,
      mul_comm ((4 : ℕ) : ℂ), Nat.cast_ofNat, div_mul_cancel₀ (b := (4 : ℂ)) _ (by simp),
      Complex.exp_pi_mul_I, neg_one_mul]
  calc
  _ = ∑' (n : ℤ), cexp (π * I * (n + 1 / 2) ^ 2 * ((1 : ℝ) +ᵥ x)) := by
    rw [Θ₂]
  _ = ∑' (n : ℤ), cexp (π * I / 4) * cexp (π * I * (n ^ 2 + n) + π * I * (n + 1 / 2) ^ 2 * x) := by
    apply tsum_congr fun b ↦ ?_
    rw [coe_vadd, ofReal_one]
    repeat rw [← Complex.exp_add]
    congr
    ring_nf
  _ = cexp (π * I / 4) * ∑' (n : ℤ), cexp (π * I * (n ^ 2 + n) + π * I * (n + 1 / 2) ^ 2 * x) := by
    conv_rhs => rw [← smul_eq_mul ℂ]
    simp_rw [← tsum_const_smul'', smul_eq_mul]
  _ = _ := by
    rw [Θ₂]
    congr 1
    apply tsum_congr fun b ↦ ?_
    have : Even (b ^ 2 + b) := by
      convert Int.even_mul_succ_self b using 1
      ring_nf
    norm_cast
    rw [Complex.exp_add]
    rw [mul_comm (π * I), Complex.exp_int_mul, Complex.exp_pi_mul_I, this.neg_one_zpow, one_mul]

lemma H₃_T_action : (H₃ ∣[(2 : ℤ)] T) = H₄ := by
  ext x
  rw [modular_slash_T_apply, H₃, H₄, Θ₃, Θ₄]
  congr 1
  apply tsum_congr fun b ↦ ?_
  rw [coe_vadd, ofReal_one, mul_add, Complex.exp_add, mul_one, mul_comm (π * I), ← Int.cast_pow,
    Complex.exp_int_mul, Complex.exp_pi_mul_I]
  congr 1
  rcases Int.even_or_odd b with (hb | hb)
  · rw [hb.neg_one_zpow, Even.neg_one_zpow]
    simp [sq, hb]
  · rw [hb.neg_one_zpow, Odd.neg_one_zpow]
    simp [sq, hb]

lemma H₄_T_action : (H₄ ∣[(2 : ℤ)] T) = H₃ := by
  -- H₄|T = H₃|T^2 = Θ₂(0, z + 2) = Θ₂(0, z) = H₃
  ext x
  simp_rw [← H₃_T_action, modular_slash_T_apply, H₃, Θ₃_as_jacobiTheta₂, coe_vadd, ← add_assoc]
  norm_num
  rw [add_comm, jacobiTheta₂_add_right]

lemma H₂_T_inv_action : (H₂ ∣[(2 : ℤ)] T⁻¹) = -H₂ := by
  nth_rw 1 [← neg_eq_iff_eq_neg.mpr H₂_T_action, neg_slash, ← slash_mul, mul_inv_cancel, slash_one]

lemma H₃_T_inv_action : (H₃ ∣[(2 : ℤ)] T⁻¹) = H₄ := by
  nth_rw 1 [← H₄_T_action, ← slash_mul, mul_inv_cancel, slash_one]

lemma H₄_T_inv_action : (H₄ ∣[(2 : ℤ)] T⁻¹) = H₃ := by
  nth_rw 1 [← H₃_T_action, ← slash_mul, mul_inv_cancel, slash_one]

/-- Use α = T * T -/
lemma H₂_α_action : (H₂ ∣[(2 : ℤ)] α) = H₂ := by
  simp [α_eq_T_sq, ← SL_slash, sq, slash_mul, H₂_T_action]

lemma H₃_α_action : (H₃ ∣[(2 : ℤ)] α) = H₃ := by
  simp [α_eq_T_sq, ← SL_slash, sq, slash_mul, H₃_T_action, H₄_T_action]

lemma H₄_α_action : (H₄ ∣[(2 : ℤ)] α) = H₄ := by
  simp [α_eq_T_sq, ← SL_slash, sq, slash_mul, H₃_T_action, H₄_T_action]

/-- Use jacobiTheta₂_functional_equation -/
lemma H₂_S_action : (H₂ ∣[(2 : ℤ)] S) = -H₄ := by
  ext ⟨x, hx⟩
  have hx' : x ≠ 0 := by simp [Complex.ext_iff, hx.ne.symm]
  calc
  _ = cexp (-π * I / x) * jacobiTheta₂ (1 / (2 * x)) (-1 / x) ^ 4 * x ^ (-2 : ℤ) := by
    rw [modular_slash_S_apply, H₂, Θ₂_as_jacobiTheta₂]
    simp [← neg_inv, mul_pow, ← Complex.exp_nat_mul]
    rw [mul_comm 4, div_mul_cancel₀ _ (by norm_num)]
    congr
    · rw [← div_eq_mul_inv, neg_div]; rfl
    · rw [← one_div, neg_div]; rfl
  _ = cexp (-π * I / x) * x ^ (-2 : ℤ)
        * (1 / (I / x) ^ ((1 : ℂ) / 2) * cexp (π * I / (4 * x)) * jacobiTheta₂ (-1 / 2) x) ^ 4 := by
    rw [mul_right_comm, jacobiTheta₂_functional_equation]
    congr 4
    · ring_nf
    · congr 1
      rw [neg_mul, one_div, neg_div, div_neg, neg_mul, neg_div, neg_neg]
      ring_nf
      simp [div_div, sq, ← mul_assoc, inv_mul_cancel_right₀ hx']
    · ring_nf; simp [hx']
    · ring_nf; simp [inv_inv]
  _ = cexp (-π * I / x) * x ^ (-2 : ℤ)
        * ((1 / (I / x) ^ ((1 : ℂ) / 2)) ^ 4 * cexp (π * I / (4 * x)) ^ 4
          * jacobiTheta₂ (-1 / 2) x ^ 4) := by
    simp [mul_pow]
  _ = cexp (-π * I / x) * x ^ (-2 : ℤ)
        * ((1 / (I / x) ^ (2 : ℂ)) * cexp (π * I / (4 * x)) ^ 4 * jacobiTheta₂ (1 / 2) x ^ 4) := by
    congr 3
    · simp only [div_pow, one_pow, ← cpow_mul_nat]
      ring_nf
    · rw [← jacobiTheta₂_add_left]
      norm_num
  _ = cexp (-π * I / x) * (x ^ (-2 : ℤ) * (-x ^ (2 : ℤ)))
        * cexp (π * I / (4 * x)) ^ 4 * jacobiTheta₂ (1 / 2) x ^ 4 := by
    repeat rw [← mul_assoc]
    congr 4
    rw [cpow_ofNat, div_pow, one_div_div, I_sq, div_neg, div_one]
    rfl
  _ = -cexp (-π * I / x) * cexp (π * I / x) * jacobiTheta₂ (1 / 2) x ^ 4 := by
    rw [mul_neg, ← zpow_add₀ hx', neg_add_cancel, mul_neg, zpow_zero, mul_one]
    congr 2
    rw [← Complex.exp_nat_mul]
    ring_nf
  _ = -jacobiTheta₂ (1 / 2) x ^ 4 := by
    rw [neg_mul, ← Complex.exp_add, neg_mul (π : ℂ), neg_div, neg_add_cancel, Complex.exp_zero,
      neg_one_mul]
  _ = -H₄ ⟨x, hx⟩ := by
    rw [H₄, Θ₄_as_jacobiTheta₂]
    rfl

lemma H₃_S_action : (H₃ ∣[(2 : ℤ)] S) = -H₃ := by
  ext x
  have hx' : (x : ℂ) ≠ 0 := by cases' x with x hx; change x ≠ 0; simp [Complex.ext_iff, hx.ne.symm]
  have := jacobiTheta₂_functional_equation 0
  simp [-one_div] at this
  simp [modular_slash_S_apply, Pi.neg_apply, H₃, Θ₃_as_jacobiTheta₂]
  rw [this, mul_pow, ← neg_inv, neg_div, div_neg, neg_neg, one_div (x : ℂ)⁻¹, inv_inv,
    mul_right_comm, ← neg_one_mul (_ ^ 4)]
  congr
  rw [div_pow, ← cpow_mul_nat, mul_neg, neg_neg]
  ring_nf!
  rw [← mul_inv, cpow_ofNat, sq, ← mul_assoc, zpow_two]
  ring_nf!
  rw [inv_pow, inv_I, even_two.neg_pow, I_sq, mul_neg_one, inv_inv, neg_mul, inv_mul_cancel₀]
  exact pow_ne_zero _ hx'

lemma H₄_S_action : (H₄ ∣[(2 : ℤ)] S) = - H₂ := by
  rw [← neg_eq_iff_eq_neg.mpr H₂_S_action, neg_slash, ← slash_mul, modular_S_sq,
    ModularForm.slash_neg' _ _ (by decide), slash_one]

lemma H₂_S_inv_action : (H₂ ∣[(2 : ℤ)] S⁻¹) = -H₄ := by
  rw [← neg_eq_iff_eq_neg.mpr H₄_S_action, neg_slash, ← slash_mul, mul_inv_cancel, slash_one]

lemma H₃_S_inv_action : (H₃ ∣[(2 : ℤ)] S⁻¹) = -H₃ := by
  nth_rw 1 [← neg_eq_iff_eq_neg.mpr H₃_S_action, neg_slash, ← slash_mul, mul_inv_cancel, slash_one]

lemma H₄_S_inv_action : (H₄ ∣[(2 : ℤ)] S⁻¹) = -H₂ := by
  rw [← neg_eq_iff_eq_neg.mpr H₂_S_action, neg_slash, ← slash_mul, mul_inv_cancel, slash_one]

/-- Use β = -S * α^(-1) * S -/
lemma H₂_β_action : (H₂ ∣[(2 : ℤ)] β) = H₂ := calc
  _ = (((H₂ ∣[(2 : ℤ)] negI) ∣[(2 : ℤ)] S) ∣[(2 : ℤ)] α⁻¹) ∣[(2 : ℤ)] S := by
    simp [β_eq_negI_mul_S_mul_α_inv_mul_S, ← SL_slash, slash_mul]
  _ = _ := by
    rw [H₂_negI_action, H₂_S_action, neg_slash, neg_slash, α_eq_T_sq, subgroup_slash]
    simp [← SL_slash, sq, slash_mul, H₄_T_inv_action, H₃_T_inv_action, H₄_S_action]

lemma H₃_β_action : (H₃ ∣[(2 : ℤ)] β) = H₃ := calc
  _ = (((H₃ ∣[(2 : ℤ)] negI) ∣[(2 : ℤ)] S) ∣[(2 : ℤ)] α⁻¹) ∣[(2 : ℤ)] S := by
    simp [β_eq_negI_mul_S_mul_α_inv_mul_S, ← SL_slash, slash_mul]
  _ = _ := by
    rw [H₃_negI_action, H₃_S_action, neg_slash, neg_slash, α_eq_T_sq, subgroup_slash]
    simp [← SL_slash, sq, slash_mul, H₄_T_inv_action, H₃_T_inv_action, H₃_S_action]

lemma H₄_β_action : (H₄ ∣[(2 : ℤ)] β) = H₄ := calc
  _ = (((H₄ ∣[(2 : ℤ)] negI) ∣[(2 : ℤ)] S) ∣[(2 : ℤ)] α⁻¹) ∣[(2 : ℤ)] S := by
    simp [β_eq_negI_mul_S_mul_α_inv_mul_S, ← SL_slash, slash_mul]
  _ = _ := by
    rw [H₄_negI_action, H₄_S_action, neg_slash, neg_slash, α_eq_T_sq, subgroup_slash]
    simp [← SL_slash, sq, slash_mul, H₂_T_inv_action, H₂_S_action]

/-- H₂, H₃, H₄ are modular forms of weight 2 and level Γ(2) -/
noncomputable def H₂_SIF : SlashInvariantForm (Γ 2) 2 where
  toFun := H₂
  slash_action_eq' := slashaction_generators_Γ2 H₂ (2 : ℤ) H₂_α_action H₂_β_action H₂_negI_action

noncomputable def H₃_SIF : SlashInvariantForm (Γ 2) 2 where
  toFun := H₃
  slash_action_eq' := slashaction_generators_Γ2 H₃ (2 : ℤ) H₃_α_action H₃_β_action H₃_negI_action

noncomputable def H₄_SIF : SlashInvariantForm (Γ 2) 2 where
  toFun := H₄
  slash_action_eq' := slashaction_generators_Γ2 H₄ (2 : ℤ) H₄_α_action H₄_β_action H₄_negI_action

end H_SlashInvariant



section H_MDifferentiable

noncomputable def H₂_SIF_MDifferentiable : MDifferentiable 𝓘(ℂ) 𝓘(ℂ) H₂_SIF := by
  intro τ
  suffices h_diff : DifferentiableAt ℂ (↑ₕH₂) τ.val by
    have : (H₂ ∘ ↑ofComplex) ∘ UpperHalfPlane.coe = H₂_SIF := by
      ext x
      simp [H₂_SIF, ofComplex_apply]
    rw [← this]
    exact h_diff.mdifferentiableAt.comp τ τ.mdifferentiable_coe
  sorry

noncomputable def H₃_SIF_MDifferentiable : MDifferentiable 𝓘(ℂ) 𝓘(ℂ) H₃_SIF := by sorry

noncomputable def H₄_SIF_MDifferentiable : MDifferentiable 𝓘(ℂ) 𝓘(ℂ) H₄_SIF := by sorry

end H_MDifferentiable



section H_isBoundedAtImInfty

variable (γ : SL(2, ℤ))

theorem isBoundedAtImInfty_H₂ : IsBoundedAtImInfty H₂ := by
  sorry

theorem isBoundedAtImInfty_H₃ : IsBoundedAtImInfty H₃ := by
  sorry

theorem isBoundedAtImInfty_H₄ : IsBoundedAtImInfty H₄ := by
  sorry

theorem isBoundedAtImInfty_H_slash : IsBoundedAtImInfty (H₂ ∣[(2 : ℤ)] γ)
      ∧ IsBoundedAtImInfty (H₃ ∣[(2 : ℤ)] γ) ∧ IsBoundedAtImInfty (H₄ ∣[(2 : ℤ)] γ) := by
  apply Subgroup.closure_induction_left (s := {S, T, ↑negI})
      (p := fun γ _ ↦ IsBoundedAtImInfty (H₂ ∣[(2 : ℤ)] γ) ∧ IsBoundedAtImInfty (H₃ ∣[(2 : ℤ)] γ)
        ∧ IsBoundedAtImInfty (H₄ ∣[(2 : ℤ)] γ))
  · simp [isBoundedAtImInfty_H₂, isBoundedAtImInfty_H₃, isBoundedAtImInfty_H₄]
  · intro x hx y _ h
    simp_rw [slash_mul]
    rcases hx with (rfl | rfl | rfl | _)
    · simp_rw [H₂_S_action, H₃_S_action, H₄_S_action, neg_slash, isBoundedAtImInfty_neg_iff]
      use h.right.right, h.right.left, h.left
    · simp_rw [H₂_T_action, H₃_T_action, H₄_T_action, neg_slash, isBoundedAtImInfty_neg_iff]
      use h.left, h.right.right, h.right.left
    · simp_rw [SL_slash, ← subgroup_slash, H₂_negI_action, H₃_negI_action, H₄_negI_action]
      exact h
  · intro x hx y _ h
    simp_rw [slash_mul]
    rcases hx with (rfl | rfl | rfl | _)
    · simp_rw [H₂_S_inv_action, H₃_S_inv_action, H₄_S_inv_action, neg_slash,
        isBoundedAtImInfty_neg_iff]
      use h.right.right, h.right.left, h.left
    · simp_rw [H₂_T_inv_action, H₃_T_inv_action, H₄_T_inv_action, neg_slash,
        isBoundedAtImInfty_neg_iff]
      use h.left, h.right.right, h.right.left
    · simp_rw [← Subgroup.coe_inv, modular_negI_inv, SL_slash, ← subgroup_slash,
        modular_slash_negI_of_even _ 2 (by decide)]
      exact h
  · intro s hs
    simp_rw [Set.mem_setOf_eq, Set.mem_range] at hs
    obtain ⟨s, rfl⟩ := hs
    rw [Set.mem_iInter, SetLike.mem_coe]
    intro hs
    simp [top_le_iff.mp <| SL2Z_generate.symm ▸ (Subgroup.closure_le s).mpr hs]

theorem isBoundedAtImInfty_H₂_slash : IsBoundedAtImInfty (H₂ ∣[(2 : ℤ)] γ) :=
  (isBoundedAtImInfty_H_slash _).left

theorem isBoundedAtImInfty_H₃_slash : IsBoundedAtImInfty (H₃ ∣[(2 : ℤ)] γ) :=
  (isBoundedAtImInfty_H_slash _).right.left

theorem isBoundedAtImInfty_H₄_slash : IsBoundedAtImInfty (H₄ ∣[(2 : ℤ)] γ) :=
  (isBoundedAtImInfty_H_slash _).right.right

end H_isBoundedAtImInfty


noncomputable def H₂_MF : ModularForm (Γ 2) 2 := {
  H₂_SIF with
  holo' := H₂_SIF_MDifferentiable
  bdd_at_infty' := isBoundedAtImInfty_H₂_slash
}

noncomputable def H₃_MF : ModularForm (Γ 2) 2 := {
  H₃_SIF with
  holo' := H₃_SIF_MDifferentiable
  bdd_at_infty' := isBoundedAtImInfty_H₃_slash
}

noncomputable def H₄_MF : ModularForm (Γ 2) 2 := {
  H₄_SIF with
  holo' := H₄_SIF_MDifferentiable
  bdd_at_infty' := isBoundedAtImInfty_H₄_slash
}

/-- Jacobi identity -/
theorem jacobi_identity (τ : ℍ) : (Θ₂ τ) ^ 4 + (Θ₄ τ) ^ 4 = (Θ₃ τ) ^ 4 := by
  rw [← H₂, ← H₃, ← H₄]
  -- prove that the dimension of M₂(Γ(2)) is 2. Compare the first two q-coefficients.
  sorry
