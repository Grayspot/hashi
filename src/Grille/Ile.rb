require_relative 'Case.rb'

##
# Classe Ile représentant une case du plateau de jeu, cette classe hérite de la classe Case.
# @author DEROUAULT Baptiste
class Ile < Case
  ##
  # Ses variables d'instances sont :
  # nbLiens        : Correspond au nombre de liens courant de l'île
  # nbLiensAttendu : Correspond au nombre de liens attendu
  # end            : Correspond à determiner si l'île est close ou non

  ##
  # Correspond à determiner si l'île est close ou non
  attr_accessor:end
  ##
  # Correspond au nombre de liens courant de l'île
  attr_reader:nbLiens
  ##
  # Correspond au nombre de liens attendu
  attr_reader:nbLiensAttendu


  @Override
  # Création d'une case de type Ile.
  # @param x [Integer] La coordonnée abscisse de la case
  # @param y [Integer] La coordonnée ordonnée de la case
  # @param carac [Charactere] Le caractère qui décrit la case
  # @param grille [Grille] Grille à laquelle appartient la case
  def initialize(x, y, carac, grille)
    super(x, y, carac, grille)
    @end = 0
    @nbLiensAttendu = @carac.to_i
  end

  ##
  # Méthode permettant de déterminer si une île est fausse ou non : nbLiens <= nbLiensAttendu 0 : faux 1 : en cours 2 : complète.
  # @return [int] 
  def estOk?()
    if(@nbLiens == @nbLiensAttendu)
      return 2
    elsif(@nbLiens < @nbLiensAttendu)
      return 1
    end
    return 0
  end

  @Override
  ##
  # Vérifie si la case est une instance de "Ile".
  # @return [boolean] par defaut.
  def estIle?()
    return true
  end

  ##
  # Retourne les voisins de l'île.
  # @return [Array]
  def retournerVoisin()
    voisin = []

    cases = @grille.cases
    dim = cases.length

    #NORD
        x = @x-1
        y = @y
        while(x >= 0 && cases[x][y].estLien?)
            x-=1
        end
        if(x>=0 && cases[x][y].estIle?)
            voisin << [x,y]
        end

    #SUD
        x = @x+1
        y = @y
        while(x < dim && cases[x][y].estLien?)
            x+=1
        end
        if(x < dim && cases[x][y].estIle?)
            voisin << [x,y]
        end

    #OUEST
        x = @x
        y = @y-1
        while(y >= 0 && cases[x][y].estLien?)
            y-=1
        end
        if(y>=0 && cases[x][y].estIle?)
            voisin << [x,y]
        end

    #EST
        x = @x
        y = @y+1
        while(y < dim && cases[x][y].estLien?)
            y+=1
        end
        if(y < dim && cases[x][y].estIle?)
            voisin << [x,y]
        end

    return voisin
  end

  ##
  # Retourne vrai si un voisin est de taille 1.
  # @return [Integer]
  def presenceUnVoisin()
    cases = @grille.cases

    voisin = 0

    for coord in self.retournerVoisin
        if(cases[coord[0]][coord[1]].nbLiensAttendu == 1)
            voisin+=1
        end
    end

    return voisin
  end

  ##
  # Méthode permettant de récuperer tous les ponts en partant d'une ile.
  # @return [Array]
  def ilePont()
    hover = []

    cases = @grille.cases
    dim = cases.length

    #NORD
        x = @x-1
        y = @y
        #Je parcours la distance tant que je ne sors pas, je ne suis pas sur une ile et que le lien est vide
        while(x>=0 && cases[x][y].estLien? && cases[x][y].nbLiens==0)
            x-=1
        end
        #Si je ne suis pas sortie et que tout les liens sont vides alors je suis sur une île

        if(x>=0 && cases[x][y].estIle?)
            #Si l'île n'est pas clos alors je sauvegarde le pont
            if(cases[x][y].estOk? != 2)
                x = @x-1
                y = @y
                while(cases[x][y].estLien?)
                    hover << [x,y]
                    x-=1
                end
            end
        end
    #SUD
        x = @x+1
        y = @y
        #Je parcours la distance tant que je ne sors pas, je ne suis pas sur une ile et que le lien est vide
        while(x<dim && cases[x][y].estLien? && cases[x][y].nbLiens==0)
            x+=1
        end
        #Si je ne suis pas sortie et que tout les liens sont vides alors je suis sur une île
        if(x<dim && cases[x][y].estIle?)
            #Si l'île n'est pas clos alors je sauvegarde le pont
            if(cases[x][y].estOk? != 2)
                x = @x+1
                y = @y
                while(cases[x][y].estLien?)
                    hover << [x,y]
                    x+=1
                end
            end
        end
    #EST
        x = @x
        y = @y+1
        #Je parcours la distance tant que je ne sors pas, je ne suis pas sur une ile et que le lien est vide
        while(y<dim && cases[x][y].estLien? && cases[x][y].nbLiens==0)
            y+=1
        end
        #Si je ne suis pas sortie et que tout les liens sont vides alors je suis sur une île
        if(y<dim && cases[x][y].estIle?)
            #Si l'île n'est pas clos alors je sauvegarde le pont
            if(cases[x][y].estOk? != 2)
                x = @x
                y = @y+1
                while(cases[x][y].estLien?)
                    hover << [x,y]
                    y+=1
                end
            end
        end

    #OUEST
        x = @x
        y = @y-1
        #Je parcours la distance tant que je ne sors pas, je ne suis pas sur une ile et que le lien est vide
        while(y>=0 && cases[x][y].estLien? && cases[x][y].nbLiens==0)
            y-=1
        end
        #Si je ne suis pas sortie et que tout les liens sont vides alors je suis sur une île
        if(y>=0 && cases[x][y].estIle?)
            #Si l'île n'est pas clos alors je sauvegarde le pont
            if(cases[x][y].estOk? != 2)
                x = @x
                y = @y-1
                while(cases[x][y].estLien?)
                    hover << [x,y]
                    y-=1
                end
            end
        end

    return hover
  end

  @Override
  ##
  #	Permet de remettre à zéro le nombre de liens de la case.
  def resetLien()
    super()
    @end = 0
    return self
  end

  private_class_method:new
end

