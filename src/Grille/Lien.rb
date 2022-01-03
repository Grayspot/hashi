require_relative 'Case.rb'

##
# Classe Lien représentant une case du plateau de jeu, cette classe hérite de la classe Case.
# @author DEROUAULT Baptiste
class Lien < Case
  ##
  # Ses variables d'instances sont :
  # nbLiens        : Correspond au nombre de liens courant de l'île
  # nbLiensAttendu : Correspond au nombre de liens attendu
  # end            : Correspond à determiner si l'île est clos ou no

  ##
  # Correspond au nombre de liens attendu
  attr_reader:nbLiensAttendu
  ##
  # Correspond au nombre de liens courant du pont
  attr_accessor:nbLiens
  ##
  # Correspond au type courant du pont
  attr_accessor:typeCourant

  ##
  # Constructeur de la classe Lien.
 	# @param x [Integer] La coordonnée abscisse de la case
	# @param y [Integer] La coordonnée ordonnée de la case
	# @param carac [Charactere] Le caractère qui décrit la case
	# @param grille [Grille] Grille à laquelle appartient la case
  def Lien.creer(x, y, carac, grille,nb_lien)
    new(x, y, carac, grille, nb_lien)
  end

  @Override
  ##
  # Re-définition de la méthode initialize.
 	# @param x [Integer] La coordonnée abscisse de la case
	# @param y [Integer] La coordonnée ordonnée de la case
	# @param carac [Charactere] Le caractère qui décrit la case
	# @param grille [Grille] Grille à laquelle appartient la case
  def initialize(x, y, carac, grille, nbLiensAttendu)
    super(x, y, carac, grille)
    @nbLiensAttendu = nbLiensAttendu
    @typeCourant =""
    @ver = ["|","H"]
    @hor = ["-","="]
  end

  @Override
  ##
  # Retourne vrai, la case est un lien.
  # return [boolean]
  def estLien?()
    return true
  end
  
  ##
  # Recherche un pont a créer : ajoute un lien au compteur à toutes les cases et iles si le pont peut exister.
  # @return [Array]
  def creerPont()
    #Tableau comportant toutes les coordonnées du pont
    pont = []

    pontY = pontHauteurExiste?()
    pontX = pontLargeurExiste?()

    if(@typeCourant != "")
      if(@typeCourant == '-' || @typeCourant == '=')
        incrementerPontLargeur(pontX)
        return pontX
      else
        incrementerPontHauteur(pontY)
        return pontY
      end
    end

    if(pontY.length != 0)
      pontY = homogenePont?(pontY) ? pontY : []
    end
    if(pontX.length != 0)
      pontX = homogenePont?(pontX) ? pontX : []
    end

    if((pontY.length < pontX.length && pontY.length != 0) ||(pontY.length != 0 && pontX.length == 0))
      #On traite pont de Y car Y < X et Y != 0 ou X = 0 et Y != 0
      incrementerPontHauteur(pontY)
      return pontY
    else
      #Ici Y = 0 et Y > X
      if(pontX.length != 0)
        #On traite pont de X
        incrementerPontLargeur(pontX)
        return pontX
      end
    end

    return pont

  end

  ##
  # Rechercher l'existance d'un pont sur l'axe Y.
  # @return [Array] 
  def pontHauteurExiste?()
    pont = []

    i = @x
    j = @y

    cases = @grille.cases

    #On cherche la première ile en haut 
    while(i>=0 && !(cases[i][j].estIle?))
      i-=1
    end

    #On vérifie que l'on a bien trouvé une ile en haut
    if(i>=0)
      #On se replace sur le pont
      i+=1
      #On parcours jusqu'a trouver une ile plus bas pour former le pont
      while(i<@grille.hauteur && !(cases[i][j].estIle?) )
        temp = []

        temp << i
        temp << j 
        pont << temp
        i+=1
      end

      #On regarde si on a pas trouvé d'ile en bas
      if(i==@grille.hauteur)
        return []
      end
    end

    #On retourne la taille du pont
    return pont
  end

  ##
  # Rechercher l'existance d'un pont sur l'axe X.
  # @return [Array]
  def pontLargeurExiste?()
    pont = []

    i = @x
    j = @y
    cases = @grille.cases

    #On cherche la première ile à gauche 
    while(j>=0 && !(cases[i][j].estIle?))
      j-=1
    end

    #On vérifie que l'on a bien trouvé une ile à gauche
    if(j>=0)
      #On se replace sur le pont
      j+=1
      #On parcours jusqu'a trouver une ile à droite pour former le pont
      while(j<@grille.largeur && !(cases[i][j].estIle?))
        temp = []
        temp << i
        temp << j 
        pont << temp
        j+=1
      end

      #On regarde si on a pas trouvé d'ile à droite
      if(j==@grille.largeur)
        return []
      end
    end

    #On retourne la taille du pont
    return pont
  end

  ##
  # Incrémente la valeur de chaque élément qui compose le pont.
  # @param pont [Array] Le tableau contenant les coordonnées de toutes les positions des cases
  def incrementerPontHauteur(pont)
    #Trigger si le pont est égal à 3 = remise à niveau
    trigger = false

    for val in pont
      @grille.cases[val[0]][val[1]].ajouterLien
      if(@grille.cases[val[0]][val[1]].nbLiens == 3)
        @grille.cases[val[0]][val[1]].resetLien
        trigger = true
      end
    end

    if(trigger)
      #On décremente d'un lien la première ile
      ile = pont.first()
      @grille.cases[ile[0]-1][ile[1]].enleverLien
      @grille.cases[ile[0]-1][ile[1]].enleverLien

      #On décremente d'un lien la dernière ile
      ile = pont.last()
      @grille.cases[ile[0]+1][ile[1]].enleverLien
      @grille.cases[ile[0]+1][ile[1]].enleverLien
    else
      #On incrémemente la première ile
      ile = pont.first()
      @grille.cases[ile[0]-1][ile[1]].ajouterLien


      #On incrémemente la dernière ile
      ile = pont.last()
      @grille.cases[ile[0]+1][ile[1]].ajouterLien
    end

    return self
  end

  ##
  # Incrémente la valeur de chaque élément qui compose le pont.
  # @param pont [Array] Le tableau contenant les coordonnées de toutes les positions des cases
  def incrementerPontLargeur(pont)
        #Trigger si le pont est égal à 3 = remise à niveau
        trigger = false

        for val in pont
          @grille.cases[val[0]][val[1]].ajouterLien
          if(@grille.cases[val[0]][val[1]].nbLiens == 3)
            @grille.cases[val[0]][val[1]].resetLien
            trigger = true
          end
        end

        if(trigger)
          #On décremente d'un lien la première ile
          ile = pont.first()
          @grille.cases[ile[0]][ile[1]-1].enleverLien
          @grille.cases[ile[0]][ile[1]-1].enleverLien
    
          #On décremente d'un lien la dernière ile
          ile = pont.last()
          @grille.cases[ile[0]][ile[1]+1].enleverLien
          @grille.cases[ile[0]][ile[1]+1].enleverLien
        else
          #On incrémemente la première ile
          ile = pont.first()
          @grille.cases[ile[0]][ile[1]-1].ajouterLien

    
          #On incrémemente la dernière ile
          ile = pont.last()
          @grille.cases[ile[0]][ile[1]+1].ajouterLien
          
        end

        return self
  end


  ##
  # Test si le nombre de liens de chaque item du pont sont égaux.
  # @param pont [Array] Le tableau contenant les coordonnées de toutes les positions des cases
  # @return [boolean] 
  def homogenePont?(pont)
    cases = @grille.cases

    ref = cases[pont[0][0]][pont[0][1]].nbLiens

    for c in pont
      if(cases[c[0]][c[1]].nbLiens != ref)
        return false
      end
    end

    return true
  end

  ##
  # Test si le nombre de liens de chaque item du pont sont égaux.
  # @param pont [Array] Le tableau contenant les coordonnées de toutes les positions des cases
  # @return [boolean]
  def pontVide?(pont)
    cases = @grille.cases

    for c in pont
      if(cases[c[0]][c[1]].nbLiens != 0)
        return false
      end
    end

    return true
  end

  ##
  # Méthode permettant de déterminer si un lien est faux ou non : nbLiens <= nbLiensAttendu && 0 : faux 1 : en cours 2 : complete.
  # @return [int]
  def estOk?()
    #Complete
    if(@nbLiens == @nbLiensAttendu && typeOk?() == 2)
        return 2
    elsif((@nbLiens < @nbLiensAttendu && typeOk?() != 0))
        return 1
    end
    return 0

  end

  ##
  # Méthode permettant de vérifier si le type du lien est bon 0 : faux 1 : en cours 2 : complete.
  # @return [int]
  def typeOk?()
    #Cas simple : le type courant est le type attendu
    if(@typeCourant == @carac)
      return 2
    #Cas en-cours : si le type courant fait partie de la famille du type attendu
    elsif(@ver.index(@carac) != nil)
      if(@ver.index(@typeCourant) != nil)
        return 1
      end
    elsif(@hor.index(@carac) != nil)
      if(@hor.index(@typeCourant) != nil)
        return 1
      end
    elsif(@typeCourant == "")
      return 1
    else
      return 0
    end
  end

  @Override
  ##
  #	Permet de remettre à zéro le nombre de liens de la case.
  def resetLien()
    super()
    @typeCourant=""
  end

  private_class_method:new
end
