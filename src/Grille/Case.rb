##
# Classe abstraite représentant chaque entités de la grille de jeu.
# @author DEROUAULT Baptiste
class Case
	##
	#	Les variables d'instances sont :
	#	x    		: La coordonnée abscisse de la case
	#	y  			: La coordonnée ordonnée de la case
	#	grille		: Grille à laquelle appartient la case
	#	carac		: La caractère qui décrit la case
	#   nbLiens 	: Le nombre de lien courant sur la case
	#   typeCourant : Le type de lien courant de la case

	##
	#	Représente le caractère représentant la case
  	attr_reader:carac
	##
	#	Cordonnée abscisse de la case
 	attr_reader:x
	##
	#	Cordonnée ordonné de la case
  	attr_reader:y

	##
	# Re-définition de la méthode initialize.
	# @param x [Integer] La coordonnée abscisse de la case
	# @param y [Integer] La coordonnée ordonnée de la case
	# @param carac [Charactere] Le caractère qui décrit la case
	# @param grille [Grille] Grille à laquelle appartient la case
	@Override
	def initialize(x, y, carac, grille)
		@x, @y, @carac, @grille = x, y, carac, grille
		@nbLiens = 0
	end

	##
	# Constructeur de la classe case.
	# @param x [Integer] La coordonnée abscisse de la case
	# @param y [Integer] La coordonnée ordonnée de la case
	# @param carac [Charactere] Le caractère qui décrit la case
	# @param grille [Grille] Grille à laquelle appartient la case
	def Case.creer(x,y,carac,grille)
		new(x,y,carac,grille)
	end

	##
	# Permet d'ajouter un lien à la case.
	def ajouterLien()
		@nbLiens+=1
		return self
	end

	##
	# Permet de remettre à zéro le nombre de lien de la case.
	def resetLien()
		@nbLiens= 0
		@typeCourant=""
		return self
	end

	##
	# Permet d'enlever un lien à la case.
	def enleverLien()
		if(@nbLiens >0)
			@nbLiens-=1
		end
		return self
	end

	##
	# Verifie si la case est une instance de "lien".
	# @return [boolean] Faux par défaux
	def estLien?()
		return false
	end

	##
	# Verifie si la case est une instance de "Ile".
	# @return [boolean] Faux par défaux
	def estIle?()
		return false
	end


	@Override
	##
	# Re-définition de la method to_s permettant d'afficher.
	def to_s
		return carac
	end

	private_class_method:new
end