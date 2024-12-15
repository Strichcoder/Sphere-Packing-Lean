/-
The purpose of this file is to define the Eisenstein series we are interested in using more convenient notation.
-/

import Mathlib

-- import Mathlib.NumberTheory.ModularForms.EisensteinSeries.Defs

open ModularForm EisensteinSeries UpperHalfPlane TopologicalSpace Set MeasureTheory intervalIntegral
  Metric Filter Function Complex

open scoped Interval Real NNReal ENNReal Topology BigOperators Nat Classical

open ArithmeticFunction

local notation "SL(" n ", " R ")" => Matrix.SpecialLinearGroup (Fin n) R
noncomputable section Definitions

def standardcongruencecondition : Fin 2 → ZMod ((1 : ℕ+) : ℕ) := 0



-- private lemma aux4 : (3 : ℤ) ≤ 4 := by norm_num
-- private lemma aux6 : (3 : ℤ) ≤ 6 := by norm_num

/- The Eisenstein Series E₂, E₄ and E₆ -/

def E₄ : ModularForm (CongruenceSubgroup.Gamma ↑1) 4 :=
  (1/2) • eisensteinSeries_MF (by norm_num) standardcongruencecondition /-they need  1/2 for the
    normalization to match up (since the sum here is taken over coprime integers).-/
def E (k : ℤ) (hk : 3 ≤ k) : ModularForm (CongruenceSubgroup.Gamma ↑1) k :=
  (1/2) • eisensteinSeries_MF hk standardcongruencecondition /-they need  1/2 for the
    normalization to match up (since the sum here is taken over coprime integers).-/
def E₆ : ModularForm (CongruenceSubgroup.Gamma ↑1) 6 :=
  (1/2) • eisensteinSeries_MF (by norm_num) standardcongruencecondition

def S0 : Set ℤ := {0}ᶜ

