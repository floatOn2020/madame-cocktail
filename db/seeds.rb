require 'open-uri'

puts 'cleaning database...'
Dose.destroy_all
Ingredient.destroy_all
Cocktail.destroy_all
puts 'All ingredients deleted'
puts 'All cocktails deleted'

puts 'creating Ingredients...'
url = 'https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list'
ingredients_serialized = open(url).read
ingredients = JSON.parse(ingredients_serialized)
ingredients['drinks'].each do |ingr|
  Ingredient.create(name:  ingr['strIngredient1'].capitalize)
end
puts "#{Ingredient.count} ingredients created"

def create_doses_for_cocktail(url, cocktail)
  detailed_cocktail_serialized = open(url).read
  details = JSON.parse(detailed_cocktail_serialized)['drinks'][0]
  # get the relevant keys for doses
  filtered = details.keys.filter do |key|
    key[/strIngredient/] && !details[key].nil?
  end
  measures = details.keys.filter do |key|
    key[/strMeasure/] && !details[key].nil?
  end
  filtered.each_with_index do |key, index|
    if Ingredient.find_by(name: details[key].capitalize).nil?
      ingredient = Ingredient.create(name: details[key].capitalize)
    else
      ingredient = Ingredient.find_by(name: details[key])
    end
    desc = details[measures[index]].nil? ? '.' : details[measures[index]]
    dose = Dose.new(description: desc)
    dose.ingredient = ingredient
    dose.cocktail = cocktail
    dose.save! if dose.valid?
  end
  puts "#{Dose.count} doses created"
end

def create_cocktails(url)
  cocktails_serialized = open(url).read
  cocktails = JSON.parse(cocktails_serialized)['drinks']
  # create a cocktail for each cocktail-name
  cocktails.each do |cocktail|
    ct = Cocktail.create!(name: cocktail['strDrink'], image: cocktail['strDrinkThumb'])
    # endpoint for cocktail details
    detailed_cocktail_url = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=#{cocktail['idDrink']}"
    create_doses_for_cocktail(detailed_cocktail_url, ct)
  end
end

puts 'creating non-alcoholic cocktails...'
# endpoint for non-alcoholic cocktail names, image-urls and ids
create_cocktails('https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic')
cocktails = Cocktail.count
puts "#{cocktails} non-alcoholic cocktails created"

puts 'creating alcolholic cocktails...'
# endpoint for alcoholic cocktail names, image-urls and ids
create_cocktails('https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic')

puts "#{Cocktail.count - cocktails} alcoholic cocktails created"
