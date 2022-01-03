##
# Représente la grille de tutoriel avancée qui hérite de la GrilleUI.
# @author DUBIN Baptiste - MOTTIER Anaîs - RENARD Dorian - DEROUAULT Baptiste - TSAMARAYEV Moustapha
class GrilleTutoAvancee < GrilleUI
    ##
    # Ses variables d'instances sont :
    #   currentEvent        : Représente l’évènement/étape courant de tutoriel
    #   container           : Conteneur de type Gtk::Box qui contient deux autres conteneurs grille et tutoGrid
    #   tutoGrid            : Conteneur de type Gtk::Grid qui contient les widgets de l’interface de tutoriel
    #   stageDescriptor     : Description de l'évènement/étape courant
    #   etat                : Etat d'un bouton
    #   trigger             : Tableau stockant les positions des îles à faire clignoter
    #   tabTuto             : Tableau initialisant l'état des boutons du trigger
    #   etat                : Itérateur permettant de parcourir le tabTuto

    @Override
    ##
    # Re-définition : ne fait rien ici car l'on ne charge pas de sauvegarde.
    def restitue()
    end

    @Override
    ##
    # Re-définition : ne fait rien ici car l'on ne sauvegarde pas.
    def sauvegarde()
    end

    @Override
    ##
    # Re-définition de la méthode redo pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementRedo
        last = @redo.last
        Thread.new{
            until @trigger.include?(last)
                last = @redo.last
                if @trigger.include?(last)
                    @tabTuto[@trigger.index(last)] = false
                    @etape += 1
                    nextStage
                end
                super
                @etat = true
                relanceCheck
                sleep(0.3)
            end
        }
        self
    end

    ##
    # Méthode parcourant le trigger.
    def nextStage()
        if @currentEvent < 11
            @currentEvent+=1
        end
        @stageDescriptor.set_label($local["trigger_#{@currentEvent}"])
        return self
    end

    @Override
    ##
    # Re-définition de la méthode paramètre car le container ici n'est pas le même que dans grilleUI et nous devont indiquer que le bouton a été enclenché.
    # @return [Gtk::Button]
    def parametres()
        #Bouton parametres
        button = Gtk::Button.new(:label => "🔧")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            @window.remove(@container)
            Parametre.creer(@window,@container,$local["ingame"],self)
        }
        return button
    end

    @Override
    ##
    # Re-définition de la méthode quitter car le container ici n'est pas le même que dans grilleUI et nous devont indiquer que le bouton a été enclenché.
    def comportementQuitter()
        if @timer != nil
            sauvegarde
            stopThread
        end

        @currentEvent = -1
        @window.set_title($local["w_main_menu"])
        @window.remove(@container)
        @window.add(@fenetrePrec)
        @window.show_all
        return self
    end

    ##
    # Méthode permettant de faire clignoter les îles.
    def etat()
        Thread.new {
            while @tabTuto.include?(true)
                val = @trigger[@etape]
                @button[val[0]][val[1]].set_name("#{$theme}CircleGold")
                sleep(0.5)
                @button[val[0]][val[1]].set_name("#{$theme}Circle")
                sleep(0.5)
            end
        }
        return self
    end

    ##
    # Méthode permettant de faire clignoter les boutons.
    # @param button [Gtk::Button] Bouton a réactiver
    def boutonActiver(button)
        Thread.new{
            while !@etat
                button.set_name("#{$theme}BtnIconFocusTuto")
                sleep(0.5)
                button.set_name("#{$theme}BtnIcon")
                sleep(0.5)
            end
        }
        return self
    end

    ##
    # Méthode permettant de réactiver le bouton check à la fin du tutoriel.
    def relanceCheck()
        if @redo.empty?
            @etat=false
            boutonActiver(@btnCheck)
            @btnCheck.set_sensitive(true)
            @btnRedo.set_sensitive(false)
        end
        return self
    end

    @Override
    ##
    # Méthode d'initialisation pour la classe GrilleTutoAvancee.
    # @param file [String] le fichier contenant la grille
    # @param window [Gtk::Window] La fenêtre
	# @param fenetrePrec [Gtk::Container] Le container précédent
    def initialize(file, window, fenetrePrec)
        #Override
        @window = window
        @fenetrePrec = fenetrePrec
        @currentEvent=0
        @etat = false

        @window.set_title($local["ingame"])

        @undo=[]
        @redo=[]

        @sauvegarde = Sauvegarde.creer(file)

        @grid = Gtk::Grid.new

        timer = nil

        @window.signal_connect('destroy'){
            stopThread
            Gtk.main_quit
        }

        #On défini que toutes les colonnes sont homogènes
        @grid.set_column_homogeneous(@grid)
        @grid.set_row_homogeneous(@grid)
        #On met du padding entre les lignes
        @window.add(@grid)

        @grille = Grille.creer("#{file}.txt")
        @grille.chargerGrille
        @cases = @grille.cases
        gridJ = @grille.largeur
        gridI = @grille.hauteur


        delimitation(gridI,gridJ)
        gridI+=1
        @btnJouer = jouer

        @button = Array.new(@grille.hauteur) { Array.new(@grille.largeur) }

        (0..(@grille.hauteur - 1)).each { |i|
            (0..(@grille.largeur - 1)).each { |j|
                @button[i][j] = creerCase(i, j)
                @grid.attach(@button[i][j], j, i, 1, 1)
            }
        }

        @btnQuitter = quitter
        @grid.attach(@btnQuitter,gridJ+1,gridI,1,1)

        cptVertical = 0

        @btnParametres = parametres
        @grid.attach(@btnParametres,gridJ+1,cptVertical,1,1)

        hideBtn
        boutonActiver(@btnJouer)
        @btnJouer.signal_connect("clicked"){
            nextStage
            razBg
            setSensitiveBoutonsJeu(false)

            @buttonAfficher = creerButtonAfficher
            @buttonAfficher.set_sensitive(false)
            @timer = creerTimer
            @aides = Aides.creer(self)
            @buttonLancer = creerButtonLancer
            @buttonLancer.set_sensitive(false)
            @timer.reprendre
            @grid.attach(@buttonLancer,3,gridI, 1, 1)
            @grid.attach(@buttonAfficher, 4, gridI, 2, 1)

            @btnReset = reset
            @btnReset.set_sensitive(false)
            @grid.attach(@btnReset,gridJ-1,gridI,1,1)

            @verif = false
            @erreur = Erreur.creer(@cases)

            @btnShow = show
            @btnShow.set_sensitive(false)
            @grid.attach(@btnShow,1,gridI,1,1)
            rendreAccessibleShow

            @btnUndo = setUndo
            @btnUndo.set_sensitive(false)
            @grid.attach(@btnUndo,6,gridI,1,1)

            @btnRedo = setRedo
            @grid.attach(@btnRedo,7,gridI,1,1)
            boutonActiver(@btnRedo)

            @btnCheck = check
            @btnCheck.set_sensitive(false)
            @grid.attach(@btnCheck,0,gridI,1,1)


            cptVertical+=2

            #Utiliser cptVertical pour afficher a gauche

            @btnHypothese = hypothese
            @btnHypothese.set_sensitive(false)
            @grid.attach(@btnHypothese,gridJ+1,cptVertical,1,1)
            cptVertical+=1

            @btnBTHypothese = retourToHypothese
            @btnBTHypothese.set_sensitive(false)
            @grid.attach(@btnBTHypothese,gridJ+1,cptVertical,1,1)
            rendreAccessibleHypothese

            cptVertical+=2
            @btnHelp = help
            @btnHelp.set_sensitive(false)
            @grid.attach(@btnHelp,gridJ+1,cptVertical,1,1)

            gridI+=1
            @window.show_all
            @grid.remove(@btnJouer)

            restitue

            imagePourJeux("")

            etat
        }
        @grid.attach(@btnJouer,gridJ/2,gridI,1,1)
        @window.show_all

        @container = Gtk::Box.new(:vertical, 0)
        @window.remove(@grid)
        @window.add(@container)

        #Ajoute un panneau qui contient les informations relative à l'étape courant de tutoriel
        @window.set_title($local["ingame"])
        @tutoGrid = Gtk::Grid.new
        @stageDescriptor=Gtk::Label.new($local["trigger_#{@currentEvent}"])
        @stageDescriptor.set_name("#{$theme}Desc")
        @stageDescriptor.set_justify(2)
        @tutoGrid.attach(@stageDescriptor,2,0,7,3)
        @tutoGrid.set_column_homogeneous(true)
        @container.pack_start(@tutoGrid, :expand => false, :fill => false, :padding => 0)
        @container.pack_end(@grid, :expand => false, :fill => true, :padding => 0)
        @window.show_all

        @trigger = [[5,3],[5,0],[5,6],[8,3],[8,5],[5,8],[2,5],[3,0],[3,2],[0,2],[0,4]]
        @tabTuto = Array.new(@trigger.length, true)
        @etape = 0
        @redo = [[0, 7], [0, 4], [0, 5], [0, 5], [0, 2], [0, 3], [3, 2], [1, 2], [1, 2], [3, 0], [3, 1], [1, 0], [2, 0], [2, 5], [2, 3], [2, 4], [4, 5], [3, 5], [3, 5], [2, 8], [2, 7], [5, 8], [7, 8], [6, 8], [8, 5], [8, 7], [8, 6], [6, 5], [7, 5], [8, 3], [8, 4], [8, 1], [8, 2], [5, 6], [5, 7], [5, 7], [3, 6], [4, 6], [4, 6], [5, 0], [4, 0], [4, 0], [7, 0], [6, 0], [5, 3], [5, 4], [5, 4], [6, 3], [6, 3], [5, 2], [5, 2], [4, 3], [4, 3]]
    end

    @Override
    ##
    # Permet de mettre à jour le texte si la langue change.
    def refreshBtn()
        super()
        @stageDescriptor.set_name("#{$theme}Desc")
    end
end
