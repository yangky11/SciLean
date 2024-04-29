import Qq

import Mathlib.Tactic

import SciLean.Tactic.FunGTrans.Decl
import SciLean.Tactic.FunGTrans.Theorems
import SciLean.Tactic.FunGTrans.Attr
import SciLean.Tactic.FunGTrans.Core

open Lean Meta Qq

namespace SciLean.Tactic.FunGTrans

set_option linter.unusedVariables false

@[gtrans]
def HasDeriv (f : α → β) (df : outParam <| α → α → β) : Prop := sorry

@[gtrans]
theorem hasDeriv_id : HasDeriv (fun x : α => x) (fun x dx => dx) := sorry_proof
@[gtrans]
theorem hasDeriv_const [Inhabited β] (b : β) : HasDeriv (fun x : α => b) (fun x dx => default) := sorry_proof
@[gtrans]
theorem hasDeriv_comp
  (f : β → γ) (g : α → β)
  (f' : β → β → γ) (g' : α → α → β)
  (hf : HasDeriv f f') (hg : HasDeriv g g') :
  HasDeriv (fun x => f (g x)) (fun x dx => f' (g x) (g' x dx)) := sorry_proof

@[gtrans]
theorem hasDeriv_add [Add β]
  (f g : α → β)
  (f' g' : α → α → β)
  (hf : HasDeriv f f') (hg : HasDeriv g g') :
  HasDeriv
    (fun x => f x + g x)
    (fun x dx =>
      let dy := f' x dx
      let dz := g' x dx
      dy + dz) := sorry_proof

@[gtrans]
theorem hasDeriv_mul [Add β] [Mul β]
  (f g : α → β)
  (f' g' : α → α → β)
  (hf : HasDeriv f f') (hg : HasDeriv g g') :
  HasDeriv
    (fun x => f x * g x)
    (fun x dx =>
      let y := f x
      let dy := f' x dx
      let z := g x
      let dz := g' x dx
      y*dz+z*dy) := sorry_proof

-- set_option trace.Meta.Tactic.gtrans.candidates true
-- set_option trace.Meta.Tactic.gtrans true
-- set_option trace.Meta.Tactic.gtrans.normalize true

#eval show MetaM Unit from do

  withLocalDeclDQ `n q(Nat) fun n => do

  let e := q(HasDeriv (fun x : Nat => x*x*x*x*x*x))
  let (xs,_,b) ← forallMetaTelescope (← inferType e)
  let e := e.beta xs
  let _ ← gtrans 100 e

  IO.println (← ppExpr e)



@[gtrans]
def HasDerivOn (f : α → β) (x : outParam <| Set α) (df : outParam <| α → α → β) : Prop := sorry


@[gtrans]
theorem hasDerivOn_id : HasDerivOn (fun x : α => x) ⊤ (fun x dx => dx) := sorry_proof

@[gtrans]
theorem hasDerivOn_const [Inhabited β] (b : β) (s : Set α) : HasDerivOn (fun x : α => b) ⊤ (fun x dx => default) := sorry_proof

@[gtrans]
theorem hasDerivOn_comp
  (f : β → γ) (g : α → β) (s : Set α)
  (f' : β → β → γ) (g' : α → α → β)
  (hf : HasDerivOn f (g '' s) f') (hg : HasDerivOn g s g') :
  HasDerivOn (fun x => f (g x)) s (fun x dx => f' (g x) (g' x dx)) := sorry_proof

@[gtrans]
theorem hasDerivOn_add [Add β]
  (f g : α → β)
  (f' g' : α → α → β) (sf sg : Set α)
  (hf : HasDerivOn f sf f') (hg : HasDerivOn g sg g') :
  HasDerivOn
    (fun x => f x + g x)
    (sf ∩ sg)
    (fun x dx =>
      let dy := f' x dx
      let dz := g' x dx
      dy + dz) := sorry_proof

@[gtrans]
theorem hasDerivOn_mul [Add β] [Mul β]
  (f g : α → β)
  (f' g' : α → α → β) (sf sg : Set α)
  (hf : HasDerivOn f sf f') (hg : HasDerivOn g sg g') :
  HasDerivOn
    (fun x => f x * g x)
    (sf ∩ sg)
    (fun x dx =>
      let y := f x
      let dy := f' x dx
      let z := g x
      let dz := g' x dx
      y*dz+z*dy) := sorry_proof

@[gtrans]
theorem hasDerivOn_div [Add β] [Sub β] [Mul β] [Div β] [Inhabited β]
  (f g : α → β)
  (f' g' : α → α → β) (sf sg : Set α)
  (hf : HasDerivOn f sf f') (hg : HasDerivOn g sg g') :
  HasDerivOn
    (fun x => f x / g x)
    (sf ∩ sg ∩ g ⁻¹' {default}ᶜ)
    (fun x dx =>
      let y := f x
      let dy := f' x dx
      let z := g x
      let dz := g' x dx
      (dy*z-y*dz)/(z*z)) := sorry_proof


set_option trace.Meta.Tactic.gtrans true
set_option trace.Meta.Tactic.gtrans.candidates true

#eval show MetaM Unit from do

  withLocalDeclDQ `n q(Nat) fun n => do

  let e := q(HasDerivOn (fun x : Nat => x*x/(x+x*x*$n)))
  let (xs,_,_) ← forallMetaTelescope (← inferType e)
  let e := e.beta xs
  let _ ← gtrans 100 e

  IO.println (← ppExpr e)

