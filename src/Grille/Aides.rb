require 'gtk3'
require 'yaml'

##
# Représente les aides pour une grille.
# @author Baptiste DUBIN - Anaïs MOTTIER - Dorian RENARD - Baptiste DEROUAULT
class Aides
	##
	#	Les variables d'instances sont :
	#	grid    		  : Le conteneur de type grid du classement
	#	fenetre  		  : La fenêtre
	#	titre	        : Le titre de la fenêtre
	#	btnBasic      : Le bouton pour choisir une aide basique
	#	btnIsolation	: Le bouton pour choisir une aide d'isolation
  # btnAdvancee   : Le bouton pour choisir une aide avancée
  # texte         : Le label pour contenant la description de l'aide
  # img           : Une image afin d'expliquer l'aide
  # tabAides      : Le tableau contenant le numéro de l'aide et les coordonnées des îles concernées
  # grilleUI      : Une instance de la grille
  # aidesDispo    : Tableau contenant 3 tableaus de disponibilités permettant de savoir quelle aide à déjà été tiré


  ##
  # Correspond à l'aide basique
  BASICS = 0
  ##
  # Nombre d'aides basiques
  NBBASICS = 5
  ##
  # Correspond à l'aide d'isolation
  ISOLATION = 1
  ##
  # Nombre d'aides isolation
  NBISOLATION = 4
  ##
  # Correspond à l'aide avancée
  ADVANCED = 2
  ##
  # Nombre d'aides avancée
  NBADVANCED = 4

  ##
  # Permet d'afficher une aide selon un titre et sa description, de plus permet de montrer les îles concernées par l'aide sur la grille.
  # @param info [Array] Le tableau stockant les éléments récupérés dans le fichier YAML
  # @param affImage [boolean] Détermine si l'on doit afficher une image ou non
  def montrerAides(info,affImage)
    #Permet d'enlever le sélecteur d'aides
      @grid.remove(@titre)
      @grid.remove(@btnBasic)
      @grid.remove(@btnIsolation)
      @grid.remove(@btnAdvancee)

    #Défini le titre
      @titre.set_label(info[0])
      @titre.set_name("#{$theme}Title")
      @titre.set_justify(2)

    #Défini la zone d'expliquation de l'aide
      @texte = Gtk::Label.new(info[1])
      @texte.set_justify(2)
      @texte.set_line_wrap(true)
      @texte.set_name("#{$theme}Text")

    #Défini la zone d'image pour l'aide
      if(affImage)
        @img = Gtk::Image.new(file: info[2])
      end
    
    boutonAides(affImage)
  end

  ##
  # Retourne une aide basique aléatoirement entre celles qui correspondent à la grille.
  # @return [Array] Le numéro de l'aide et toutes les coordonnées des îles concernés sous forme : [1,[2,3],[4,4]]
  def tirerAidesBasique()
    #Tableau contenant toutes les aides
      aides = []
    #Liste de toutes les îles
      listIles = []
    #Cases de la grille
      cases = @grilleUI.cases
    #Taille de la grille
      taille = cases.length

    #Tableau permettant de récupérer les coordonnées de chaque cellule concerné
      a1 = [0]
      a2 = [1]
      a3 = [2]
      a4 = [3]
      a5 = [4]

    #On récupère toutes les îles
      for i in 0..(taille-1)
        for j in 0..(taille-1)
          if(cases[i][j].estIle?)
            listIles << [i,j]
          end
        end
      end

    #On parcours toutes les îles
    for coord in listIles
      #CAS 1 : Île avec un seul voisin
      #On vérifie que l'on peux tirer cette aide
      if(@aidesDispo[BASICS][0])
        if(cases[coord[0]][coord[1]].retournerVoisin.length == 1)
          if(cases[coord[0]][coord[1]].estOk? != 2)
            a1 << [coord[0],coord[1]]
          end
        end
      end

      #CAS 2 : Îles avec 3 dans le coin, 5 sur le côté et 7 au milieu
      #On vérifie que l'on peux tirer cette aide
      if(@aidesDispo[BASICS][1])
        #Cas 7 : Toujours validé
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 7)
          if(cases[coord[0]][coord[1]].estOk? != 2)
            a2 << [coord[0],coord[1]]
          end
        end

        #Cas 3 : On doit avoir un 3 qui doit être dans un coin
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 3 && (coord[0] == 0 || coord[0] == (taille-1)) && (coord[1] == 0 || coord[1] == (taille-1)))
          if(cases[coord[0]][coord[1]].estOk? != 2)
            a2 << [coord[0],coord[1]]
          end
        end

        #Cas 5 : On doit avoir un 5 qui doit être sur un côté
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 5 && ((coord[0] == 0 && coord[1] != (taille-1) && coord[1] != 0) || (coord[0] == (taille-1) && coord[1] != (taille-1) && coord[1] != 0) || (coord[1] == (taille-1) && coord[0] != (taille-1) && coord[0] != 0) || (coord[1] == 0 && coord[0] != (taille-1) && coord[0] != 0)))
          if(cases[coord[0]][coord[1]].estOk? != 2)
            a2 << [coord[0],coord[1]]
          end
        end
      end

      #CAS 3 : Îles avec 3 dans le coin, 5 sur le côté et 7 au milieu mais doivent avoir une île 1 relié à eux
      #On vérifie que l'on peux tirer cette aide
      if(@aidesDispo[BASICS][2])
        #Cas 7 : On doit regardé la présence d'un 1
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 7)
          if(cases[coord[0]][coord[1]].presenceUnVoisin == 1)
            if(cases[coord[0]][coord[1]].estOk? != 2)
              a3 << [coord[0],coord[1]]
            end
          end
        end

        #Cas 3 : On doit avoir un 3 qui doit être dans un coin
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 3 && (coord[0] == 0 || coord[0] == (taille-1)) && (coord[1] == 0 || coord[1] == (taille-1)))
          if(cases[coord[0]][coord[1]].presenceUnVoisin == 1 )
            if(cases[coord[0]][coord[1]].estOk? != 2)
              a3 << [coord[0],coord[1]]
            end
          end
        end

        #Cas 5 : On doit avoir un 5 qui doit être sur un côté
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 5 && ((coord[0] == 0 && coord[1] != (taille-1) && coord[1] != 0) || (coord[0] == (taille-1) && coord[1] != (taille-1) && coord[1] != 0) || (coord[1] == (taille-1) && coord[0] != (taille-1) && coord[0] != 0) || (coord[1] == 0 && coord[0] != (taille-1) && coord[0] != 0)))
          if(cases[coord[0]][coord[1]].presenceUnVoisin == 1)
            if(cases[coord[0]][coord[1]].estOk? != 2)
              a3 << [coord[0],coord[1]]
            end
          end
        end
      end

      #CAS 4 : Îles 4 avec deux voisin 1 sur trois
      #On vérifie que l'on peux tirer cette aide
      if(@aidesDispo[BASICS][3])
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 4 && ((coord[0] == 0 && coord[1] != (taille-1) && coord[1] != 0) || (coord[0] == (taille-1) && coord[1] != (taille-1) && coord[1] != 0) || (coord[1] == (taille-1) && coord[0] != (taille-1) && coord[0] != 0) || (coord[1] == 0 && coord[0] != (taille-1) && coord[0] != 0)))
          if(cases[coord[0]][coord[1]].presenceUnVoisin == 2)
            if(cases[coord[0]][coord[1]].estOk? != 2)
              a4 << [coord[0],coord[1]]
            end
          end
        end
      end

      #CAS 5 : Île 6 avec un voisin 1 sur 4
      #On vérifie que l'on peux tirer cette aide
      if(@aidesDispo[BASICS][4])
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 6)
          if(cases[coord[0]][coord[1]].retournerVoisin.length == 4)
            if(cases[coord[0]][coord[1]].presenceUnVoisin == 1)
              if(cases[coord[0]][coord[1]].estOk? != 2)
                a5 << [coord[0],coord[1]]
              end
            end
          end
        end
      end
    end

    #Permet de mettre toutes les aides concernées dans un tableau pour en tirer une au sort
      if(a1.length != 1)
        aides << a1
      end
      if(a2.length != 1)
        aides << a2
      end
      if(a3.length != 1)
        aides << a3
      end
      if(a4.length != 1)
        aides << a4
      end
      if(a5.length != 1)
        aides << a5
      end

    if(aides.length != 0)
      return aides[rand(aides.length)]
    else
      return []
    end
  end

  ##
  # Permet de choisir une aide et de l'afficher en fonction de la catégorie choisie.
  # @param categorie [Integer] La catégorie de l'aide
  def tirerAides(categorie)
    @tabAides = []
    case categorie
    when BASICS
      if(@aidesDispo[BASICS].include?(true))
        #Retourne array contenant, la position de l'aide et les coordonnées de toutes les îles qu'elles valide : [1,[2,3],[3,4]]
        @tabAides = tirerAidesBasique()

        #Une aide à été tiré
        if(@tabAides.length != 0)
          x = @tabAides.shift
          #On rends indisponible l'aide tiré
          @aidesDispo[BASICS][x] = false

          montrerAides([$local['aidesBasicsTitre'][x], $local['aidesBasics'][x*2], $local['aidesBasics'][x*2+1]],true)

        else
          montrerAides([$local['nonAideTitre'], $local['nonAideTexte'], nil],false)
        end
      else
        montrerAides([$local['nonAideTitre'], $local['nonAideTexte'], nil],false)
      end
    when ISOLATION
      if(@aidesDispo[ISOLATION].include?(true))
        x = rand(NBISOLATION)
        while(@aidesDispo[ISOLATION][x]==false)
          x = rand(NBISOLATION)
        end

        @aidesDispo[ISOLATION][x] = false

        montrerAides([$local['aidesIsolationsTitre'][x], $local['aidesIsolations'][x*2], $local['aidesIsolations'][x*2 + 1]],true)
      else
        montrerAides([$local['nonAideTitre'], $local['nonAideTexte'], nil],false)
      end
    when ADVANCED
      if(@aidesDispo[ADVANCED].include?(true))
        x = rand(NBADVANCED)
        while(@aidesDispo[ADVANCED][x]==false)
          x = rand(NBADVANCED)
        end

        @aidesDispo[ADVANCED][x] = false

        montrerAides([$local['aidesAdvancedTitre'][x], $local['aidesAdvanced'][x*2], $local['aidesAdvanced'][x*2 + 1]],true)
      else
        montrerAides([$local['nonAideTitre'], $local['nonAideTexte'], nil],false)
      end
    else
      puts '[-] Erreur : tirerAides'
    end
  end

  ##
  # Permet de créer le bouton pour montrer l'aide.
  # @return [Gtk::Button] Le bouton montrer
  def creerBoutonMontrer()
    if(@tabAides.length != 0)
      btnMontrer = Gtk::Button.new(label: $local["btnMontrer"])
      btnMontrer.set_name("#{$theme}BtnIcon")
      btnMontrer.signal_connect('clicked') do
        @grilleUI.razBg
        for coord in @tabAides
          @grilleUI.button[coord[0]][coord[1]].set_name("#{$theme}CircleGold")
        end
      end
    end
    return btnMontrer
  end

  ##
  # Permet de définir le bouton montrer et le bouton quitter lorque l'on affiche une aide.
  # @param affImage [boolean] Détermine si l'on doit afficher une image ou non
  def boutonAides(affImage)
    btnMontrer = creerBoutonMontrer()

    btnQuitter = Gtk::Button.new(label: $local["exit"])
    btnQuitter.set_name("#{$theme}BtnIcon")

    @grid.attach(@titre, 0, 0, 1, 1)
    @grid.attach(@texte, 0, 1, 1, 1)
    if(affImage)
      @grid.attach(@img, 0, 2, 1, 1)
    end
    if(@tabAides.length != 0)
      @grid.attach(btnMontrer, 0, 3, 1, 1)
    end
    
    @grid.attach(btnQuitter, 0, 4, 1, 1)

    @fenetre.show_all

    btnQuitter.signal_connect('clicked') do
      @fenetre.destroy
    end
  end

  @Override
  ##
  # Re-définition du initialize pour lui donner la grille et créer un tableau des aides disponibles.
  # @param grilleUI [GrilleUI] La grille de jeu
  def initialize(grilleUI)
    @grilleUI = grilleUI
    #On rends toutes les aides disponibles
    @aidesDispo = [Array.new(5,true),Array.new(4,true),Array.new(4,true)]
  end

  ##
  # Fonction permettant de lancer le choix d'aides.
  def lancer()
    #Création de la fenêtre
    @fenetre = Gtk::Window.new
    @fenetre.set_border_width(10)
    @fenetre.set_default_size(600, 280)
    @fenetre.set_title($local['titreFenetre'])
    @fenetre.set_name($theme)

    @fenetre.set_window_position(Gtk::WindowPosition::CENTER_ALWAYS)

    #Création du container
    @grid = Gtk::Grid.new
    @grid.set_column_homogeneous(@grid)
    @grid.set_row_spacing(20)
    @fenetre.add(@grid)

    #Création du titre de la fenêtre
    @titre = Gtk::Label.new($local['titrePrincipal'])
    @titre.set_name("#{$theme}Title")

    

    #Bouton pour afficher une aide basique
    @btnBasic = Gtk::Button.new(label: $local['btnBasic'])
    @btnBasic.set_name("#{$theme}BtnIcon")
    @btnBasic.signal_connect('clicked') do
      @fenetre.set_title("#{$local['btnBasic']}-#{$local['titrePrincipal']}")
      tirerAides(BASICS)
    end

    #Bouton pour afficher une aide isolation
    @btnIsolation = Gtk::Button.new(label: $local['btnIsolation'])
    @btnIsolation.set_name("#{$theme}BtnIcon")
    @btnIsolation.signal_connect('clicked') do
      @fenetre.set_title("#{$local['btnIsolation']}-#{$local['titrePrincipal']}")
      tirerAides(ISOLATION)
    end

    #Bouton pour afficher une aide avancée
    @btnAdvancee = Gtk::Button.new(label: $local['btnAdvanced'])
    @btnAdvancee.set_name("#{$theme}BtnIcon")
    @btnAdvancee.signal_connect('clicked') do
      @fenetre.set_title("#{$local['btnAdvanced']}-#{$local['titrePrincipal']}")
      tirerAides(ADVANCED)
    end


    @titre.set_label($local['titrePrincipal'])

    #On attache les boutons au container
    @grid.attach(@titre, 0, 0, 1, 1)
    @grid.attach(@btnBasic, 0, 3, 1, 1)
    @grid.attach(@btnIsolation, 0, 6, 1, 1)
    @grid.attach(@btnAdvancee, 0, 9, 1, 1)

    @fenetre.set_title($local['titreFenetre'])
    @fenetre.show_all
  end

  ##
  # Permet de construire les aides en fonction de la grille.
  # @param grilleUI [GrilleUI] La grille
  def Aides.creer(grilleUI)
    new(grilleUI)
  end

  private_class_method:new
end
