require 'gtk3'
require 'yaml'
require_relative "../Classement/Classement.rb"
require_relative "../Methode/outils.rb"
require_relative "../Grille/GrilleUI.rb"
require_relative "APropos.rb"
require_relative "Parametre.rb"
require_relative "Adventure.rb"
require_relative "ChoixGrille.rb"
require_relative "ChoixTuto.rb"
require_relative "../Grille/GrilleClasseUI.rb"
require_relative "../Grille/GrilleTutoAvancee"
require_relative "BarreProgression.rb"


##
# Classe permettante d'afficher le menu principale.
# @author DEROUAULT Baptiste - GIROD Valentin - TSAMARAYEV Moustapha
class MenuPrincipal

	#LANGUES
	$lang
	$local
	#PARAMETRES VISUELS
	$theme

	##
	# Définit le titre du menu principal, en gros et en haut de la fenêtre.
	def setTitle()
		@@title = Gtk::Label.new($local["game_title"])
		@@title.set_name("#{$theme}Title")
		@box.attach(@@title,0,0,3,1)

		return self
	end

	##
	# Crée le bouton jouer, qui se remplace par le menu de sélection de type de jeu quand on clique dessus, et remplace le bouton "quitter" par un bouton "retour".
	def setJouer()
		@@jouer = creerBoutonBasique($local["play_mode"])

		@@jouer.signal_connect("clicked"){
			@box.remove(@@jouer)
			@box.remove(@@quitter)
			@box.attach(@selecJeu,0,1,3,1)
			@box.attach(@@retour,1,5,1,1)
			@window.show_all
		}

		@box.attach(@@jouer,1,1,1,1)

		return self
	end

	##
	# Crée le bouton retour, qui enlève tous les sous-menus du bouton jouer et ré-affiche le bouton jouer.
	# Se remplace lui-même par le bouton quitter au clique.
	def setRetour()
		@@retour = creerBoutonBasique($local["back"])

		@@retour.signal_connect("clicked"){
			@box.remove(@selecJeu)
      		@box.remove(@selecDiff)
      		@box.remove(@selecTaille)
			@box.remove(@@retour)
			setSelectionJeu()
			setSelectionDifficulte()
			setSelectionTaille()
			@box.attach(@@jouer,1,1,1,1)
			@box.attach(@@quitter,1,5,1,1)
			@window.show_all
		}

		return self
	end

	##
	# Crée le menu de sélection de jeu (tuto, jeu libre, Aventure, Classé), qui se replace par le menu de sélection de difficulté de grille si on clique sur "classé" ou "jeu libre", ou lance le mode tutoriel ou aventure.
	def setSelectionJeu()
		@selecJeu = Gtk::Grid.new()
		@selecJeu.set_column_homogeneous(true)
		@selecJeu.set_row_homogeneous(true)
		@selecJeu.set_row_spacing(10)

		@@tutoriel = creerBoutonSelectionJeu(nil, "mode_tutorial", 0)
		@@freeplay = creerBoutonSelectionJeu("Freeplay", "mode_freeplay", 2)
		@@aventure = creerBoutonSelectionJeu(nil, "mode_adv", 1)
		@@classe = creerBoutonSelectionJeu("Classe", "mode_rank", 3)
		return self
	end

	##
	# Crée et renvoit un bouton de type de jeu pour le menu de sélection de jeux.
	# @param type_jeu [String] le type de jeu
	# @param texte_bouton [String] le texte à afficher sur le bouton
	# @param coordonnee [Integer] la coordonnée horizontale pour le bouton dans le menu de sélection de jeu
	# @return [Gtk::Button] un bouton qui démarre un type de jeu désiré
	def creerBoutonSelectionJeu(type_jeu, texte_bouton, coordonnee)
		bouton = creerBoutonBasique($local[texte_bouton])
		@selecJeu.attach(bouton, coordonnee,0,1,1)
		if(texte_bouton.eql?("mode_adv"))
			bouton.signal_connect("clicked"){
				@window.remove(@box)
				Adventure.creer(@window,@box)
			}
		elsif(texte_bouton.eql?("mode_tutorial"))
			bouton.signal_connect("clicked"){
				@window.remove(@box)
				ChoixTuto.creer(@window,@box)
			}
		else
	    bouton.signal_connect("clicked"){
				@box.remove(@selecJeu)
				@box.attach(@selecDiff,0,1,3,1)
				@mode_de_jeu = type_jeu
				@window.show_all
	    }
		end
		return bouton
	end

	##
	# Crée le menu de sélection de difficulté (facile, moyen, difficile). Se replace par le menu de sélection de taille de grille une fois qu'on a choisit la difficulté.
	def setSelectionDifficulte()
		@selecDiff = Gtk::Grid.new()
		@selecDiff.set_column_homogeneous(true)
		@selecDiff.set_row_homogeneous(true)
		@selecDiff.set_row_spacing(10)
		@@facile = creerBoutonSelectionDiff("Easy", "lvl_easy", 0)
		@@moyen = creerBoutonSelectionDiff("Medium", "lvl_medium", 1)
		@@difficile = creerBoutonSelectionDiff("Hard", "lvl_difficult", 2)
		return self
	end

	##
	# Crée et renvoit un bouton de difficulté pour le menu de sélection de difficulté.
	# @param difficulte [String] le type de difficulté
	# @param texte_bouton [String] le texte à afficher sur le bouton
	# @param coordonnee [Integer] la coordonnée horizontale pour le bouton dans le menu de sélection de jeu
	# @return [Gtk::Button] un bouton qui permet de choisir une difficulté
	def creerBoutonSelectionDiff(difficulte, texte_bouton, coordonnee)
		bouton = creerBoutonBasique($local[texte_bouton])

		@selecDiff.attach(bouton,coordonnee,0,1,1)
		bouton.signal_connect("clicked"){
			@box.remove(@selecDiff)
			@box.attach(@selecTaille, 0,1,3,1)
			@difficulte = difficulte
			@window.show_all
		}
		return bouton
	end

	##
	# Crée le menu de sélection de taille (7x7, 15x15, 25x25). Lance le menu de choix de grille une fois la difficulté choisit.
	def setSelectionTaille()
		@selecTaille = Gtk::Grid.new()
		@selecTaille.set_column_homogeneous(true)
		@selecTaille.set_row_homogeneous(true)
		@selecTaille.set_row_spacing(10)

		creerBoutonSelectionTaille("9x9", 0)
		creerBoutonSelectionTaille("13x13", 1)
		creerBoutonSelectionTaille("17x17", 2)
		return self
	end

	##
	# Crée et renvoit un bouton de taille pour le menu de sélection de taille de grille.
	# @param taille [Integer] la taille des grilles à afficher
	# @param coordonnee [Integer] la coordonnée horizontale pour le bouton dans le menu de sélection de jeu
	# @return [Gtk::Button] un bouton qui permet de choisir une taille de grille
	def creerBoutonSelectionTaille(taille, coordonnee)
		bouton = creerBoutonBasique(taille)
		@selecTaille.attach(bouton,coordonnee,0,1,1)
		bouton.signal_connect("clicked"){
			@window.remove(@box)
			ChoixGrille.creer(@window, @box, @mode_de_jeu, @difficulte, taille)
		}
		return self
	end

	##
	# Crée un bouton avec le texte définit et l'id CSS bouton.
	# @param texte [String] Le texte à afficher sur le bouton
	# @return un Gtk:Button basique
	def creerBoutonBasique(texte)
		bouton = Gtk::Button.new(:label=>texte)
		bouton.relief = Gtk::ReliefStyle::NONE
		bouton.set_name("#{$theme}Bouton")
		return bouton
	end

	##
	# Crée un bouton pour les sous-menus du menu principal, qui vont cacher le menu principal et afficher le menu choisit quand on va cliquer dessus.
	# @param texte_bouton [String] l'id du texte à afficher dans le bouton, qui va ^etre pris depuis le fichier de langue
	# @param classe [Integer] la classe du sous-menu correspondant
	# @param coordonnee [Integer] la coordonnée en hauteur du sous-menu
	# @return [Gtk::Button]
	def creerSousMenu(texte_bouton, classe, coordonnee)
		bouton = creerBoutonBasique($local[texte_bouton])
		if(classe.eql?(Parametre))
			bouton.signal_connect("clicked"){
				@window.remove(@box)
				classe.creer(@window,@box,$local["w_main_menu"],self)
			}
		else
			bouton.signal_connect("clicked"){
				@window.remove(@box)
				classe.creer(@window,@box)
			}
		end
		@box.attach(bouton,1,coordonnee,1,1)
		return bouton
	end

	##
	# Crée le bouton quitter.
	def setQuitter()
		@@quitter = creerBoutonBasique($local["exit"])
		@@quitter.signal_connect("clicked"){
			Gtk.main_quit
		}
		@box.attach(@@quitter,1,5,1,1)

		return self
	end

	##
	# Crée la fenêtre principale.
	@Override
	def initialize()

		Gtk.init
		@window = Gtk::Window.new()
		@window.set_default_size(600,600)
		@window.set_border_width(30)
		@window.set_resizable(false)
		chargerParametres()
		@window.set_title($local["w_main_menu"])
		@widthX = @window.size()[0]
		@widthY = @window.size()[1]
		@window.signal_connect('destroy'){
            @@quitter.clicked
        }

		@window.set_name($theme)

        # CSS
        provider = Gtk::CssProvider.new
		path="./ressources/providers/light.css"
		provider.load_from_path(path)

        Gtk::StyleContext.add_provider_for_screen(Gdk::Screen.default,
                                                    provider,
                                                    Gtk::StyleProvider::PRIORITY_APPLICATION)

		#On crée le layout
		@box = Gtk::Grid.new()
		@box.set_row_spacing(20)
		@box.set_column_homogeneous(true)
		@box.set_row_homogeneous(true)

		@window.add(@box)
		setTitle()
		setJouer()
		@@parametres = creerSousMenu("settings", Parametre, 3)
		@@classement = creerSousMenu("leaders",Classement, 2)
		@@aPropos = creerSousMenu("about_title", APropos, 4)
		setQuitter()
		setSelectionJeu()
    	setSelectionDifficulte()
    	setSelectionTaille()
		setRetour()

		@window.set_window_position(Gtk::WindowPosition::CENTER_ALWAYS)

		@window.set_icon("ressources/icone/hashi.svg")
		@window.show_all

		Gtk.main
	end

  	##
  	# Charge les paramètres du jeu (la langue et la résolution).
	def chargerParametres
		if(!File.file?("./ressources/parametres.yml"))
			actualRes = "#{@window.size[0]}x#{@window.size[1]}"
			param = {"resolution"=>actualRes, "langue"=>"fr", "theme"=>"light", "fullScreen"=>false}
			File.new("./ressources/parametres.yml", "w")
			File.open("./ressources/parametres.yml", "w") { |file| file.write(param.to_yaml) }
			$lang=param['langue']
			$theme=param['theme']
			$local=YAML.load(File.read("./ressources/localisation/#{$lang}.yml"))

		else
		param =  YAML.load(File.read("./ressources/parametres.yml"))
		$lang=param['langue']
		$theme=param['theme']
		$local=YAML.load(File.read("./ressources/localisation/#{$lang}.yml"))
		if(param["fullScreen"])
			@window.fullscreen
		else
			@window.unfullscreen
			@window.resize(param["resolution"].split("x")[0].to_i, param["resolution"].split("x")[1].to_i)
		end
		end
		return self
	end

	##
	# Permet d'actualiser le css et les labels de chacun des boutons
	def self.refreshBtn()
		@@title.label = $local["game_title"]
		@@title.set_name("#{$theme}Title")
		@@classement.set_label($local["leaders"])
		@@classement.set_name("#{$theme}Bouton")
		@@jouer.set_label($local["play_mode"])
		@@jouer.set_name("#{$theme}Bouton")
		@@retour.set_label($local["back"])
		@@retour.set_name("#{$theme}Bouton")
		@@tutoriel.set_label($local["mode_tutorial"])
		@@tutoriel.set_name("#{$theme}Bouton")
		@@freeplay.set_label($local["mode_freeplay"])
		@@freeplay.set_name("#{$theme}Bouton")
		@@aventure.set_label($local["mode_adv"])
		@@aventure.set_name("#{$theme}Bouton")
		@@classe.set_label($local["mode_rank"])
		@@classe.set_name("#{$theme}Bouton")
		@@facile.set_label($local["lvl_easy"])
		@@facile.set_name("#{$theme}Bouton")
		@@moyen.set_label($local["lvl_medium"])
		@@moyen.set_name("#{$theme}Bouton")
		@@difficile.set_label($local["lvl_difficult"])
		@@difficile.set_name("#{$theme}Bouton")
		@@parametres.set_label($local["settings"])
		@@parametres.set_name("#{$theme}Bouton")
		@@aPropos.set_label($local["about_title"])
		@@aPropos.set_name("#{$theme}Bouton")
		@@quitter.set_label($local["exit"])
		@@quitter.set_name("#{$theme}Bouton")
		return self
	end

	##
	# Permet d'actualiser le style de tous les sélecteurs.
	def refreshBtn()
		setSelectionTaille()
	end

end
