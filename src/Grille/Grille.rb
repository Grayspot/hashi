require_relative 'Case.rb'
require_relative 'Ile.rb'
require_relative 'Lien.rb'

##
# Représente la grille de jeu.
# @author Baptiste DEROUAULT
class Grille
  ##
  # Ses variables d'instances sont :
  # cases  : Les cases du plateau
  # hauteur: La dimension abscisse du plateau
  # largeur: La dimension ordonnée du plateau
  # fichier: Le fichier contenant la grille

  ##
  # La dimension abscisse du plateau
  attr_reader:hauteur

  ##
  # La dimension ordonnée du plateau
  attr_reader:largeur

  ##
  # Les cases du plateau
  attr_reader:cases


  # Re-définition de la méthode initialize
  # @param nom_fichier [String] Le nom (+ le chemin) du fichier contenant la grille de jeu
  @Override
  def initialize(nom_fichier)
    @fichier = nom_fichier
  end


  ##
  # Génère une grille depuis un fichier existant.
  def chargerGrille()
    i = 0
    j = 0


    #On ouvre le fichier et on le parcours ligne par ligne puis mot par mot
    File.open(@fichier, "r").each do |line|
      line.split.each do |word|
        case word[0]
        when '#'
          # La dimension est indiqué comme ci-dessous alors on doit récupérer les deux valeurs pour créer la grille
          # - #5X5
          dimension = word.split('X')
          # - ['#5','5']

          # - ['5']
          @largeur = dimension[0].split("#")[1].to_i
          # - ['5']
          @hauteur = dimension[1].to_i

          @cases = Array.new(@hauteur){Array.new(@largeur)}
        when '-'
          #Si le symbole est un '-', cela signifie que la résultat doit être un pont simple vertical donc la case doit être un Lien
          @cases[i][j] = Lien.creer(i, j, word, self, 1)
        when '='
          @cases[i][j] = Lien.creer(i, j, word, self, 2)
        when '|'
          @cases[i][j] = Lien.creer(i, j, word, self, 1)
        when 'H'
          @cases[i][j] = Lien.creer(i, j, word, self, 2)
        when '0'
          @cases[i][j] = Lien.creer(i, j, "", self, 0)
        else
          #Ici le symbole est un chiffre alors on sait que c'est une île
          @cases[i][j] = Ile.creer(i, j, word, self)
        end


        if(word[0] != '#')
          j+=1
          if(j==@largeur)
            j=0
            i+=1
          end
        end
      end
    end

    return self
  end

  ##
  # Constructeur de la classe Grille.
  # @param nom_fichier [String] Le nom (+ le chemin) du fichier contenant la grille de jeu
  def Grille.creer(nom_fichier)
    new(nom_fichier)
  end


  @Override
  ##
  # Re-définition de la méthode d'affichage.
  def to_s()
    chaine = ""
    for i in 0..(@hauteur-1)
      for j in 0..(@largeur-1)
        chaine += @cases[i][j].to_s+" "
      end
      chaine += "\n"
    end

    return chaine
  end

  private_class_method:new
end
