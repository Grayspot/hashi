require_relative 'Bdd.rb'
require_relative '../Methode/outils.rb'
require 'gtk3'

##
# Représente l'affichage du classement.
# @author DEROUAULT Baptiste
class Classement
	##
	#	Les variables d'instances sont :
	#	grid    		: Le container grid du classement
	#	window  		: La fenêtre
	#	fenetre_prec	: Le container précédent
	#	ligneClassement	: La liste de tous les labels pour le classement
	#	pseudoClassement: La liste de tous les pseudo
	#	tempsClassement	: La liste de tous les temps

	##
	# Permet de créer le container et l'affecter à la fenêtre.
	def creerFenetreEtFormat()
		#On défini que toutes les colonnes sont homogènes
	  	@grid.set_column_homogeneous(true)
	  	#On met du padding entre les lignes
	  	@grid.set_row_spacing(10)
		#On ajoute le container à la fenêtre
	  	@window.add(@grid)

		return self
	end

	##
	# Permet d'initialiser les lignes du classement.
	def initialiserLignesClassement()
		#Défini les couleurs des trois premiers
		gold = Gdk::RGBA.new(1,0.843,0,1)
		bronze = Gdk::RGBA.new(0.804,0.498,0.196,1)
		silver = Gdk::RGBA.new(0.753,0.753,0.753,1)

		color = []
		color << gold
		color << silver
		color << bronze

		##
		#	Permet d'initialiser et créer les 10 lignes de classements, position - pseudo - temps
		for i in (1..10)
			@ligneClassement[i].set_text("#{i}")

			@grid.attach(@ligneClassement[i], 0,i+1, 1, 1)

			@pseudoClassement[i].set_text("-")
			@grid.attach(@pseudoClassement[i], 1, i+1, 1, 1)

			@tempsClassement[i].set_text("-")
			@grid.attach(@tempsClassement[i], 2, i+1, 1, 1)

			#Permet de donner une couleur pour les trois premiers : gold silver bronze
			if(i<4)
				@ligneClassement[i].override_background_color(:normal, color[i-1])
				@pseudoClassement[i].override_background_color(:normal, color[i-1])
				@tempsClassement[i].override_background_color(:normal, color[i-1])
			end
		end

		return self
	end

	##
	# Permet de mettre à jour les lignes du classement.
	def reinitialiserLignesClassement()
		for i in (1..10)
			@ligneClassement[i].set_text("#{i}")
			@pseudoClassement[i].set_text("-")
			@tempsClassement[i].set_text("-")
		end

		return self
	end

	##
	# Permet de créer les lignes du classement avec une difficulté et un niveau donné.
	# @param diff [Integer] La difficulté
	# @param niveau [Integer] Le niveau
	def creerLignesClassement(diff, niveau, taille)
		bdd = Bdd.creer("ranked.bdd")
		bdd.creerBdd();
		row = bdd.recupererHighscore(diff,niveau,taille)
		cpt = 1

		reinitialiserLignesClassement()

		##
		#	Permet de créer les 10 lignes de classements en fonction du résultat de la base de données
		for i in row
			@ligneClassement[cpt].set_text("#{cpt}")
			@pseudoClassement[cpt].set_text("#{i['pseudo']}")
			@tempsClassement[cpt].set_text("#{i['temps']}")
			cpt += 1
		end

		return self
	end

	##
	# Permets de construire le container du classement avec une fenêtre donnée et le container précédent.
	# @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
	def Classement.creer(window,fenetre_prec)
		new(window,fenetre_prec)
	end

	@Override
	##
	# Rédéfinition de la méthode initialize.
	# @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
	def initialize(window,fenetre_prec)
		@window = window
		@fenetre_prec = fenetre_prec

		@grid = Gtk::Grid.new
		creerFenetreEtFormat()

		@window.set_title($local["w_ranked"])


		#Création de la liste des difficultés
		difficultes = [$local["lvl_easy"],$local["lvl_medium"],$local["lvl_difficult"]]
		listeDiff = creerListeComboText(difficultes)
		@grid.attach(listeDiff,0,0,1,1)

		#Création de la liste des niveaux
		niveau = []

		#Créer le choix du niveau
		for i in 1..10
			niveau << "#{$local["level"]} #{i}"
		end
		listeNiv = creerListeComboText(niveau)
		@grid.attach(listeNiv,1,0,1,1)


		#Créer le choix de la taille
		tailles = ["9x9","13x13","17x17"]
		listeTaille = creerListeComboText(tailles)
		@grid.attach(listeTaille,2,0,1,1)

		#Créer tous les champs des résultats
		@ligneClassement = []
		@pseudoClassement = []
		@tempsClassement = []
		for i in 1..10
			@ligneClassement[i] = Gtk::Label.new()
			@pseudoClassement[i] = Gtk::Label.new()
			@tempsClassement[i] = Gtk::Label.new()

			if(i>3)
				@pseudoClassement[i].set_name("#{$theme}Text")
				@ligneClassement[i].set_name("#{$theme}Text")
				@tempsClassement[i].set_name("#{$theme}Text")
			end
		end

		initialiserLignesClassement()

		bdd = Bdd.creer("ranked.bdd")
		bdd.creerBdd();
		#Bouton permettant de remettre à zéro le classement
		btnReset = Gtk::Button.new(:label => $local["raz"])
		btnReset.set_name("#{$theme}Bouton")
		@grid.attach(btnReset, 0, 19, 3, 1)

		#Bouton pour afficher en fonction de l'etat des deux listes deroulantes
		btnAfficher = Gtk::Button.new(:label => $local["display"])
		btnAfficher.set_name("#{$theme}Bouton")
		btnAfficher.signal_connect("clicked"){
				creerLignesClassement(listeDiff.active+1, listeNiv.active+1, listeTaille.active+1)
				window.show_all
		}
		@grid.attach(btnAfficher, 0, 20, 3, 1)

		btnReset.signal_connect("clicked"){
			bdd.clearRecords(listeDiff.active+1, listeNiv.active+1, listeTaille.active+1)
			btnAfficher.clicked
			window.show_all
		}
		

		#Resultat de l'affichage du classement
		ligne = Gtk::Label.new()
		ligne.set_name("#{$theme}Text")
		ligne.set_text($local["leaders"])
		@grid.attach(ligne, 0, 1, 1, 1)

		pseudo = Gtk::Label.new()
		pseudo.set_text($local["nickname"])
		pseudo.set_name("#{$theme}Text")
		@grid.attach(pseudo, 1, 1, 1, 1)

		temps = Gtk::Label.new()
		temps.set_text($local["time"])
		temps.set_name("#{$theme}Text")
		@grid.attach(temps, 2, 1, 1, 1)


		#Bouton au quitter et placement
		button = Gtk::Button.new(:label => $local["back"])
		button.set_name("#{$theme}Bouton")
		button.signal_connect("clicked"){
			@window.set_title($local["w_main_menu"])
			@window.remove(@grid)
			@window.add(@fenetre_prec)
			@window.show_all
		}

		@grid.attach(button,0,21,3,1)
		btnAfficher.clicked
		@window.show_all
	end

	private_class_method:new
end

