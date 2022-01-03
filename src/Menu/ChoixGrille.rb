##
# Classe permettante d'afficher le choix des grilles.
# @author GIROD Valentin
class ChoixGrille

	##
	# Permet de créer le container et l'affecter à la fenêtre.
	def creerFenetreEtFormat()
		#On défini que toutes les colonnes sont homogènes
	  	@grid.set_column_homogeneous(@grid)
	  	#On met du padding entre les lignes
	  	@grid.set_row_spacing(10)

	  	@window.add(@scroll)
	end

	##
	# Constructeur de la classe ChoixGrille.
    # @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
	# @param type_jeu [Integer] Le type de jeu
	# @param diffic [Integer] la difficulté du jeu
	# @param taille_grille [Integer] La dimension de la grille de jeu
	def ChoixGrille.creer(window,fenetre_prec,type_jeu, diffic, taille_grille)
		new(window,fenetre_prec,type_jeu, diffic, taille_grille)
	end

	##
	# Ré-définition de la méthode initialize.
    # @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
	# @param type_jeu [Integer] Le type de jeu
	# @param diffic [Integer] la difficulté du jeu
	# @param taille_grille [Integer] La dimension de la grille de jeu
	@Override
	def initialize(window,fenetre_prec, type_jeu, diffic, taille_grille)
		@window = window
		@fenetre_prec = fenetre_prec
		@scroll = Gtk::ScrolledWindow.new(nil, Gtk::Adjustment.new(0,0,0,0,0,0))
		@grid = Gtk::Grid.new
		creerFenetreEtFormat()
		@type_jeu = type_jeu
		@diffic = diffic
		@type_jeu = type_jeu
		@taille_grille = taille_grille
		@window.set_title($local['w_choix_grille'])
		posBoutonRetour = creerListeMaps()
		#Bouton au quitter et placement
		button = Gtk::Button.new(:label => $local["back"])
		button.set_name("#{$theme}BoutonChoixGrille")
		button.signal_connect("clicked"){
			@window.set_title($local['w_main_menu'])
			@window.remove(@scroll)
			@window.add(@fenetre_prec)
			@window.show_all
		}
		@grid.attach(button,0,posBoutonRetour[1],posBoutonRetour[0],1)
		@scroll.set_shadow_type(Gtk::ShadowType::NONE)
		@scroll.set_propagate_natural_width(true)
		@scroll.add_with_viewport(@grid)
		@scroll.child.set_shadow_type(Gtk::ShadowType::NONE)
		@window.show_all
	end

	##
	# Permet de créer la liste de toutes les grilles de jeu.
	# @return [Integer] La position en hauteur du bouton retour
	def creerListeMaps()
		largeur_fenetre = @window.size[0];
		taille_image = @taille_grille.split('x')[0].to_i*150/9
		#le -40 c'est pour la bordure ajoutée par la scrolledWindow, que je n'ai pas réussi à enlever
		nbBoutons = ((largeur_fenetre-100)/taille_image)
		cptBouton = 1
		posBoutonRetour = [nbBoutons,1]
		for j in 0..10 do
			for i in 1..nbBoutons do
				if(cptBouton <= 10)
					@grid.attach(boutonMap(cptBouton.to_s, taille_image),i-1,j,1,1)
					cptBouton+=1
				end
			end
			posBoutonRetour[1] += 1
		end
		return posBoutonRetour
	end

	##
	# Crée un bouton de lancement de map.
	# @param nom_fich [String] Le nom du fichier de la map à lancer
	# @return [Gtk::Grid] Contenant une image, une barre de progression et un bouton pour une map
	def boutonMap(nom_fich, taille_image)
		pixbuf =  GdkPixbuf::Pixbuf.new(:file => "./ressources/maps/#{@type_jeu}/#{@diffic}/#{@taille_grille}/#{nom_fich}.png")
		pixbuf = pixbuf.scale(taille_image, taille_image, :nearest)

		grid = Gtk::Grid.new
		grid.attach(Gtk::Image.new(:pixbuf=>pixbuf), 0, 0, 1, 1)
		if(@type_jeu.eql?"Freeplay")
			barre = BarreProgression.creer("./ressources/maps/#{@type_jeu}/#{@diffic}/#{@taille_grille}/#{nom_fich}").progression
			#impossible de modifier la taille minimum des barres de progressions
			#avec barre.set_size_request(1,2)
			#La taille des images a donc été augmentée pour correspondre à la barre
			grid.attach(barre, 0,1,1,1)
		end
		bouton = Gtk::Button.new(:label => nom_fich)
		bouton.set_name("#{$theme}BoutonChoixGrille")
		bouton.signal_connect("clicked"){
			@window.remove(@scroll)
			if(@type_jeu.eql?"Freeplay")
				GrilleUI.creer("./ressources/maps/#{@type_jeu}/#{@diffic}/#{@taille_grille}/#{nom_fich}",@window,@fenetre_prec)
			else
				GrilleClasseUI.creer("./ressources/maps/#{@type_jeu}/#{@diffic}/#{@taille_grille}/#{nom_fich}",@window,@fenetre_prec, @taille_grille, @diffic, nom_fich)
			end
		}
		grid.attach(bouton, 0,2,1,1)
		return grid
	end
	private_class_method:new
end
