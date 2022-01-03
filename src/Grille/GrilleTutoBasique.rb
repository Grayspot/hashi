require 'gtk3'

require_relative 'GrilleUI'

##
# Représente la grille de tutoriel basique qui hérite de la GrilleUI.
# @author Moustapha TSAMARAYEV
class GrilleTutoBasique < GrilleUI
    ##
    # Ses variables d'instances sont :
    # event_progression : Représente la progression de jouer dans le tutoriel
    # current_event     : Représente l’évènement/étape courant de tutoriel
    # container         : Conteneur de type Gtk::Box qui contient deux autres conteneurs grille et tuto_grid
    # tuto_grid         : Conteneur de type Gtk::Grid qui contient les widgets de l’interface de tutoriel
    # stage_descriptor  : Description de l'évènement/étape courant
    # 
    
    ##
    # Nombre d'étapes
    NBSTEP = 12

    @Override
    ##
    # Re-définit la méthode initialize.
    def initialize(file,window,fenetre_prec)
        
        @event_progression=Array.new(12,false)
        @file=file
        
        @window = window
        @fenetre_prec = fenetre_prec

        @window.set_title($local["w_tutorial"])

        @undo=[]
        @redo=[]

        @sauvegarde = Sauvegarde.creer(file)


        @grid = Gtk::Grid.new()

        timer = nil

        @window.signal_connect('destroy'){
            stopThread()
            Gtk.main_quit
        }

        #On défini que toutes les colonnes sont homogènes
        @grid.set_column_homogeneous(@grid)
        @grid.set_row_homogeneous(@grid)
        #On met du padding entre les lignes
        @window.add(@grid)

        @grille = Grille.creer("#{file}.txt")
        @grille.chargerGrille()
        @cases = @grille.cases
        gridJ = @grille.largeur
        gridI = @grille.hauteur


        delimitation(gridI,gridJ)
        gridI+=1
        @btnJouer = jouer()

        @button = Array.new(@grille.hauteur) { Array.new(@grille.largeur) }

        for i in 0..(@grille.hauteur-1)
            for j in 0..(@grille.largeur-1)
                @button[i][j] = creerCase(i, j)
                @grid.attach(@button[i][j],j,i,1,1)
            end
        end

        @btnQuitter = quitter()
        @grid.attach(@btnQuitter,gridJ+1,gridI,1,1)

        cptVertical = 0

        @btnParametres = parametres()
        @grid.attach(@btnParametres,gridJ+1,cptVertical,1,1)

        hideBtn()
        @btnJouer.signal_connect("clicked"){
            @event_progression[0]=true
            razBg()

            @buttonAfficher = creerButtonAfficher()
            @timer = creerTimer()
            @aides = Aides.creer(self)
            @buttonLancer = creerButtonLancer()
            @timer.reprendre()
            @grid.attach(@buttonLancer,3,gridI, 1, 1)
            @grid.attach(@buttonAfficher, 4, gridI, 2, 1)

            @btnReset = reset()
            @grid.attach(@btnReset,gridJ-1,gridI,1,1)

            @verif = false
            @erreur = Erreur.creer(@cases)

            @btnShow = show()
            @grid.attach(@btnShow,1,gridI,1,1)
            rendreAccessibleShow()

            @btnUndo = setUndo()
            @grid.attach(@btnUndo,6,gridI,1,1)

            @btnRedo = setRedo()
            @grid.attach(@btnRedo,7,gridI,1,1)

            @btnCheck = check()
            @grid.attach(@btnCheck,0,gridI,1,1)

            cptVertical+=2

            #Utiliser cptVertical pour afficher a gauche

            @btnHypothese = hypothese()
            @grid.attach(@btnHypothese,gridJ+1,cptVertical,1,1)
            cptVertical+=1

            @btnBTHypothese = retourToHypothese()
            @grid.attach(@btnBTHypothese,gridJ+1,cptVertical,1,1)
            rendreAccessibleHypothese()

            cptVertical+=2
            @btnHelp = help()
            @grid.attach(@btnHelp,gridJ+1,cptVertical,1,1)

            gridI+=1
            @window.show_all
            @grid.remove(@btnJouer)

            restitue()

            imagePourJeux("")
        }
        @grid.attach(@btnJouer,gridJ/2,gridI,1,1)
        @window.show_all

        #################################################################################
        #                       ADDITION TO THE INITIALIZE METHOD                       #
        # Impossible to use super() because of minor changements in base initialization #
        #################################################################################

        @current_event=0
        @container = Gtk::Box.new(:vertical, 0)
        @window.remove(@grid)
        @window.add(@container)
        
        #Ajoute un panneau qui contient les informations relative à l'étape courant de tutoriel
        @window.set_title($local["ingame"])
        @tuto_grid = Gtk::Grid.new()
        @stage_descriptor=Gtk::Label.new($local["bt_event_#{@current_event}"])
        @stage_descriptor.set_name("#{$theme}Desc")
        @stage_descriptor.set_justify(2)
        @tuto_grid.attach(@stage_descriptor,2,0,7,3)
        @tuto_grid.set_column_homogeneous(true)
        @container.pack_start(@tuto_grid, :expand => false, :fill => false, :padding => 0)
        @container.pack_end(@grid, :expand => false, :fill => true, :padding => 0)
        @window.show_all

        #Thread that handles events
        eventsThread()
        
    end

    ##
    # Incrémente la variable de l’étape courante ce qui permet au joueur d’avancer dans le tutoriel.
    def nextStage()
        if @current_event < 11
            @current_event+=1
        end
        @stage_descriptor.set_label($local["bt_event_#{@current_event}"])

        return self
    end

    @Override
    ##
    # Re-définition de la méthode paramètre car le container ici n'est pas le même que dans grilleUI et nous devons indiquer que le bouton a été enclenché.
    # @return [Gtk::Button]
    def parametres()
        #Bouton parametres
        button = Gtk::Button.new(:label => "🔧")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            @window.remove(@container)
            Parametre.creer(@window,@container,$local["ingame"],self)
            @event_progression[10]=true
        }
        return button
    end

    @Override
    ##
    # Re-définition de la méthode quitter car le container ici n'est pas le même que dans grilleUI et nous devons indiquer que le bouton a été enclenché.
    def comportementQuitter()
        if(@timer != nil)
            sauvegarde()
            stopThread()
        end

        @current_event = -1
        @event_progression[11]=true

        @window.set_title($local["w_main_menu"])
        @window.remove(@container)
        @window.add(@fenetre_prec)
        @window.show_all

        return self
    end
    
    @Override
    ##
    # Re-définition de la méthode retour à l'hypothèse pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementRetourToHypothese()
        super
        @event_progression[9]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode hypothèse pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementHypothese()
        super
        @event_progression[8]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode aides pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementHelp()
        super
        @event_progression[7]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode lancer pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementLancer()
        super
        @event_progression[6]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode remise à zéro pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementReset()
        super
        @event_progression[5]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode redo pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementRedo()
        super
        @event_progression[4]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode undo pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementUndo()
        super
        imagePourJeux("")
        @event_progression[3]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode check pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementCheck()
        super
        @event_progression[1]=true
        return self
    end

    @Override
    ##
    # Re-définition de la méthode montrer pour détecter que l'on a bien cliqué sur ce bouton.
    def comportementShow()
        super
        @event_progression[2]=true
        return self
    end

    @Override
    ##
    # Re-définition : ne fait rien ici car l'on ne charge pas de sauvegarde.
    def restitue()
        #Ne fait rien ici
    end

    @Override
    ##
    # Re-définition : ne fait rien ici car l'on ne sauvegarde pas.
    def sauvegarde()
        #Ne fait rien ici
    end

    ##
    # Permet de désactiver ou d'activer tous les boutons.
    # @param type [Boolean] Boolean de choix
    def setSensitiveButtons(type)
        #Désactive tous les boutons commandes
            @btnCheck.set_sensitive(type)
            @btnShow.set_sensitive(type)
            @btnUndo.set_sensitive(type)
            @btnRedo.set_sensitive(type)
            @btnReset.set_sensitive(type)
            @btnHypothese.set_sensitive(type)
            @btnBTHypothese.set_sensitive(type)
            @btnHelp.set_sensitive(type)
            @btnParametres.set_sensitive(type)
            @buttonAfficher.set_sensitive(type)
        
        #Désactive tous les boutons de jeu
            size = @button.length
            for i in 0..(size-1)
                for j in 0..(size-1)
                    @button[i][j].set_sensitive(type)
                end
            end

        return self
    end

    ##
    # Permet de faire fonctionnner le tutoriel, en faisant clignoter les boutons chacun leur tour afin de faire découvrir à l'utilisateur toutes les commandes.
    def eventsThread()
        @tabAides = [@btnJouer]

        #Thread du tuto
        @thread = Thread.new{
            i = 0
            for i in 0..(NBSTEP-1)
                #Permet la préparation de la démonstration
                if i == 1
                    @button[4][1].clicked()
                    @button[4][1].clicked()
                elsif i == 8
                    @button[4][1].clicked()
                    @button[4][1].clicked()
                elsif i == 9
                    sleep(0.2)
                    @button[4][3].clicked()
                    sleep(0.2)
                    @button[3][2].clicked()
                    sleep(0.2)
                    @button[5][2].clicked()
                    sleep(0.2)
                    @button[1][4].clicked()
                    sleep(0.2)
                    @button[1][6].clicked()
                    sleep(0.2)
                end

                @tabAides[i].set_sensitive(true)
                #Permet de faire clignoter le boutons
                while @event_progression[i] == false
                    @tabAides[i].set_name("#{$theme}BtnIconFocus")
                    sleep(0.5)
                    @tabAides[i].set_name("#{$theme}BtnIcon")
                    sleep(0.5)
                end
                if(i == 0)
                    @tabAides = [@btnJouer,@btnCheck,@btnShow,@btnUndo,@btnRedo,@btnReset,@buttonLancer,@btnHelp,@btnHypothese,@btnBTHypothese,@btnParametres,@btnQuitter]
                    setSensitiveButtons(false)
                end
                nextStage()
            end
        }
        return self
    end

end

