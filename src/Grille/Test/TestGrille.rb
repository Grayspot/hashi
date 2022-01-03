require_relative '../Grille.rb'

#Création de la grille
g = Grille.creer('map.txt')
g.chargerGrille()

puts g

cases = g.cases

cases[0][1].creerPont()