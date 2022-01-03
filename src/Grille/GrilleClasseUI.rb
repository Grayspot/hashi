require_relative "AidesClasse.rb"
##
# Représente la grille du jeu en mode classé héritant de la classe GrilleUI.
#	Autheur : DEROUAULT Baptiste
class GrilleClasseUI < GrilleUI
  ##
  # Ses variables d'instances sont :
  # addCheck : Correspond à l'ajout du temps pour la vérification
  # addShow  : Correspond à l'ajout du temps pour montrer
  # addAidesBasic : Correspond à l'aide basique
  # addAidesIsolation : Correspond à l'aide basique
  # addAidesAvancee: Correspond à l'aide basique
  # bdd : Correspond à la base donnée
  # taille : La taille
  # diff : La difficulté
  # niveau : Le niveau

  ##
  # Pénalité en cas d'une vérification fausse
  PENCHECK = 5
  ##
  # Pénalité pour montrer les erreurs
  PENSHOW = 15


  ##
  # Permet d'initialiser les variables pour la sauvegarde du score dans le classement.
  # @param taille [String] La taille de la grille
  # @param diff [String] La difficulté de la grille
  # @param niveau [Integer] Le niveau de la grille
  def initClassement(taille, diff, niveau)
    case diff
    when "Easy"
      @diff = 1
    when "Medium"
      @diff = 2
    when "Difficult"
      @diff = 3
    end

    @niveau = niveau

    case taille
    when "9x9"
      @taille = 1
    when "13x13"
      @taille = 2
    when "17x17"
      @taille = 3
    end

    return self
  end

  @Override
  ##
  # Ne fait rien ici.
  def restitue()
    #Ne fait rien en classé
  end

  @Override
  ##
  # Ne fait rien ici.
  def sauvegarde()
    #Ne fait rien ici
  end

  @Override
  ##
  # Permet de proposer au joueur s'il veut sauvegarder son score.
  def finPartie()
    if(popup_message(@window,true,$local["sauvegarde"]) == 1)
      pseudo = pseudoVictoire()
      @bdd.insererBdd(pseudo,@niveau,@diff,@taille,@timer.temps)
    end
    @btnQuitter.clicked

    return self
  end 

  ##
  # Demande à l'utilisateur de rentrer un pseudo.
  # @param title [String] Le titre de la boîte de dialogue
  def entrerPseudo(title)
    @dialog = Gtk::Dialog.new
    @dialog.title = title
    @dialog.transient_for = @window

    entry =  Gtk::Entry.new()

    @dialog.child.add(entry)

    @dialog.add_button("OK", Gtk::ResponseType::OK)

    @dialog.signal_connect("response") do |widget, response|
      case response
      when Gtk::ResponseType::OK
        @pseudo = entry.text()
      end  
    end
    @dialog.show_all
    @dialog.run
    @dialog.destroy

    return self
  end

  ##
  # Pseudo de l'utilisateur.
  # @return [String]
  def pseudoVictoire()
    @pseudo = ""
    while(@pseudo.length == 0)
      entrerPseudo($local["pseudo"])
    end

    return @pseudo
  end

  @Override
  ##
  # Re-définit le comportement lorsque que l'on clique sur le bouton check.
  def comportementCheck()
    ajout = false

    #Propose à l'utilisateur s'il veut prendre le risque de vérifier mais de prendre une pénalité s'il a des erreurs
    if(popup_message(@window,true,"#{$local["augmentationCheck"]} #{PENCHECK}s !") == 1)
      ajout = true
      super()
    end

    tab = @erreur.donneLesErreurs()
    etat = tab.shift()

    if(ajout && etat == 0)
      @timer.ajouterTemps(PENCHECK)
    end
    return self
  end

  @Override
  ##
  # Re-définit le comportement lorsque l'on clique sur le bouton montrer.
  def comportementShow()
    #Propose à l'utilisateur de prendre une pénalité pour lui montrer ses erreurs
    if(popup_message(@window,true,"#{$local["ajoutShow"]} #{PENSHOW}s #{$local["afficherShow"]}") == 1)
      super()
      @timer.ajouterTemps(PENSHOW)
    end
    return self
  end

  @Override
  ##
  # Re-définit le comportement lorsque l'on clique sur le bouton aides.
  def comportementHelp()
    #Propose à l'utilisateur de prendre une pénalité pour lui donner une aide
    if(popup_message(@window,true,"#{$local["ajoutAides"]} #{3} #{$local["entreSecAides"]} #{9}s #{$local["afficherAides"]}") == 1)
      super()
    end
    return self
  end

  @Override
  ##
  # Re-définit la méthode initialize.
  # @param file [String] le fichier contenant la grille
	# @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
  # @param taille [String] La taille de la grille
  # @param diff [String] La difficulté de la grille
  # @param niveau [Integer] Le niveau de la grille
  def initialize(file, window, fenetre_prec,taille,diff,niveau)
    @bdd = Bdd.creer("ranked.bdd")
    @bdd.creerBdd()

    initClassement(taille,diff,niveau)

    @window = window
        @fenetre_prec = fenetre_prec

        @window.set_title($local["ingame"])

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

            razBg()

            @buttonAfficher = creerButtonAfficher()
            @timer = creerTimer()
            @aides = AidesClasse.creer(self)
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
  end

  ##
  # Constructeur de la classe GrilleClasseUI.
  # @param file [String] le fichier contenant la grille
	# @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
  # @param taille [String] La taille de la grille
  # @param diff [String] La difficulté de la grille
  # @param niveau [Integer] Le niveau de la grille
  def GrilleClasseUI.creer(file, window, fenetre_prec,taille,diff,niveau)
    new(file, window, fenetre_prec,taille,diff,niveau)
  end

  private_class_method:new
end