def G₂' : ℍ → ℂ := fun z => ∑' (m : ℤ), (∑' (n : ℤ), 1 / (m * z + n) ^ 2) --hmm is this right?


def δ (a b : ℤ): ℂ := if a = 0 ∧ b = 0 then 1 else if a = 0 ∧ b = -1 then 2 else 0

@[simp]
lemma δ_eq : δ 0 0 = 1 := by simp [δ]

@[simp]
lemma δ_eq2 : δ 0 (-1) = 2 := by simp [δ]

lemma δ_neq (a b : ℤ) (h : a ≠ 0) : δ a b = 0 := by
  simp [δ, h]


instance natPosSMul : SMul ℕ+ ℍ where
  smul x z := UpperHalfPlane.mk (x * z) <| by simp; apply z.2



theorem natPosSMul_apply (c : ℕ+) (z : ℍ) : ((c  • z : ℍ) : ℂ) = (c : ℂ) * (z : ℂ) := by rfl

/--Maybe this is the definition we want as I cant see how to easily show the other outer sum is
absolutely convergent. -/
def G₂ : ℍ → ℂ := fun z =>  limUnder (atTop)
    (fun N : ℕ => ∑ m in Finset.Ico (-N : ℤ) N, (∑' (n : ℤ), (1 / ((m : ℂ) * z + n) ^ 2)))

/-This should follow from the mod forms repo stuff. Will port soon. -/
lemma G₂_eq (z : UpperHalfPlane) : G₂ z = (2 * riemannZeta 2) -
    8 * π ^ 2 * ∑' (n : ℕ+), (sigma 1 n) * cexp (2 * π * Complex.I * n * z) := sorry

/-This is from the modforms repo, so no need to prove it. -/
theorem q_exp_iden (k : ℕ) (hk : 2 ≤ k) (z : ℍ) :
    ∑' d : ℤ, 1 / ((z : ℂ) + d) ^ k =
      (-2 * ↑π * Complex.I) ^ k / (k - 1)! *
      ∑' n : ℕ+, n ^ ((k - 1) ) * Complex.exp (2 * ↑π * Complex.I * z * n) := sorry

lemma t4  (z : ℍ) (k : ℕ) (hk : 2 ≤ k):
    ∑' c : ℕ+, ∑' d : ℤ, 1 / (((c • z : ℍ) : ℂ) + d) ^ k =
      ∑' e : ℕ+,
        (-2 * ↑π * Complex.I) ^ k / (k - 1)! *
        ∑' n : ℕ+, n ^ (k - 1) * Complex.exp (2 * ↑π * Complex.I * e * z * n) := by
      congr
      funext c
      rw [ q_exp_iden k hk (c • z : ℍ), natPosSMul_apply c z, ← mul_assoc]

lemma t6 (z : ℍ) (f : ℤ → ℂ) :
  (fun N : ℕ => ∑ m in Finset.Ico (-N : ℤ) N, f m) =
  (fun N : ℕ => ∑ m in Finset.Ico (-N : ℤ) 0, f m) +
  (fun N : ℕ => ∑ m in Finset.Ico (0 : ℤ) N, f m) := by
  ext N
  simp

  sorry

lemma finsetaux1 (f : ℤ → ℂ) (N : ℕ) : ∑ m in Finset.Ico (-N : ℤ) N, f m =
  ∑ m in Finset.range (N + 1), (f (-m)) + ∑ m in Finset.range N , f m - f 0 := by sorry

def negEquiv : ℤ ≃ ℤ where
  toFun n := -n
  invFun n := -n
  left_inv := by apply neg_neg
  right_inv := by apply neg_neg

theorem int_sum_neg {α : Type*} [AddCommMonoid α] [TopologicalSpace α] [T2Space α] (f : ℤ → α) :
  ∑' d : ℤ, f d = ∑' d, f (-d) :=
  by
  have h : (fun d => f (-d)) = (fun d => f d) ∘ negEquiv.toFun :=
    by
    funext
    simp
    rfl
  rw [h]
  apply symm
  apply negEquiv.tsum_eq

lemma t7 (z : ℍ) (N : ℕ) :
  (∑ m in Finset.Ico (-N : ℤ) 0, (∑' (n : ℤ), (1 / ((m : ℂ) * z + n) ^ 2))) =
   ∑ m in Finset.Ico (-N : ℤ) 0, (-2 * ↑π * Complex.I) ^ 2 / (2 - 1)! *
      ∑' n : ℕ+, n ^ ((2 - 1) ) * Complex.exp (2 * ↑π * Complex.I * -m * z * n) := by
  apply Finset.sum_congr  rfl
  intro m hm
  simp at hm
  have hm : 0 ≤ -m := by linarith
  have hm0 : 0 < -m := by linarith
  set M := (-m).toNat
  have hM : 0 < M := by simp [M, hm0]
  set mm : ℕ+ := ⟨M, hM⟩
  have hmm : (mm : ℂ) = - (m : ℂ) := by
    simp [mm, M]
    have := Int.toNat_of_nonneg hm
    norm_cast
  have := q_exp_iden 2 (by norm_num) (mm • z)
  rw [natPosSMul_apply mm z] at this
  rw [hmm] at this
  simp at *
  conv at this =>
    enter [2,2,1]
    ext n
    rw [← mul_assoc]
  rw [← this]
  nth_rw 1 [int_sum_neg]
  congr
  funext m
  simp
  ring




lemma aux33 (f : ℕ → ℂ) (hf : Summable f) : ∑' n, f (n) =
    limUnder atTop (fun N : ℕ => ∑ n in Finset.range N, f (n)) := by
  rw [Filter.Tendsto.limUnder_eq]
  have  := hf.hasSum
  have V := this.comp tendsto_finset_range
  apply V


lemma aux34 (f : ℕ → ℂ) (hf : Summable f) : ∑' n, f (n + 1) =
    limUnder atTop (fun N : ℕ => ∑ n in Finset.range N, f (n + 1)) := by
    rw [aux33 ]
    rw [summable_nat_add_iff ]
    apply hf

/- this is being Pr'd-/
lemma tsum_pnat_eq_tsum_succ3 {α : Type*} [TopologicalSpace α] [AddCommMonoid α] [T2Space α]
  (f : ℕ → α) : ∑' (n : ℕ+), f ↑n = ∑' (n : ℕ), f (n + 1) := by sorry

lemma aux35 (f : ℕ → ℂ) (hf : Summable f) : ∑' n : ℕ+, f n =
  limUnder atTop (fun N : ℕ => ∑ n in Finset.range N, f (n + 1)) := by
  rw [← aux34 f hf]
  apply tsum_pnat_eq_tsum_succ3


def summable_term (z : ℍ) : ℤ → ℂ :=  (fun m : ℤ => (∑' (n : ℤ), (1 / ((m : ℂ) * z + n) ^ 2)))

lemma term_evem (z : ℍ) (m : ℤ) : summable_term z m = summable_term z (-m) := by
  simp [summable_term]
  nth_rw 1 [int_sum_neg]
  congr
  funext m
  simp
  ring

lemma Icc_succ (n : ℕ) : Finset.Icc (-(n + 1) : ℤ) (n + 1) = Finset.Icc (-n : ℤ) n ∪
  {(-(n+1) : ℤ), (n + 1 : ℤ)} := by
  refine Finset.ext_iff.mpr ?_
  intro a
  simp
  omega



lemma Icc_sum_even (f : ℤ → ℂ) (hf : ∀ n, f n = f (-n)) (N : ℕ):
    ∑ m in Finset.Icc (-N : ℤ) N, f m =  2 * ∑ m in Finset.range (N + 1), f m  - f 0 := by
  induction' N with N ih
  simp
  ring
  have := Icc_succ N
  simp only [neg_add_rev, Int.reduceNeg,  Nat.cast_add, Nat.cast_one] at *
  rw [this]
  rw [Finset.sum_union]
  rw [Finset.sum_pair]
  rw [ih]
  nth_rw 2 [Finset.sum_range_succ]
  have HF:= hf (N + 1)
  simp at HF
  rw [← HF]
  ring_nf
  norm_cast
  omega
  simp

lemma zeta_two_eqn : ∑' (n : ℤ), ((n : ℂ) ^ 2)⁻¹ = 2 * riemannZeta 2 := by
  have := tsum_nat_add_neg (f := fun n => 1/((n : ℂ) ^ 2)) ?_
  simp at this
  rw [← this]
  have hr := zeta_nat_eq_tsum_of_gt_one (k := 2)
  simp at hr
  rw [hr]
  rw [tsum_add]
  ring
  repeat{
  have := Complex.summable_one_div_nat_cpow  (p := 2)
  simp at this
  exact this}
  simp
  have := Complex.summable_one_div_nat_cpow  (p := 2)
  simp at *
  norm_cast at *
  apply  Summable.of_nat_of_neg_add_one
  apply this

  sorry

lemma sum_range_zero (f : ℤ → ℂ) (n : ℕ) : ∑ m in Finset.range (n+1), f m = f 0 +
  ∑ m in Finset.range n, f (m+1) := by
  rw [Finset.sum_range_succ' ]
  rw [add_comm]
  simp

lemma auxer (a c : ℂ) : a + 2*2*c - 2*c =a + 2*c := by ring

lemma t8 (z : ℍ) :
  (fun N : ℕ => ∑ m in Finset.Icc (-N : ℤ) N, (∑' (n : ℤ), (1 / ((m : ℂ) * z + n) ^ 2))) =
  (fun _ : ℕ => 2*((riemannZeta 2))) + (fun N : ℕ => ∑ m in Finset.range (N), 2 * (-2 * ↑π * Complex.I) ^ 2 / (2 - 1)! *
      ∑' n : ℕ+, n ^ ((2 - 1) ) * Complex.exp (2 * ↑π * Complex.I * (m + 1) * z * n)) := by
  funext m
  simp only [one_div, neg_mul, even_two, Even.neg_pow, Nat.add_one_sub_one, Nat.factorial_one,
    Nat.cast_one, div_one, pow_one, Pi.add_apply]
  rw [Icc_sum_even]
  simp only [Int.cast_natCast, Int.cast_zero, zero_mul, zero_add]
  rw [ zeta_two_eqn]
  nth_rw 2 [add_comm]
  have := sum_range_zero (fun m =>  (∑' (n : ℤ), (1 / ((m : ℂ) * z + n) ^ 2))) m
  simp only [Int.cast_natCast, one_div, Int.cast_zero, zero_mul, zero_add, Int.cast_add,
    Int.cast_one] at this
  rw [this, zeta_two_eqn, add_comm, mul_add, ← mul_assoc, auxer]
  congr
  rw [@Finset.mul_sum]
  congr
  ext d
  let Z : ℍ := ⟨(d +1)* z, by simp; apply mul_pos; linarith; exact z.2⟩
  have := q_exp_iden 2 (by norm_num) (z := Z)
  simp only [coe_mk_subtype, one_div, neg_mul, even_two, Even.neg_pow, Nat.add_one_sub_one,
    Nat.factorial_one, Nat.cast_one, div_one, pow_one, Z] at *
  rw [this]
  ring_nf
  congr
  ext r
  congr
  ring
  · intro n
    have := term_evem z n
    simp [summable_term] at *
    exact this


/-This is straight from the mod forms repo-/
theorem tsum_sigma_eqn {k : ℕ} (z : ℍ) :
    ∑' c : ℕ+ × ℕ+, (c.1 ^ k : ℂ) * Complex.exp (2 * ↑π * Complex.I * z * c.1 * c.2) =
      ∑' e : ℕ+, sigma k e * Complex.exp (2 * ↑π * Complex.I * e * z) := by sorry

/-This is straight from the mod forms repo-/
theorem a1 (k : ℕ) (e : ℕ+) (z : ℍ) :
    Summable fun c : ℕ+ => (e : ℂ) ^ (k - 1) * exp (2 * ↑π * Complex.I * ↑z * e * c) := by sorry
/-This is straight from the mod forms repo-/
theorem a4 (k : ℕ) (z : ℍ) :
    Summable (uncurry fun b c : ℕ+ => ↑b ^ (k - 1) * exp (2 * ↑π * Complex.I * ↑c * ↑z * ↑b)) := by sorry

lemma t9 (z : ℍ) : ∑' m : ℕ,
  ( 2 * (-2 * ↑π * Complex.I) ^ 2 / (2 - 1)! *
      ∑' n : ℕ+, n ^ ((2 - 1) ) * Complex.exp (2 * ↑π * Complex.I * (m + 1) * z * n))  =  -
    8 * π ^ 2 * ∑' (n : ℕ+), (sigma 1 n) * cexp (2 * π * Complex.I * n * z) := by
  have := tsum_pnat_eq_tsum_succ3 (fun m => 2 * (-2 * ↑π * Complex.I) ^ 2 / (2 - 1)! *
      ∑' n : ℕ+, n ^ ((2 - 1) ) * Complex.exp (2 * ↑π * Complex.I * (m) * z * n))
  simp at *
  rw [← this]
  have := tsum_sigma_eqn z (k := 1)
  rw [tsum_mul_left]
  rw [← this]
  have he :  2 * (2 * ↑π * Complex.I) ^ 2 = - 8 * π ^ 2 := by sorry
  rw [he]
  simp
  left
  symm
  simp only [pow_one, neg_mul] at *
  rw [tsum_prod]
  rw [tsum_comm' ]
  congr
  funext m
  congr
  funext n
  simp
  congr 1
  ring
  have := a4 2 z

  sorry --these 3 are in the modforms repo
  sorry
  sorry
  have := a4 2 z
  apply this.congr
  intro b
  simp [uncurry]
  congr 1
  ring



lemma verga2 : Tendsto (fun N : ℕ => Finset.Icc (-N : ℤ) N) atTop atTop :=
  tendsto_atTop_finset_of_monotone (fun _ _ _ ↦ Finset.Icc_subset_Icc (by gcongr) (by gcongr)) (fun x ↦ ⟨x.natAbs, by simp [le_abs, neg_le]⟩)




lemma auxl (a b c d : ℂ): Complex.abs ((a + b) - (c +d)) ≤ Complex.abs (a - c) + Complex.abs (b - d) := by
  have : Complex.abs (a + b) ≤ Complex.abs a + Complex.abs b := by exact AbsoluteValue.add_le Complex.abs a b
  conv  =>
    enter [1,2]
    rw [show a + b - (c + d) = (a - c) + (b - d) by ring]
  apply  AbsoluteValue.add_le Complex.abs

lemma auxl2 (a b c : ℂ): Complex.abs (a - b) ≤ Complex.abs (a - b + c) + Complex.abs (c) := by
  nth_rw 1 [show a - b = (a - b + c) + -c by ring]
  have : Complex.abs (a - b + c + -c) ≤ Complex.abs (a - b+ c) + Complex.abs (-c) := by exact AbsoluteValue.add_le Complex.abs (a - b+ c) (-c)
  simpa using this

lemma trex (f : ℤ → ℂ) (N : ℕ) (hn : 1 ≤ N) : ∑ m in Finset.Icc (-N : ℤ) N, f m =
  f N + f (-N : ℤ)  + ∑ m in Finset.Icc (-(N - 1) : ℤ) (N-1), f m := by
  induction' N with N ih
  simp
  aesop
  zify
  rw [Icc_succ]
  rw [Finset.sum_union]
  ring_nf
  rw [add_assoc]
  congr
  rw [ Finset.sum_pair]
  ring
  omega
  simp

lemma cc(f : ℤ → ℂ) (hc :  CauchySeq fun N : ℕ => ∑ m in Finset.Icc (-N : ℤ) N, f m)
  (hs : ∀ n , f n = f (-n)) :
  Tendsto f atTop (𝓝 0) := by
  have h := cauchySeq_iff_tendsto_dist_atTop_0.mp hc
  simp_rw [cauchySeq_iff_le_tendsto_0] at *
  obtain ⟨g, hg, H, Hg⟩ := hc
  rw [Metric.tendsto_atTop] at *
  simp at *
  intro ε hε
  have hh := Hg (2 * ε) (by linarith)
  obtain ⟨N, hN⟩ := hh
  use N + 1
  intro n hn
  have H3 := H (n).natAbs (n -1).natAbs N ?_ ?_
  rw [trex f n.natAbs] at H3
  simp [dist_eq_norm] at *
  have h1 : |n| = n := by
    simp
    linarith
  simp_rw [h1] at H3
  have h2 : |n - 1| = n - 1 := by
    simp
    linarith
  simp_rw [h2] at H3
  simp at H3
  rw [← hs n] at H3
  rw [show f n + f n = 2 * f n by ring] at H3
  simp at H3
  have HN := hN N (by rfl)
  have hgn : g N ≤ |g N| := by
    exact le_abs_self (g N)
  have := le_trans H3 hgn
  have hgnn : 2 * Complex.abs (f n) < 2 * ε := by
    apply lt_of_le_of_lt
    exact this
    exact HN
  nlinarith
  omega
  omega
  omega


lemma sum_Icc_eq_sum_Ico_succ {α : Type*} [AddCommMonoid α] (f : ℤ → α)
    {l u : ℤ} (h : l ≤ u) :
    ∑ m in Finset.Icc l u, f m = (∑ m in Finset.Ico l u, f m) + f u := by
  rw [Finset.Icc_eq_cons_Ico h]
  simp
  rw [add_comm]


lemma CauchySeq_Icc_iff_CauchySeq_Ico (f : ℤ → ℂ) (hs : ∀ n , f n = f (-n))
  (hc : CauchySeq (fun N : ℕ => ∑ m in Finset.Icc (-N : ℤ) N, f m) ) :
  CauchySeq (fun N : ℕ => ∑ m in Finset.Ico (-N : ℤ) N, f m) := by
  have h0 := cc f hc hs
  have : CauchySeq fun n: ℕ => f n := by
    apply Filter.Tendsto.cauchySeq (x := 0)
    rw [Metric.tendsto_atTop] at *
    intro ε hε
    have hf3 := h0 ε hε
    obtain ⟨N, hN⟩ := hf3
    use N.natAbs
    simp at *
    intro n hn
    have hy := hN n
    apply hy
    omega

  have h1 := Filter.Tendsto.mul_const  2 h0
  have hff : Tendsto (fun n : ℕ => 2 * ‖f n‖) atTop (𝓝 0) := by
    rw [Metric.tendsto_atTop] at *
    simp [dist_eq_norm] at *
    intro ε hε
    have hf3 := h1 ε hε
    obtain ⟨N, hN⟩ := hf3
    use N.natAbs
    intro n hn
    have hy := hN n
    rw [mul_comm]
    apply hy
    omega
  simp_rw [cauchySeq_iff_le_tendsto_0] at *
  obtain ⟨b, hb, H, hbb⟩ := hc
  obtain ⟨a, ha, H2, haa⟩ := this
  refine ⟨b + a, ?_, ?_, ?_⟩

  · intro n
    simp
    apply add_nonneg
    exact hb n
    apply ha n

  ·

    intro n m N hn hm
    have H3 := H n m N hn hm
    simp [dist_eq_norm] at *
    rw [sum_Icc_eq_sum_Ico_succ _, sum_Icc_eq_sum_Ico_succ _] at H3
    have := auxl2 (∑ m ∈ Finset.Ico (-↑n) ↑n, f m) (∑ m ∈ Finset.Ico (-↑m) ↑m, f m) (f n - f m)
    apply le_trans this
    gcongr
    simp at *
    apply le_trans _ H3
    apply le_of_eq
    congr
    ring
    have H22 := H2 n m N hn hm
    exact H22

    omega
    omega
  ·
    have HG := Filter.Tendsto.add hbb haa
    simpa using HG

lemma G2_cauchy (z : ℍ) :
  CauchySeq  (fun N : ℕ => ∑ m in Finset.Icc (-N : ℤ) N, (∑' (n : ℤ), (1 / ((m : ℂ) * z + n) ^ 2))) := by
  rw [t8]
  simp
  apply CauchySeq.const_add
  apply Filter.Tendsto.cauchySeq (x :=  -
    8 * π ^ 2 * ∑' (n : ℕ+), (sigma 1 n) * cexp (2 * π * Complex.I * n * z))
  rw [← t9]
  have hf : Summable fun m : ℕ => ( 2 * (-2 * ↑π * Complex.I) ^ 2 / (2 - 1)! *
      ∑' n : ℕ+, n ^ ((2 - 1) ) * Complex.exp (2 * ↑π * Complex.I * (m + 1) * z * n)) := by sorry
  have := hf.hasSum
  have V := this.comp tendsto_finset_range
  simp at *
  apply V



lemma G₂_eq1 (z : ℍ) : G₂ z = 2 * riemannZeta 2 +
  ∑' (m : ℕ+), ∑' (n : ℤ), 1 / ((m : ℂ) * z + n) ^ 2 := by
  rw [G₂]
  rw [Filter.Tendsto.limUnder_eq]
  simp
  rw [@NormedAddCommGroup.tendsto_atTop]
  --is this true?
  sorry

lemma fsb (b : ℕ) : Finset.Ico (-(b+1) : ℤ) (b+1) = Finset.Ico (-(b : ℤ)) (b) ∪
    {-((b+1) : ℤ), (b : ℤ)} :=  by
  ext n
  simp
  omega

example (a b c d: ℂ ) : a + b - (c + d) = a - c + (b - d) := by
  exact add_sub_add_comm a b c d

theorem telescope_aux (z : ℍ) (m : ℤ) (b : ℕ) :
  ∑ n ∈ Finset.Ico (-b : ℤ) b, (1 / ((m : ℂ) * ↑z + ↑n) - 1 / (↑m * ↑z + ↑n + 1)) =
    1 / (↑m * ↑z - ↑b) - 1 / (↑m * ↑z + ↑b) := by
  induction' b  with b ihb
  aesop
  simp only [Nat.cast_add, Nat.cast_one, Int.reduceNeg, one_div,
      Finset.sum_sub_distrib] at *
  rw [fsb, Finset.sum_union, Finset.sum_union, Finset.sum_pair, Finset.sum_pair,add_sub_add_comm, ihb]
  simp only [neg_add_rev, Int.reduceNeg, Int.cast_add, Int.cast_neg, Int.cast_one, Int.cast_natCast]
  ring
  · omega
  · omega
  · simp only [neg_add_rev, Int.reduceNeg, Finset.disjoint_insert_right, Finset.mem_Ico,
    le_add_iff_nonneg_left, Left.nonneg_neg_iff, Int.reduceLE, add_neg_lt_iff_lt_add, false_and,
    not_false_eq_true, Finset.disjoint_singleton_right, neg_le_self_iff, Nat.cast_nonneg,
    lt_self_iff_false, and_false, and_self]
  · simp only [neg_add_rev, Int.reduceNeg, Finset.disjoint_insert_right, Finset.mem_Ico,
    le_add_iff_nonneg_left, Left.nonneg_neg_iff, Int.reduceLE, add_neg_lt_iff_lt_add, false_and,
    not_false_eq_true, Finset.disjoint_singleton_right, neg_le_self_iff, Nat.cast_nonneg,
    lt_self_iff_false, and_false, and_self]


lemma PS1 (z : ℍ) (m : ℤ) : limUnder atTop
  (fun N : ℕ => ∑ n in (Finset.Ico (-(N : ℤ)) (N : ℤ)),
    (1 / ((m : ℂ) * z + n) -  1 / (m * z + n + 1))) = 0 := by
  apply Filter.Tendsto.limUnder_eq
  rw [@NormedAddCommGroup.tendsto_nhds_zero]
  intro ε hε
  simp only [  norm_eq_abs, eventually_atTop, ge_iff_le]
  use 0
  intro b hb
  have : ∑ n in (Finset.Ico (-(b : ℤ)) (b : ℤ)),
    (1 / ((m : ℂ) * z + n) -  1 / (m * z + n + 1)) = (1 / ((m : ℂ) * z - b) -  1 / (m * z + b))  := by
    apply telescope_aux
  rw [this]
  simp [hε]

  sorry

lemma ada (f : ℤ → ℂ) (h : ∀ i, f i = 0) : ∑' n, f n = 0 := by
  convert tsum_zero
  aesop


lemma PS2 (z : ℍ) : ∑' m : ℤ, (limUnder atTop
  (fun N : ℕ => ∑ n in (Finset.Ico (-(N : ℤ)) (N : ℤ)),
    (1 / ((m : ℂ) * z + n) -  1 / (m * z + n + 1)))) = 0 := by
    convert tsum_zero
    next m =>
    apply PS1
    --apply m.2

lemma PS3 (z : ℍ) : limUnder atTop
  (fun N : ℕ => ∑ n in (Finset.Ico (-(N : ℤ)) (N : ℤ)),
    ∑' m : ℤ , (1 / ((m : ℂ) * z + n) -  1 / (m * z + n + 1))) = -2 * π * Complex.I / z := by sorry

lemma aux (a b c : ℝ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) : a⁻¹ ≤ c * b⁻¹ ↔ b ≤ c * a := by
  constructor
  intro h
  simp_rw [inv_eq_one_div] at h
  rw [mul_one_div, le_div_comm₀ _ hb] at h
  simp only [one_div, div_inv_eq_mul] at h
  apply h
  simp only [one_div, inv_pos]
  exact ha
  intro h
  simp_rw [inv_eq_one_div]
  rw [← div_le_comm₀ _ ha]
  simp only [one_div, mul_inv_rev, inv_inv]
  rw [propext (mul_inv_le_iff₀ hc), mul_comm]
  exact h
  simp only [one_div]
  apply mul_pos hc (inv_pos.mpr hb)

theorem extracted_1 (b : Fin 2 → ℤ) (hb : b ≠ 0) (HB1 : b ≠ ![0, -1]) :
    ‖![b 0, b 1 + 1]‖ ^ (-1 : ℝ) * ‖b‖ ^ (-2 : ℝ) ≤ 2 * ‖b‖ ^ (-3 : ℝ) := by
  rw [show (-3 : ℝ) = -1 -2  by norm_num]
  have ht : b = ![b 0, b 1] := by
    ext i
    fin_cases i <;> rfl
  nth_rw 3 [Real.rpow_of_add_eq (y := -1) (z := -2) (by apply norm_nonneg) (by norm_num)
    (by norm_num)]
  rw [← mul_assoc]
  apply mul_le_mul
  · simp_rw [Real.rpow_neg_one]
    rw [aux]
    · simp only [norm_eq_max_natAbs, Nat.cast_max, Nat.succ_eq_add_one, Nat.reduceAdd,
        Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, max_le_iff]
      have : 2 * max ↑(b 0).natAbs ↑(b 1 + 1).natAbs = max (2*(b 0)).natAbs (2*(b 1 + 1)).natAbs := by
        simp_rw [Int.natAbs_mul]
        exact (Nat.mul_max_mul_left 2 (b 0).natAbs (b 1 + 1).natAbs).symm
      refine ⟨?_ , ?_⟩
      · norm_cast
        simp only [this, Fin.isValue, le_max_iff]
        left
        simp only [Int.natAbs_mul, Int.reduceAbs]
        apply Nat.le_mul_of_pos_left _ Nat.zero_lt_two
      norm_cast
      rcases eq_or_ne (b 1) (-1) with hr | hr
      · simp only [this, le_max_iff]
        left
        simp only [hr, Int.reduceNeg, IsUnit.neg_iff, isUnit_one, Int.natAbs_of_isUnit, Fin.isValue, Int.natAbs_mul, Int.reduceAbs, Fin.isValue]
        have hb0 : b 0 ≠ 0 := by
          rw [ht, hr] at HB1
          simp only [Nat.succ_eq_add_one, Nat.reduceAdd, Fin.isValue, Int.reduceNeg, ne_eq] at HB1
          by_contra hh
          simp only [hh, Int.reduceNeg, not_true_eq_false] at HB1
        omega
      · rw [this]
        simp only [Fin.isValue, le_max_iff]
        right
        simp only [Int.natAbs_mul, Int.reduceAbs]
        omega
    · simp only [Nat.succ_eq_add_one, Nat.reduceAdd, Fin.isValue, norm_pos_iff, ne_eq,
      Matrix.cons_eq_zero_iff, Matrix.zero_empty, and_true, not_and]
      intro h
      by_contra H
      rw [@add_eq_zero_iff_eq_neg] at H
      rw [ht, h, H] at HB1
      simp only [Nat.succ_eq_add_one, Nat.reduceAdd, Int.reduceNeg, ne_eq, not_true_eq_false] at HB1
    · exact norm_pos_iff.mpr hb
    · simp only [Nat.ofNat_pos]
  · rfl
  · apply Real.rpow_nonneg
    apply norm_nonneg
  · simp only [Nat.ofNat_pos, mul_nonneg_iff_of_pos_left]
    apply Real.rpow_nonneg
    apply norm_nonneg

lemma G_2_alt_summable (z : ℍ) : Summable fun  (m : Fin 2 → ℤ) =>
    1 / (((m 0 : ℂ) * z + m 1)^2 * (m 0 * z + m 1 + 1))  := by
  have hk' : 2 < (3 : ℝ) := by linarith
  apply ((summable_one_div_norm_rpow hk').mul_left <| r z ^ (-3 : ℝ) *  2).of_norm_bounded_eventually
  rw [Filter.eventually_iff_exists_mem ]
  use { ![0,0], ![0,-1]}ᶜ
  simp
  intro b HB1 HB2
  have hk0 : 0 ≤ (2 : ℝ) := by norm_num
  have hk0' : 0 ≤ (1 : ℝ) := by norm_num
  have p1 := summand_bound z  hk0 b
  let b' : Fin 2 → ℤ := ![b 0, b 1 + 1]
  have p2 := summand_bound z hk0' b'
  simp only [Nat.ofNat_nonneg, zero_le_one, Fin.isValue, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.head_cons, Int.cast_add, Int.cast_one, one_div, mul_inv_rev, map_mul, map_inv₀, map_pow,
     ge_iff_le, b'] at *
  have := mul_le_mul p2 p1 ?_ ?_
  have hpow :  Complex.abs (↑(b 0) * ↑z + ↑(b 1)) ^ (-2 : ℝ) =  (Complex.abs (↑(b 0) * ↑z + ↑(b 1)) ^ 2)⁻¹ :=
    by norm_cast
  have hpow2 :  Complex.abs (↑(b 0) * ↑z + ↑(b 1)+1) ^ (-1 : ℝ) = (Complex.abs (↑(b 0) * ↑z + ↑(b 1)+1))⁻¹ :=
    by apply Real.rpow_neg_one
  rw [← hpow, ← hpow2]
  rw [← add_assoc] at this
  apply le_trans this
  have :  r z ^ (-1 : ℝ) * ‖![b 0, b 1 + 1]‖ ^ (-1 : ℝ) * (r z ^ (-2 : ℝ) * ‖b‖ ^ (-2 : ℝ)) =
    r z ^ (-3 : ℝ) * ‖![b 0, b 1 + 1]‖ ^ (-1 : ℝ) * ‖b‖ ^ (-2 : ℝ) := by
    rw [show (-3 : ℝ) = -2 -1  by norm_num]
    nth_rw 5 [Real.rpow_of_add_eq (y := -2) (z := -1)]
    ring
    exact (r_pos z).le
    norm_cast
    norm_cast
  rw [this]
  have hg : r z ^ (-3 : ℝ) * 2 * ‖b‖ ^ (-3 : ℝ) = r z ^ (-3 : ℝ) * (2 * ‖b‖ ^ (-3 : ℝ)) := by ring
  rw [hg, mul_assoc]
  apply mul_le_mul
  rfl
  apply  extracted_1
  convert HB1
  apply symm
  simp only [Matrix.cons_eq_zero_iff, Matrix.zero_empty, and_self]
  simpa using HB2
  · exact
    mul_nonneg (Real.rpow_nonneg (norm_nonneg ![b 0, b 1 + 1]) (-1))
      (Real.rpow_nonneg (norm_nonneg b) (-2))
  · apply Real.rpow_nonneg
    apply (r_pos z).le
  · apply Real.rpow_nonneg
    exact AbsoluteValue.nonneg Complex.abs _
  · exact
    mul_nonneg (Real.rpow_nonneg (LT.lt.le (r_pos z)) (-1))
      (Real.rpow_nonneg (norm_nonneg ![b 0, b 1 + 1]) (-1))

lemma G_2_alt_summable_δ (z : ℍ) : Summable fun  (m : Fin 2 → ℤ) =>
    (1 / (((m 0 : ℂ) * z + m 1)^2 * (m 0 * z + m 1 + 1)) + δ (m 0) (m 1)):= by
    let s : Finset (Fin 2 → ℤ) := { ![0,0], ![0,-1]}
    rw [← Finset.summable_compl_iff s]
    have := (G_2_alt_summable z).subtype sᶜ
    simp at *
    apply this.congr
    intro b
    simp at *
    have hb1 : b.1 ≠ ![0, 0] := by aesop
    have hb2 : b.1 ≠ ![0, -1] := by aesop
    simp [δ]
    split_ifs with h1 h2
    exfalso
    have hb : b.1 = ![0, 0] := by
      nth_rw 1 [← h1.1, ← h1.2]
      simp
      exact List.ofFn_inj.mp rfl
    exact hb1 hb
    exfalso
    have hb : b.1 = ![0, -1] := by
      nth_rw 1 [← h2.1, ← h2.2]
      simp
      exact List.ofFn_inj.mp rfl
    exact hb2 hb
    rfl

theorem G2_prod_summable1 (z : ℍ) (b : ℤ) :
    Summable fun c : ℤ ↦ ((b : ℂ) * ↑z + ↑c + 1)⁻¹ * (((b : ℂ) * ↑z + ↑c) ^ 2)⁻¹ := by
  have := G_2_alt_summable z
  simp only [Fin.isValue, one_div, mul_inv_rev] at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  apply this.prod_factor b

theorem G2_prod_summable1_δ (z : ℍ) (b : ℤ) :
    Summable fun c : ℤ ↦ ((b : ℂ) * ↑z + ↑c + 1)⁻¹ * (((b : ℂ) * ↑z + ↑c) ^ 2)⁻¹ + δ b c := by
  have := G_2_alt_summable_δ z
  simp only [Fin.isValue, one_div, mul_inv_rev] at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  apply this.prod_factor b

lemma G2_alt_indexing (z : ℍ) : ∑' (m : Fin 2 → ℤ),
    1 / (((m 0 : ℂ) * z + m 1)^2 * (m 0 * z + m 1 + 1)) =
    ∑' m : ℤ, ∑' n : ℤ, 1 / (((m : ℂ)* z + n)^2 * (m * z + n +1)) := by
  rw [ ← (finTwoArrowEquiv _).symm.tsum_eq]
  simp
  refine tsum_prod' ?h ?h₁
  have := G_2_alt_summable z
  simp at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  apply this
  intro b
  simp
  have := G_2_alt_summable z
  simp only [Fin.isValue, one_div, mul_inv_rev] at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  apply this.prod_factor

lemma G2_alt_indexing_δ (z : ℍ) : ∑' (m : Fin 2 → ℤ),
    (1 / (((m 0 : ℂ) * z + m 1)^2 * (m 0 * z + m 1 + 1)) + δ (m 0) (m 1))  =
    ∑' m : ℤ, ∑' n : ℤ, (1 / (((m : ℂ)* z + n)^2 * (m * z + n +1)) + (δ m n)) := by
  rw [ ← (finTwoArrowEquiv _).symm.tsum_eq]
  simp
  refine tsum_prod' ?h ?h₁
  have := G_2_alt_summable_δ z
  simp at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  apply this
  intro b
  simp
  have := G_2_alt_summable_δ z
  simp only [Fin.isValue, one_div, mul_inv_rev] at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  apply this.prod_factor


def swap : (Fin 2 → ℤ) → (Fin 2 → ℤ) := fun x => ![x 1, x 0]

@[simp]
lemma swap_apply (b : Fin 2 → ℤ) : swap b = ![b 1, b 0] := rfl

lemma swap_involutive (b : Fin 2 → ℤ) : swap (swap b) = b := by
  ext i
  fin_cases i <;> rfl

def swap_equiv : Equiv (Fin 2 → ℤ) (Fin 2 → ℤ) := Equiv.mk swap swap
  (by rw [LeftInverse]; apply swap_involutive)
  (by rw [Function.RightInverse]; apply swap_involutive)

lemma G2_alt_indexing2 (z : ℍ) : ∑' (m : Fin 2 → ℤ),
    1 / (((m 0 : ℂ) * z + m 1)^2 * (m 0 * z + m 1 + 1)) =
    ∑' n : ℤ, ∑' m : ℤ, 1 / (((m : ℂ)* z +n)^2 * (m * z + n +1)) := by
  have := (G_2_alt_summable z)
  simp at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  rw [tsum_comm']
  rw [G2_alt_indexing]
  apply this.congr
  intro b
  simp
  rfl
  intro b
  simp
  apply this.prod_factor
  intro c
  simp
  have H := (G_2_alt_summable z)
  simp at this
  rw [← swap_equiv.summable_iff] at H
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at H
  simp [Fin.isValue, one_div, mul_inv_rev, swap_equiv, Equiv.coe_fn_mk,
    finTwoArrowEquiv_symm_apply, swap_apply] at H
  have := H.prod_factor c
  simp at this
  apply this

lemma G2_alt_indexing2_δ (z : ℍ) : ∑' (m : Fin 2 → ℤ),
    (1 / (((m 0 : ℂ) * z + m 1)^2 * (m 0 * z + m 1 + 1)) + δ (m 0) (m 1))  =
    ∑' n : ℤ, ∑' m : ℤ, (1 / (((m : ℂ)* z +n)^2 * (m * z + n +1)) + δ m n) := by
  have := (G_2_alt_summable_δ z)
  simp at this
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at this
  rw [tsum_comm']
  rw [G2_alt_indexing_δ]
  apply this.congr
  intro b
  simp
  rfl
  intro b
  simp
  apply this.prod_factor
  intro c
  simp
  have H := (G_2_alt_summable_δ z)
  simp at this
  rw [← swap_equiv.summable_iff] at H
  rw [← (finTwoArrowEquiv _).symm.summable_iff] at H
  simp [Fin.isValue, one_div, mul_inv_rev, swap_equiv, Equiv.coe_fn_mk,
    finTwoArrowEquiv_symm_apply, swap_apply] at H
  have := H.prod_factor c
  simp at this
  apply this


lemma verga : Tendsto (fun N : ℕ => Finset.Ico (-N : ℤ) N) atTop atTop := by
  apply Monotone.tendsto_atTop_atTop
  rw [@monotone_iff_forall_covBy]
  intro a b h
  simp at *
  intro t
  simp
  intro h1 h2
  rw [Order.covBy_iff_add_one_eq] at h
  rw [← h]
  omega
  intro b




  sorry

lemma aux3 (f : ℤ → ℂ) (hf : Summable f) : ∑' n, f n =
    limUnder atTop (fun N : ℕ => ∑ n in Finset.Ico (-N : ℤ) N, f n) := by
  rw [Filter.Tendsto.limUnder_eq]
  have  := hf.hasSum
  have V := this.comp verga
  apply V



lemma limUnder_add {α : Type*} [Preorder α] [(atTop : Filter α).NeBot] (f g : α → ℂ)
    (hf : CauchySeq f) (hg : CauchySeq g) :
    (limUnder atTop f) + (limUnder atTop g) = limUnder atTop (f + g) := by
  nth_rw 3 [Filter.Tendsto.limUnder_eq]
  rw [@Pi.add_def]
  apply Filter.Tendsto.add
  refine CauchySeq.tendsto_limUnder hf
  refine CauchySeq.tendsto_limUnder hg


lemma limUnder_mul_const {α : Type*} [Preorder α] [(atTop : Filter α).NeBot] (f : α → ℂ)
    (hf : CauchySeq f) (c : ℂ) :
    c * (limUnder atTop f)= limUnder atTop (c • f) := by
  nth_rw 2 [Filter.Tendsto.limUnder_eq]
  apply Filter.Tendsto.const_mul
  refine CauchySeq.tendsto_limUnder hf


lemma limUnder_sub {α : Type*} [Preorder α] [(atTop : Filter α).NeBot] (f g : α → ℂ)
    (hf : CauchySeq f) (hg : CauchySeq g) :
    (limUnder atTop f) - (limUnder atTop g) = limUnder atTop (f - g) := by
  nth_rw 3 [Filter.Tendsto.limUnder_eq]
  rw [@Pi.sub_def]
  apply Filter.Tendsto.sub
  refine CauchySeq.tendsto_limUnder hf
  refine CauchySeq.tendsto_limUnder hg


theorem tendstozero_inv_linear (z : ℍ) (b : ℤ)  :
  Tendsto (fun d : ℕ ↦ 1 / ((b : ℂ) * ↑z + ↑d)) atTop (𝓝 0) := by
    rw [@tendsto_zero_iff_norm_tendsto_zero]
    conv =>
      enter [1]
      simp
    apply squeeze_zero (g := fun n : ℕ => r z ^ (-1 : ℝ) * ‖![b, n]‖ ^ (-1 : ℝ))
    simp
    intro t
    have := EisensteinSeries.summand_bound z (k := 1)  (by simp) ![b, t]
    simp at *
    apply le_trans _ this
    apply le_of_eq
    rw [Real.rpow_neg_one]
    rw [← tendsto_const_smul_iff₀ (c := r z ) ]
    simp
    have hr : r z * r z ^ (-1 : ℝ) = 1 := by
      rw [Real.rpow_neg_one]
      refine mul_inv_cancel₀ (ne_of_lt (r_pos z)).symm
    conv =>
      enter [1]
      intro r
      rw [← mul_assoc, hr]
    simp
    apply squeeze_zero' (g := (fun n : ℕ => |(n : ℝ)| ^ (-1 : ℝ)))
    apply Filter.Eventually.of_forall
    intro x
    refine Real.rpow_nonneg ?g0.hf.hp.hx (-1)
    apply norm_nonneg
    rw [@eventually_atTop]
    use b.natAbs
    intro x hx
    apply le_of_eq
    congr
    rw [EisensteinSeries.norm_eq_max_natAbs ]
    simp [hx]
    simp
    apply tendsto_inverse_atTop_nhds_zero_nat.congr
    intro x
    exact Eq.symm (Real.rpow_neg_one ↑x)
    have := r_pos z
    exact (ne_of_lt this).symm

theorem poly_id (z : ℍ) (b n : ℤ) :
  ((b : ℂ) * ↑z + ↑n + 1)⁻¹ * (((b : ℂ) * ↑z + ↑n) ^ 2)⁻¹ + (δ b n) +
    (((b : ℂ) * ↑z + ↑n)⁻¹ - ((b : ℂ) * ↑z + ↑n + 1)⁻¹) =
    (((b : ℂ) * ↑z + ↑n) ^ 2)⁻¹ := by
  by_cases h : b = 0 ∧ n = 0
  rw [h.1, h.2]
  simp
  simp at h
  by_cases hb : b = 0
  by_cases hn : n = -1
  simp [hb, hn]
  ring
  have hj := h hb
  have hd : δ 0 n = 0 := by
    simp [δ, hb, hj, hn]
  simp [hd, hb]
  have hn0 : (n : ℂ) ≠ 0 := by aesop
  have hn1 : (n : ℂ) + 1 ≠ 0 := by
    norm_cast
    omega
  field_simp
  ring
  have : δ b n = 0 := by simp [δ, hb]
  rw [this]
  simp
  have h : ![(b : ℝ), n + 1] ≠ 0 := by
    aesop
  have hh : ![(b : ℝ), n ] ≠ 0 := by
    aesop
  have h0 : ((b : ℂ) * ↑z + ↑n + 1) ≠ 0 := by
    have := linear_ne_zero ![b, n + 1] z h
    simp at this
    norm_cast at this
    rw [@AddSemigroup.add_assoc]
    aesop
  have h1 : ((b : ℂ) * ↑z + ↑n) ≠ 0 := by
    have := linear_ne_zero ![b, n] z hh
    simpa using this
  field_simp [h0, h1]
  ring


lemma limUnder_congr_eventually (f g : ℕ → ℂ) (h : ∀ᶠ n in atTop, f n = g n)
  (hf : CauchySeq f) (hg : CauchySeq g)  :
  limUnder atTop f = limUnder atTop g := by
  have h0 := CauchySeq.tendsto_limUnder hf
  have h1 := CauchySeq.tendsto_limUnder hg
  rw [Filter.Tendsto.limUnder_eq (x := (limUnder atTop f)) ]
  rw [Filter.Tendsto.limUnder_eq ]
  apply Filter.Tendsto.congr' _ h1
  symm
  apply h
  exact h0
  --apply Filter.Tendsto.congr' ( hf)

theorem extracted_2 (z : ℍ) (b : ℤ) : CauchySeq fun N : ℕ ↦
  ∑ n ∈ Finset.Ico (-↑N : ℤ) ↑N, 1 / (((b : ℂ) * ↑z + ↑n) ^ 2 * (↑b * ↑z + ↑n + 1)) := by
  apply Filter.Tendsto.cauchySeq (x := ∑' (x : ℤ),
        ((b  : ℂ) * ↑z + ↑x + 1)⁻¹ * (((b : ℂ) * ↑z + ↑x) ^ 2)⁻¹)
  have hA:= (G2_prod_summable1 z b).hasSum
  have ht := hA.comp verga
  simp at *
  apply ht

theorem extracted_2_δ (z : ℍ) (b : ℤ) : CauchySeq fun N : ℕ ↦
  ∑ n ∈ Finset.Ico (-↑N : ℤ) ↑N, (1 / (((b : ℂ) * ↑z + ↑n) ^ 2 * (↑b * ↑z + ↑n + 1)) + δ b n) := by
  apply Filter.Tendsto.cauchySeq (x := ∑' (x : ℤ),
        (((b  : ℂ) * ↑z + ↑x + 1)⁻¹ * (((b : ℂ) * ↑z + ↑x) ^ 2)⁻¹  + δ b x))
  have hA:= (G2_prod_summable1_δ z b).hasSum
  have ht := hA.comp verga
  simp at *
  apply ht


theorem extracted_3 (z : ℍ) (b : ℤ) : CauchySeq fun N : ℕ ↦
  ∑ n ∈ Finset.Ico (-↑N : ℤ) ↑N, (1 / ((b : ℂ) * ↑z + ↑n) - 1 / (↑b * ↑z + ↑n + 1)) := by
  conv =>
      enter [1]
      intro d
      rw [telescope_aux ]
  apply Filter.Tendsto.cauchySeq (x := 0)
  have h1 : Tendsto (fun d : ℕ ↦ 1 / ((b : ℂ) * ↑z - ↑d)) atTop (𝓝 0) := by
    have := tendstozero_inv_linear z (-b)
    rw [← tendsto_const_smul_iff₀ (c := (-1 : ℂ) ) ] at this
    simp at *
    apply this.congr
    intro x
    rw [neg_inv]
    congr
    ring
    norm_cast
  have h2 : Tendsto (fun d : ℕ ↦ 1 / ((b : ℂ) * ↑z + ↑d)) atTop (𝓝 0) := by
    apply tendstozero_inv_linear z b
  have := Filter.Tendsto.sub h1 h2
  simpa using this

/-This is proven in the modular forms repo. -/
lemma G2_summable_aux (n : ℤ) (z : ℍ) (k : ℤ) (hk : 2 ≤ k) :
    Summable fun d : ℤ => ((((n : ℂ) * z) + d) ^ k)⁻¹ := by sorry

theorem extracted_4 (z : ℍ) (b : ℤ) :
  CauchySeq fun N : ℕ ↦ ∑ n ∈ Finset.Ico (-↑N : ℤ) ↑N, (1 / ((b : ℂ) * ↑z + ↑n) ^ 2 ) := by
  apply Filter.Tendsto.cauchySeq (x := ∑' (x : ℤ), ((((b : ℂ) * ↑z + ↑x) ^ 2)⁻¹))
  have hA:= (G2_summable_aux b z 2 (by norm_num)).hasSum
  have ht := hA.comp verga
  simp at *
  apply ht

theorem extracted_5 (z : ℍ) (b : ℤ) :
  CauchySeq fun N : ℕ ↦ ∑ n ∈ Finset.Ico (-↑N : ℤ) ↑N, (1 / ((b : ℂ) * ↑z - ↑n) ^ 2 ) := by
  apply Filter.Tendsto.cauchySeq (x := ∑' (x : ℤ), ((((b : ℂ) * ↑z - ↑x) ^ 2)⁻¹))
  have hA:= (G2_summable_aux b z 2 (by norm_num)).hasSum
  have ht := hA.comp verga
  simp at *
  have := ht.congr' (f₂ := fun N : ℕ ↦ ∑ n ∈ Finset.Ico (-↑N : ℤ) ↑N, (1 / ((b : ℂ) * ↑z - ↑n) ^ 2 )) ?_
  simp at this
  sorry
  sorry

lemma auxr (z : ℍ) (b : ℤ):
    ((limUnder atTop fun N : ℕ ↦
    ∑ n ∈ Finset.Ico (-N : ℤ) N, (1 / (((b : ℂ) * ↑z + ↑n) ^ 2 * (↑b * ↑z + ↑n + 1)) + δ b n)) +
    limUnder atTop fun N : ℕ ↦
    ∑ n ∈ Finset.Ico (-N : ℤ) N, (1 / ((b : ℂ) * ↑z + ↑n) - 1 / (↑b * ↑z + ↑n + 1))) =
    limUnder atTop fun N : ℕ ↦
    ∑ n ∈ Finset.Ico (-N : ℤ) N, (1 / ((b : ℂ) * ↑z + ↑n) ^ 2) := by
  have := limUnder_add (f := fun N : ℕ ↦
    ∑ n ∈ Finset.Ico (-N : ℤ) N, (1 / (((b : ℂ) * ↑z + ↑n) ^ 2 * (↑b * ↑z + ↑n + 1))+ δ b n))
    (g := fun N : ℕ ↦
    ∑ n ∈ Finset.Ico (-N : ℤ) N, (1 / ((b : ℂ) * ↑z + ↑n) - 1 / (↑b * ↑z + ↑n + 1)))
      (extracted_2_δ z b) (by apply extracted_3 z b)
  rw [this]
  apply limUnder_congr_eventually _ _ _
    (by apply CauchySeq.add (extracted_2_δ z b) (extracted_3 z b)) (by apply extracted_4 z b)
  simp only [one_div, mul_inv_rev, Pi.add_apply, eventually_atTop,
    ge_iff_le]
  use 1
  intro c hc
  rw [← Finset.sum_add_distrib ]
  congr
  ext n
  apply  poly_id z b n



--this sum is now abs convergent. Idea is to subtract PS1 from the G₂ defn.
lemma G2_alt_eq (z : ℍ) : G₂ z = ∑' m : ℤ, ∑' n : ℤ, (1 / (((m : ℂ)* z +n)^2 * (m * z + n +1)) + δ m n) := by
    rw [G₂]
    have :=  PS2 z
    set t :=  ∑' m : ℤ, ∑' n : ℤ, (1 / (((m : ℂ)* z +n)^2 * (m * z + n +1)) + δ m n)
    rw [show t = t + 0 by ring, ← this]
    simp only [t]
    rw [← tsum_add]
    · rw [aux3]
      · congr
        ext n
        congr
        ext m
        rw [aux3, aux3, auxr z m]
        · have H := G2_prod_summable1_δ z m
          simpa using H
        · have H := G2_summable_aux m z 2 (by norm_num)
          simpa using H
      · have H := G_2_alt_summable_δ z
        rw [← (finTwoArrowEquiv _).symm.summable_iff] at H
        have ha := H.prod
        apply ha.congr
        intro b
        simpa using PS1 z b
    · have H := G_2_alt_summable_δ z
      rw [← (finTwoArrowEquiv _).symm.summable_iff] at H
      have ha := H.prod
      apply ha.congr
      intro b
      simp only [Fin.isValue, one_div, mul_inv_rev, finTwoArrowEquiv_symm_apply, comp_apply,
        Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]
    · have HS : Summable fun m : ℤ => (0 : ℂ) := by apply summable_zero
      apply HS.congr
      intro b
      symm
      apply PS1 z b


lemma G2_S_act (z : ℍ) : (z.1 ^ 2)⁻¹ * G₂ (ModularGroup.S • z) =  limUnder (atTop)
    fun N : ℕ => ((∑' (n : ℤ), ∑ m in Finset.Ico (-N : ℤ) N, (1 / ((n : ℂ) * z + m) ^ 2))) := by
  rw [ modular_S_smul]
  simp [G₂]
  rw [ limUnder_mul_const]
  congr
  ext N
  simp
  sorry
  sorry



lemma G2_inde_lhs (z : ℍ) : (z.1 ^ 2)⁻¹ * G₂ (ModularGroup.S • z) - -2 * π * Complex.I / z =
  ∑' n : ℤ, ∑' m : ℤ, (1 / (((m : ℂ)* z +n)^2 * (m * z + n +1)) + δ m n) := by
  rw [G2_S_act]
  rw [← PS3 z]
  rw [aux3]

  rw [limUnder_sub]
  congr
  ext N
  simp
  rw [tsum_sum]
  rw [← Finset.sum_sub_distrib ]
  congr
  ext n
  rw [← tsum_sub]
  congr
  ext m
  have := poly_id z m n
  nth_rw 1 [← this]
  simp




  sorry
  sorry
  sorry
  sorry
  sorry
  sorry
/- /-Check that we didnt define the zero function! -/
lemma G2'_summable (z : ℍ) : Summable fun m : ℤ =>  (∑' (n : ℤ), 1 / ((m : ℂ) * z + n) ^ 2) := by
  --is this true??
  sorry
 -/

/-This is from the modforms repo, so no need to prove it. -/
theorem series_eql' (z : ℍ) :
    ↑π * Complex.I - 2 * ↑π * Complex.I * ∑' n : ℕ, Complex.exp (2 * ↑π * Complex.I * z * n) =
      1 / z + ∑' n : ℕ+, (1 / ((z : ℂ) - n) + 1 / (z + n)) := sorry



def E₂ : ℍ → ℂ := (1 / (2 * riemannZeta 2)) •  G₂

/-This result is already proven in the modular forms repo and being PRed (slowly) into mathlib, so
we can use it freely here. -/
lemma E_k_q_expansion (k : ℕ) (hk : 3 ≤ (k : ℤ)) (hk2 : Even k) (z : ℍ) :
    (E k hk) z = 1 +
        (1 / (riemannZeta (k))) * ((-2 * ↑π * Complex.I) ^ k / (k - 1)!) *
        ∑' n : ℕ+, sigma (k - 1) n * Complex.exp (2 * ↑π * Complex.I * z * n) := by sorry

/--This we should get from the modular forms repo stuff. Will port these things soon. -/
lemma E₂_eq (z : UpperHalfPlane) : E₂ z =
    1 - 24 * ∑' (n : ℕ+),
    ↑n * cexp (2 * π * Complex.I * n * z) / (1 - cexp (2 * π * Complex.I * n * z)) := sorry



/-This is the annoying exercise. -/
lemma G₂_transform (z : ℍ) (γ : SL(2, ℤ)) : (G₂ ∣[(2 : ℤ)] γ) z =
  G₂ z - (2 * π * Complex.I * γ 1 0) / (denom γ z) := sorry

/-Should be easy from the above.-/
lemma E₂_transform (z : ℍ) (γ : SL(2, ℤ)) : (E₂ ∣[(2 : ℤ)] ModularGroup.S) z =
  E₂ z + 6 / ( π * Complex.I * z) := sorry

lemma MultipliableDiscriminantProductExpansion : Multipliable (fun (z : UpperHalfPlane) =>
  cexp (2 * π * Complex.I * z) * ∏' (n : ℕ+), (1 - cexp (2 * π * Complex.I * n * z)) ^ 24) := sorry

/- The discriminant form -/
def Δ (z : UpperHalfPlane) :=  cexp (2 * π * Complex.I * z) * ∏' (n : ℕ+),
    (1 - cexp (2 * π * Complex.I * n * z)) ^ 24

/-This should be easy from the definition and the Mulitpliable bit. -/
lemma Δ_ne_zero (z : UpperHalfPlane) : Δ z ≠ 0 := by sorry

/- The eta function. Best to define it on all of ℂ since we want to take its logDeriv. -/
def η (z : ℂ) := cexp (π * Complex.I * z / 24) * ∏' (n : ℕ+),
    (1 - cexp (2 * π * Complex.I * n * z))

lemma eta_disc (z : ℍ) : (η ^ 24) z = Δ z := by sorry

lemma eta_logDeriv (z : ℍ) : logDeriv η z = (π * Complex.I / 12) * E₂ z := sorry

/- φ₀, φ₋₂ and φ₋₄, except we can't use - signs in subscripts for definitions... -/
def φ₀ (z : UpperHalfPlane) := (((E₂ z) * (E₄ z) - (E₆ z)) ^ 2) / (Δ z)
def φ₂' (z : UpperHalfPlane) := (E₄ z) * ((E₂ z) * (E₄ z) - (E₆ z)) / (Δ z)
def φ₄' (z : UpperHalfPlane) := ((E₄ z) ^ 2) / (Δ z)
/- We extend these definitions to ℂ for convenience. -/
def φ₀'' (z : ℂ) : ℂ := if hz : 0 < z.im then φ₀ ⟨z, hz⟩ else 0
def φ₂'' (z : ℂ) : ℂ := if hz : 0 < z.im then φ₂' ⟨z, hz⟩ else 0
def φ₄'' (z : ℂ) : ℂ := if hz : 0 < z.im then φ₄' ⟨z, hz⟩ else 0

end Definitions

noncomputable section Holomorphicity

-- Try and get the desired holomorphicity results for φ₀, φ₂ and φ₄ in terms of the Eᵢ

end Holomorphicity

noncomputable section Integrability

-- Here, we show that

end Integrability

open Complex Real

noncomputable section  Product_Formula
/-This one is easy.-/
lemma Discriminant_T_invariant : (Δ ∣[(12 : ℤ)] ModularGroup.T) = Δ := sorry

/-This is the hard one. -/
lemma Discriminant_S_invariant : (Δ ∣[(12 : ℤ)] ModularGroup.S) = Δ := sorry
-- use E₂_transform

def Discriminant_SIF : SlashInvariantForm (CongruenceSubgroup.Gamma 1) 12 where
  toFun := Δ
  slash_action_eq' A := by sorry

open Manifold in
lemma Discriminant_MDifferentiable : MDifferentiable 𝓘(ℂ) 𝓘(ℂ) Δ := sorry

lemma Discriminant_zeroAtImInfty (γ : SL(2, ℤ)): IsZeroAtImInfty (Δ ∣[(12 : ℤ)] γ) := sorry

def CuspForm_div_Discriminant (k : ℤ) (f : CuspForm (CongruenceSubgroup.Gamma 1) k) (z : ℍ) :
  ModularForm (CongruenceSubgroup.Gamma 1) (k - 12) where
    toFun := f  / Δ
    slash_action_eq' := sorry
    holo' := sorry --need to use the q-expansion to see that its still holo
    bdd_at_infty' := sorry


/-this is done in the modformdims repo, soon to be in mathlib.-/
lemma weigth_zero_rank_eq_one : Module.rank ℂ (ModularForm (CongruenceSubgroup.Gamma 1) 0) = 1 :=
  by sorry

/-this is done in the modformdims repo, soon to be in mathlib.-/
lemma neg_weight_rank_zero (k : ℤ) (hk : k < 0) :
    Module.rank ℂ (ModularForm (CongruenceSubgroup.Gamma 1) k) = 0 := by sorry

def CuspForms_iso_Modforms (k : ℤ) : CuspForm (CongruenceSubgroup.Gamma 1) k ≃ₗ[ℂ]
    ModularForm (CongruenceSubgroup.Gamma 1) (k - 12) := sorry

theorem DiscriminantProductFormula (z : UpperHalfPlane) : Δ z = ((E₄ z) ^ 3 - (E₆ z) ^ 2) / 1728 := sorry
--enough to check its a cuspform, since if it is, then divining by Δ gives a modular form of weight 0.

lemma weight_two_empty (f : ModularForm (CongruenceSubgroup.Gamma 1) 2) : f = 0 := sorry
/- cant be a cuspform from the above, so let a be its constant term, then f^2 = a^2 E₄ and
f^3 = a^3 E₆, but now this would mean that Δ = 0 or a = 0, which is a contradiction. -/

lemma dim_modforms_eq_one_add_dim_cuspforms (k : ℤ) (hk : 2 < k):
    Module.rank ℂ (ModularForm (CongruenceSubgroup.Gamma 1) k) =
    1 + Module.rank ℂ (CuspForm (CongruenceSubgroup.Gamma 1) k) := sorry

lemma dim_modforms_lvl_one (k : ℤ) :
    Module.rank ℂ (ModularForm (CongruenceSubgroup.Gamma 1) k) = if 12 ∣ k - 2 then
    Nat.floor (k / 12) else Nat.floor (k / 12) + 1 := sorry

lemma dim_gen_cong_levels (k : ℤ) (Γ : Subgroup SL(2, ℤ)) (hΓ : Subgroup.index Γ ≠ 0) :
    FiniteDimensional ℂ (ModularForm Γ k) := by sorry
--use the norm to turn it into a level one question.


end Product_Formula

#min_imports
