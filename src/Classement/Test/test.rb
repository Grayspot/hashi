require_relative '../Bdd.rb'
# encoding: UTF-8

##
# Auteur DEROUAULT BAPTISTE
# Version 0.1 : 15/02/2021
#

d1 = Bdd.creer("test.bdd")
d1.creerBdd()

d2 = Bdd.creer("test.bdd")
d2.chargerBdd();
d2.insererBdd('a',1,1,1,1) #1
d2.insererBdd('b',1,1,1,2) #2
d2.insererBdd('c',1,1,1,3) #3
d2.insererBdd('d',1,1,1,5) #4
d2.insererBdd('e',1,1,1,7) #5
d2.insererBdd('f',1,1,1,6) #6
d2.insererBdd('f',1,1,1,5) #7
d2.insererBdd('f',1,1,1,7) #8
d2.insererBdd('f',1,1,1,8) #9
d2.insererBdd('f',1,1,1,9) #10
d2.insererBdd('f',1,1,1,15)#11
d2.insererBdd('g',1,2,1,3)

puts "TEST RECUPERER ET AFFICHER LE CONTENU DE TOUTES LA TABLE"
row = d2.recupererBdd()
print row

puts "\n\nTEST RECUPERER MEILLEUR SCORE"
row = d2.recupererHighscore(1,1,1)
for i in row
    puts i
end
