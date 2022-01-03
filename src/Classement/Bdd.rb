
require 'sqlite3'

##
# Représente la base de données du jeu.
# @author DEROUAULT Baptiste - ZHENG Haoran
class Bdd
    ##
	#	Les variables d'instances sont :
	#	path    : Le chemin du fichier
	#	db      : La base de données

    ##
    # Permet de construire la base de données avec un fichier donné.
    # @param unPath [String] Le fichier où la base de données sera sauvegardée
    def Bdd.creer(unPath)
        new(unPath)
    end

    @Override
   	##
	# Rédéfinition de la méthode initialize.
	# @param unPath [String] Le fichier où la base de données sera sauvegardée
	  def initialize(unPath)
		@path = unPath
	end

    ##
    # Permet de définir la base de données en table de hashage.
    def setHash()
        @db.results_as_hash = true
        return self
    end

    ##
    # Permet de créer la base de données.
    def creerBdd()
        @db = SQLite3::Database.new @path
        #Création de la table classement
        @db.execute <<-SQL
            create table IF NOT EXISTS CLASSEMENT (
            pseudo varchar(30),
            niveau int,
            diff int,
            taille int,
            temps int
            );
        SQL
        #Permet de définir le retour de la base de données en table de hashage
        setHash()

        return self
    end

    ##
    # Permet de charger la base de données.
    def chargerBdd()
        @db = SQLite3::Database.open @path
        setHash()
        return self
    end

    ##
    # Permet d'insérer une ligne dans la base de données.
    # @param pseudo [String] Le pseudo du joueur
    # @param niveau [Integer] Le niveau
    # @param diff [Integer] La difficulté du niveau
    # @param taille [Integer] La taille du niveau
    # @param temps [Integer] Le temps qu'a mis le joueur
    def insererBdd(pseudo,niveau,diff,taille,temps)
        @db.execute("INSERT INTO CLASSEMENT (pseudo, niveau, diff, taille, temps) VALUES (?, ?, ?, ?, ?)",pseudo,niveau,diff,taille,temps)
        return self
    end

    ##
    # Permet de récupérer toutes les lignes (records) de la base de données.
    # @return [Array] Les lignes de la base de données
    def recupererBdd()
        return @db.execute('select * from CLASSEMENT')
    end

    ##
    # Permet de supprimer la table de la base de données.
    def supprimerTable()
        @db.execute("DROP TABLE CLASSEMENT")
        return self
    end

    ##
    # Supprimer toutes les lignes (records) avec une difficulté et un niveau donné.
    # @param diff [Integer] La difficulté
    # @param niveau [Integer] Le niveau
    # @param taille [Integer] La taille du niveau
    def clearRecords(diff,niveau,taille)
       @db.execute("delete from CLASSEMENT where niveau=? and diff=? and taille=?",niveau,diff,taille)
       return self
    end

    ##
    # Chaque fois que le joueur finit le jeu, on va vérifier si le nouveau résultat est mieux pour la mise à jour de la base de données.
    # @param pseudo [String] Le pseudo du joueur
    # @param niveau [Integer] Le niveau
    # @param diff [Integer] La difficulté du niveau
    # @param taille [Integer] La taille du niveau
    # @param temps [Integer] Le nouveau temps
    def update(pseudo,niveau,diff,taille,temps)
        table = @db.execute("select temps from CLASSEMENT where pseudo=? and niveau=? and diff=? and taille=?",pseudo,niveau,diff,taille)
        for i in table
          if temps < i.values[0]
            @db.execute("UPDATE CLASSEMENT SET temps =? where pseudo=? and niveau=? and diff=? and taille=?",temps,pseudo,niveau,diff,taille)
          end
        end
        return self
    end

    ##
    # Retourne le meilleur score d'un joueur avec un niveau et une difficulté donné.
    # @param pseudo [String] Le pseudo du joueur
    # @param niveau [Integer] Le niveau
    # @param diff [Integer] La difficulté du niveau
    # @param taille [Integer] La taille du niveau
    # @return [Array] Le meilleur score
    def collectBestScore(pseudo,niveau,diff,taille)
      return @db.execute("select distinct * from CLASSEMENT where temps=(select distinct MIN(temps) from CLASSEMENT where pseudo=? and diff=? and niveau=? and taille=?) and pseudo=?",pseudo, niveau,diff,taille,pseudo)
    end

    ##
    # Retourner les temps du joueur.
    # @param pseudo [String] Le pseudo du joueur
    # @return [Array] Les temps du joueur
    def showAllScore(pseudo)
      return @db.execute('select * from CLASSEMENT where pseudo=?',pseudo)
    end

    ##
    # Retourne vrai si le pseudo n'est pas déjà dans la base de données.
    # @param pseudo [String] Le pseudo du joueur
    # @return [boolean] Vrai si le pseudo est inconnu
    def pseudoExiste?(pseudo)
      table = @db.execute("select pseudo from CLASSEMENT")
      for i in table
          if i.values[0] == pseudo
            return false
            break
          end
      end
      return true
    end

    ##
    # Récupère les 10 premiers temps avec une difficulté, un niveau et une taille donné.
    # @param niveau [Integer] Le niveau
    # @param diff [Integer] La difficulté du niveau
    # @param taille [Integer] La taille du niveau
    # @return [Array] Les 10 meilleurs temps
    def recupererHighscore(diff, niveau, taille)
        return @db.execute("select distinct * from CLASSEMENT where diff=? and niveau=? and taille=? order by temps ASC limit 10",diff,niveau,taille)
    end

    private_class_method:new
end
