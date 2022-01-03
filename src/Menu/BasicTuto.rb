require 'gtk3'
require 'yaml'
require_relative "../Methode/outils.rb"
require_relative '../Grille/GrilleTutoBasique.rb'

##
# Représente un descriptif pour le jeu de hashi
class BasicTuto

    ##
    # Constructeur pour la classe de tutoriel basique.
    # @param window [Gtk::Window] la fenêtre du programme
    #	@param fenetrePrec [Gtk::Grid] Le container précédent
    def BasicTuto.creer(window,fenetrePrec)
        new(window,fenetrePrec)
    end

    @Override
    ##
    # Constructeur pour la classe de tutoriel basique.
    # @param window [Gtk::Window] la fenêtre du programme
    #	@param fenetrePrec [Gtk::Grid] Le container précédent
    def initialize(window,fenetrePrec)
        #######################
        # BASE INITIALIZATION #
        #######################

        @window = window
        @fenetrePrec = fenetrePrec
        @grid = Gtk::Grid.new
        @title = Gtk::Label.new($local["tutorial"])
        @title.set_name("#{$theme}Title")
        @grid.attach(@title,0,0,3,1)
        @grid.set_column_homogeneous(true)
        @grid.set_row_homogeneous(false)
        @grid.set_row_spacing(10)
        @window.set_title($local["mode_tutorial"])
        @window.add(@grid)

        ###################################
        # BUTTONS , LABELS  and VARIABLES #
        ###################################

        @currentEvent=0

        #TITLE - titre de la fenetre
        title=Gtk::Label.new("TUTORIAL")
        title.set_name("#{$theme}Title")
        @grid.attach(title, 0, 0, 3, 1)

        #PREVIEW - image
        @preview=Gtk::Button.new(:label=>"")
        @preview.set_name("#{$theme}Bt_tutorial_3")
        @preview.set_alignment(1,0.5)
        @grid.attach(@preview, 0, 1, 3, 1)

        #DESCRIPTION - description de l'etape
        @description=Gtk::Label.new($local["bt_rules"])
        @description.set_name("#{$theme}Text")
        @description.set_justify(2)
        @grid.attach(@description, 0, 2, 3, 1)

        #SUIVANT - permet de passer à l'etape suivant
        suivant = Gtk::Button.new(:label=>$local["next"])
        suivant.set_name("#{$theme}BoutonAdv")
        @grid.attach(suivant,1,3,1,1)

        #RETOUR - permet de passer à l'etape precedent
        btnReturn = Gtk::Button.new(:label => $local["back"])
        btnReturn.set_name("#{$theme}BoutonAdv")
        @grid.attach(btnReturn,1,5,1,1)

        #######################
        #      LISTENERS      #
        #######################

        #Passe à l'etape suivant. Si dernier etape, lance le tutoriel.
        suivant.signal_connect("clicked"){
            if(@currentEvent==5)
                @window.remove(@grid)
                GrilleTutoBasique.creer("./ressources/maps/Tutoriel/tutoBasique",@window,@fenetrePrec)
            else
                refresh(@preview,@description)
                @currentEvent+=1
            end
        }

        #Passe à l'etape suivant. Si premier etape, retourne dans le menu precedent.
        btnReturn.signal_connect("clicked"){
            if(@currentEvent==0)
                @window.set_title($local["w_main_menu"])
                @window.remove(@grid)
                @window.add(@fenetrePrec)
                @window.show_all
            else
                @currentEvent-=1
                refresh(@preview,@description)
            end
        }
        @window.show_all
    end

    ##
    # Méthode qui met à jour le texte et les images qui sont affichés à l'écran quand on passe à l'étape suivante/précedente.
    # @param image_preview [Gtk::Button] est l'image de preview de l'étape courante
    # @param description [Gtk::Button] correspond à la description de l'étape courante
    def refresh(image_preview, description)

        image_preview.set_name("#{$theme}Bt_tutorial_#{@currentEvent}")
        description.set_label($local["bt_rules_#{@currentEvent}"])

        return self
	end
  private_class_method:new
end
