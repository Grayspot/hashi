require_relative "../Grille/Sauvegarde.rb"

##
# Classe qui crée et permet de retourner une barre de progression relative à une grille précise.
# @author GIROD Valentin
class BarreProgression < GrilleUI

  ##
  # Constructeur de la classe avec un fichier précis.
  # @param fichier [File] Le fichier correspondante à la grille
  def BarreProgression.creer(fichier)
    new(fichier)
  end

  ##
  # Constructeur de la classe avec un fichier précis.
  # @param fichier [File] Le fichier correspondante à la grille
  @Override
  def initialize(fichier)

    @grille = Grille.creer("#{fichier}.txt")
    @grille.chargerGrille()
    @cases = @grille.cases
    #génère le tableau des cases correspondant à la grille depuis le fichier de savegarde
    #On a les cases à la progression actuelle
    @liensTermines = 0.0
    @liensTotaux = 0.0
    if(File.exist?("#{fichier}save.txt"))
      rejouerCoups((Sauvegarde.creer(fichier)).restituer())

      for i in 0..(@grille.hauteur-1)
        for j in 0..(@grille.largeur-1)
          if(@grille.cases[i][j].estLien? && !@grille.cases[i][j].to_s().eql?(""))
            @liensTotaux +=1.0
            if(@grille.cases[i][j].to_s().eql?(@cases[i][j].typeCourant))
              @liensTermines +=1.0
            end
          end
        end
      end

    end

  end

  ##
  # Permet de retourner une barre de progression correspondante à la grille.
  # @return [Gtk::ProgressBar]
  def progression()
    if(@liensTotaux == 0)
      @liensTotaux = 1.0
    end
    return Gtk::ProgressBar.new().set_fraction(@liensTermines/@liensTotaux)
  end

  @Override
  ##
  # Permet de rejouer les coups.
  # @param tab [Array] Tableau contenant toutes les positions ou les coups doivent être joué
  def rejouerCoups(tab)
      #Coups à joueur

      for c in tab
          if(@cases[c[0]][c[1]].estLien?)

              if(!entrave(c[0],c[1]))

                  #On demande à la case de nous renvoyer un tableau à deux dimensions de coordonées avec toutes les coordonnées qui corresponde au ponts ainsi qu'ajoute un lien au compteur de toutes les @cases ainsi qu'au deux iles
                  tab = @cases[c[0]][c[1]].creerPont()

                  if(tab.length > 0)
                      sens = ""

                      if((tab.length == 1 && c[0]>=1 && c[0] < @grille.hauteur-1 && @cases[c[0]-1][c[1]].estIle? && @cases[c[0]+1][c[1]].estIle?) || (tab.first[0] - tab.last[0] != 0))
                          sens = "|"
                      elsif((tab.length == 1 && c[1]>=1 && c[1] < @grille.largeur-1 && @cases[c[0]][c[1]-1].estIle?) || (tab.first[1] - tab.last[1] != 0))
                          sens = "-"
                      end
                      for val in tab
                          case @cases[val[0]][val[1]].nbLiens
                          when 0
                              @cases[val[0]][val[1]].typeCourant = ""
                          when 1
                              @cases[val[0]][val[1]].typeCourant = sens
                          when 2
                              if(sens == '-')
                                  @cases[val[0]][val[1]].typeCourant = "="
                              else
                                  @cases[val[0]][val[1]].typeCourant = "H"
                              end
                          end
                      end
                  end
              end
          end
      end
      return self
  end

  @Override
  ##
  # Traite le cas d'un pont lorsqu'il est entouré d'îles.
  # @param i [Integer] la coordonnée en hauteur
  # @param j [Integer] la coordonnée en largeur
  # @return [Boolean] vrai si le traitement a été effectué
  def entrave(i,j)
      if(estEntrave?(i,j))
          #Le pattern est de la forme  - = | H 0
          case @cases[i][j].nbLiens
          when 0
              #On ajoute un lien : on est sur -
              @cases[i][j].ajouterLien
              @cases[i][j].typeCourant = "-"
              @cases[i][j-1].ajouterLien()
              @cases[i][j+1].ajouterLien()
          when 1
              #On est soit dans le cas - ou |
              if(@cases[i][j].typeCourant == '-')
                  @cases[i][j].typeCourant = '='
                  @cases[i][j-1].ajouterLien()
                  @cases[i][j+1].ajouterLien()
              else
                  @cases[i][j].typeCourant = 'H'
                  @cases[i-1][j].ajouterLien()
                  @cases[i+1][j].ajouterLien()
              end
              @cases[i][j].ajouterLien
          when 2
              #On est soit dans le case = ou H
              if(@cases[i][j].typeCourant == '=')
                  @cases[i][j].typeCourant = "|"
                  @cases[i][j].nbLiens = 1
                  @cases[i][j-1].enleverLien()
                  @cases[i][j+1].enleverLien()
                  @cases[i][j-1].enleverLien()
                  @cases[i][j+1].enleverLien()
                  @cases[i-1][j].ajouterLien()
                  @cases[i+1][j].ajouterLien()
              else
                  @cases[i][j].typeCourant = ""
                  @cases[i][j].nbLiens = 0
                  @cases[i-1][j].enleverLien()
                  @cases[i+1][j].enleverLien()
                  @cases[i-1][j].enleverLien()
                  @cases[i+1][j].enleverLien()
              end
          end
          return true
      end
      return false
  end
  private_class_method:new
end