-- good for surjective functions `f`
-- The additional parameter `c` determines which elemnt of `f⁻¹' {y}` does `f'` chooses
-- todo: shoud we require that `f'` produces the whole preimage? i.e. `{x | ∃ c, x = f' c y} = f⁻¹' {y}`
@[gtrans]
def ParametricRightInverse (f : α → β) (γ : outParam <| Type) (f' : outParam <| γ → β → α) : Prop :=
  ∀ (y : β) (c : γ), f (f' c y) = y

-- def polarCoordinates (θ : Float) : Float×Float := (θ.cos, θ.sin)

-- @[gtrans]
-- theorem polarCoordinates.arg_θ.ParametricRightInverse_rule :
--   ParametricRightInverse
--     polarCoordinates
--     ℤ
--     (fun n (x,y) => Float.ofInt n * 2 * Float.atan2 0 (-1) + Float.atan2 y x) := by unfold ParametricRightInverse; intros; simp[polarCoordinates]

@[gtrans]
theorem HAdd.hAdd.arg_a0a1.ParametricRightInverse_rule {α} [AddCommGroup α] [Module ℚ α] :
  ParametricRightInverse
    (fun xy : α×α => xy.1 + xy.2)
    α
    (fun a z => ((1/2:ℚ) • z+a,(1/2:ℚ) • z-a)) := by unfold ParametricRightInverse; intros; simp; sorry_proof


-- the intuition `p` recovers information lost by `f`
@[gtrans]
def ParametricLeftInverse (f : α → β) (γ : outParam <| Type) (p : outParam <| α → γ) (f' : outParam <| γ → β → α) : Prop :=
  ∀ (x : α), f' (p x) (f x) = x



@[gtrans]
def ParametricPreimageAt
    {X Y I : Type} {X₁ X₂ : I → Type}
    (f : X → Y) (y : Y)
    (p : outParam <| ∀ i, X₁ i → X₂ i → X)  -- decomposition of `X` as `X₁ i × X₂ i`
    (g : outParam <| (i : I) → X₁ i → X₂ i) -- preimage is a graph of this function
    (dom : outParam <| (i : I) → Set (X₁ i)) --
    :=
  -- all points in `dom i` map to `y`
  ∀ (i : I) (x₁ : X₁ i), (x₁ ∈ dom i) → f (p i x₁ (g i x₁)) = y
  ∧
  -- every point in the preimage can be uniquelly represented by some point `x₁ : X₁ i`
  ∀ (x : X), (x ∈ f⁻¹' {y}) → ∃! (i : I), ∃! (x₁ : X₁ i), (x₁ ∈ dom i) ∧ (p i x₁ (g i x₁) = x)
