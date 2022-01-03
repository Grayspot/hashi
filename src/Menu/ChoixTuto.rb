require 'gtk3'
require 'yaml'
require_relative "../Methode/outils.rb"
require_relative "../Menu/BasicTuto.rb"
require_relative '../Grille/GrilleTutoBasique.rb'
require_relative "../Grille/GrilleTutoAvancee.rb"

##
# Classe permettante d'afficher le sélecteur du mode aventure.
# @author Moustapha TSAMARAYEV
class ChoixTuto

    # Constructeur de la classe Parametre
    # @param window [Gtk::Window] Fenêtre
    # @param fenetre_prec [Gtk::Grid] Le container précédent
    def ChoixTuto.creer(window,fenetre_prec)
        new(window,fenetre_prec)
    end

    @Override
    ##
    # Rédéfinition de la méthode initialize.
    # @param window [Gtk::Window] Fenêtre
    # @param fenetre_prec [Gtk::Grid] Le container précédent 
    def initialize(window,fenetre_prec)
        #######################
        # BASE INITIALIZATION #
        #######################

        @window = window

        taille = @window.size()[0]

        @fenetre_prec = fenetre_prec
        @grid = Gtk::Grid.new
        @title = Gtk::Label.new($local["tutorial"])
        @title.set_name("#{$theme}Title")
        @grid.attach(@title,0,0,3,1)
        @grid.set_column_homogeneous(true)
        @grid.set_row_homogeneous(true)
        @grid.set_row_spacing(10)
        @window.set_title($local["w_tutorial"])
        @title = Gtk::Label.new($local["tutorial_title"])
        @window.add(@grid)


        #######################
        # BUTTONS and LABELS  #
        #######################

        #Titre de menu courant
        @title.set_name("#{$theme}Title")
        @grid.attach(@title, 0, 0, 3, 1)

        #Texte de description
        description=Gtk::Label.new($local["tutorial_description"])
        description.set_name("#{$theme}Text")
        description.set_justify(2)
        @grid.attach(description, 0, 1, 3, 1)

        #Bouton qui permet de lancer le tuto basique
        basic = Gtk::Button.new(:label=>$local["basicTitle"])
        basic.set_name("#{$theme}BoutonAdv")
        @grid.attach(basic,1,2,1,1)

        #Bouton qui permet de lancer le tuto avancée
        advanced = Gtk::Button.new(:label=>$local["advancedTitle"])
        advanced.set_name("#{$theme}BoutonAdv")
        @grid.attach(advanced,1,3,1,1)

        #Bouton 'retour'
        btnReturn = Gtk::Button.new(:label => $local["back"])
        btnReturn.set_name("#{$theme}BoutonAdv")
        @grid.attach(btnReturn,1,5,1,1)

        #######################
        #      LISTENERS      #
        #######################

        #Bouton 'tuto basique'
        basic.signal_connect("clicked"){
            @window.remove(@grid)
            BasicTuto.creer(@window,@grid)
        }

        #Bouton 'tuto avancée'
        advanced.signal_connect("clicked"){
            @window.remove(@grid)
            GrilleTutoAvancee.creer("./ressources/maps/Tutoriel/mapTuto",@window,@grid)
        }

        #Bouton 'retour'
        btnReturn.signal_connect("clicked"){
            @window.set_title($local["w_main_menu"])
            @window.remove(@grid)
            @window.resize(taille,taille)
            @window.add(@fenetre_prec)
            @window.show_all
        }
        @window.show_all
    end
    private_class_method:new
end
