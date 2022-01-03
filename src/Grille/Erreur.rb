require_relative 'Grille.rb'

##
# Récupère les cases fausses dans le jeu Hashi.
# @author Baptiste DEROUAULT
class Erreur
    ##
    # Ses variables d'instances sont :
    # - cases   : Correspond au tableau à double dimensions où est stocké toutes les cases


    ##
    # Constructeur de la classe Erreur avec un tableau de cases donnés.
    # @param cases [Array] correspondant
    def Erreur.creer(cases)
        new(cases)
    end

    @Override
    ##
    # Re-définition de la méthode initialize.
    # @param cases [Array] correspondant
    def initialize(cases)
        @cases = cases
    end

    ##
    # Retourne un tableau avec les coordonnées des cases qui sont fausses sous forme : [type,[0,1][0,2]] type => 2 Erreur : 1 En Cours.
    # @return [Array]
    def donneLesErreurs()
        erreur = [0]
        enCours = [1]
        fini = [2]

        #On parcourt les cases une par une
        taille = @cases.length

        #Permet de parcourir case par case pour savoir si la case est correct ou non
        for i in 0..(taille-1)
            for j in 0..(taille-1)
                temp = []
                #Cas En cours
                if(caseEstCorrect?(@cases[i][j]) == 1)
                    temp << i
                    temp << j

                    enCours << temp
                #Cas Erreur
                elsif(caseEstCorrect?(@cases[i][j]) == 0)
                    temp << i
                    temp << j

                    erreur << temp
                #Cas Correct
                else
                    temp << i
                    temp << j

                    fini << temp
                end
            end 
        end

        #Ici on retourne le tableau d'erreur s'il y en a puis le tableau en cours sinon le tableau fini
        if(erreur.length != 1)
            return erreur
        elsif(enCours.length != 1)
            return enCours
        end
        return fini

    end

    ##
    # Méthode permettante de vérifier si une case est correcte.
    # @param c [Case] une case
    # @return [boolean]
    def caseEstCorrect?(c)
        #Ici une ile est correct si elle à le bon nombre de lien attaché à elle
        #Une case est en-cours si elle possède moins de lien dont elle à besoin
        #Une case est fausse lorsque qu'elle possède plus de lien dont elle a besoin
        return c.estOk?()
    end

    private_class_method:new
end