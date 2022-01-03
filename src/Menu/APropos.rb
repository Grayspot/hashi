require 'yaml'

##
# Classe permettante d'afficher le module APropos du menu.
# @author GIROD Valentin
class APropos

	##
	# Permet de créer le container et l'affecter à la fenêtre.
	def creerFenetreEtFormat()
		  # On défini que toutes les colonnes sont homogènes
	  	@grid.set_column_homogeneous(@grid)
	  	# On met du padding entre les lignes
	  	@grid.set_row_spacing(10)

	  	@window.add(@grid)

		return self
	end

	##
	# Constructeur de la classe A propos.
    # @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
	def APropos.creer(window,fenetre_prec)
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

		@window.set_title("A propos - Hashi")


		titre = Gtk::Label.new($local["about_title"])
		titre.set_name("#{$theme}Title")
		texte = Gtk::Label.new($local["about"])
		texte.set_name("#{$theme}Text")
		texte.set_line_wrap(true)
		@grid.attach(titre,0,0,1,1)
		@grid.attach(texte,0,1,1,1)

		# Bouton au quitter et placement
		button = Gtk::Button.new(:label => $local["back"])
		button.set_name("#{$theme}Bouton")
		button.signal_connect("clicked"){
			@window.set_title("Menu Principal - Hashi")
			@window.remove(@grid)
			@window.add(@fenetre_prec)
			@window.show_all
		}
		@grid.attach(button,0,2,1,1)
		@window.show_all
	end

	private_class_method:new
end
