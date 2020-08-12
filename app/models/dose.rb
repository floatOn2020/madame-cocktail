class Dose < ApplicationRecord
  belongs_to :cocktail
  belongs_to :ingredient
  validates :description, presence: true
  # validates :cocktail, :ingredient, presence: true
  validates :ingredient, uniqueness: { scope: :cocktail,
    message: "this ingredient has already been added to this cocktail" }
end
