##
# Classe permettante de sauvegarder les coups dans un fichier save.
# @author DEROUAULT Baptiste
class Sauvegarde 
    ##
    # Ses variables d'instances sont :
    # fichier  : Correspond au nom de fichier initial
    # coups    : Correspond à un tableau comportant tous les coups joués

    ##
    # Constructeur de la classe Sauvegarde.
    # @param unFichier [String] Le nom du fichier initial
    def Sauvegarde.creer(unFichier)
        new(unFichier)
    end

    @Override
    ##
    # Ré-définition de la méthode initialize.
    # @param unFichier [String] Le nom du fichier initial
    def initialize(unFichier)
        @fichier = unFichier
    end

    ##
    # Méthode permettante de sauvegarder tous les coups ainsi que le temps de jeu.
    # @param time [Integer] le temps en secondes
    # @param lesCoups [Array] La liste des coups à sauvegarder
    def enregistrer(time,lesCoups)
        #On ouvre le fichier en écriture
        file = File.open("#{@fichier}save.txt","w")

        file.seek(0)

        #On écrit le timer
        file.write("##{time}\n")

        #On écrit toutes les coordoonées des cases à activer
        for val in lesCoups
            file.write("#{val[0]}:#{val[1]}\n")
        end

        file.write("@")

        #On ferme le fichier
        file.close

        return self
    end

    ##
    # Méthode permettante de restituer tout les coups en fonction de la sauvegarde.
    # @return [Array]
    def restituer()
        save = []

        recup = true

        #On test si le fichier existe
        if(File.exist?("#{@fichier}save.txt"))
            File.open("#{@fichier}save.txt","r").each do |line| 
                line.split.each do |word|
                    if(recup)
                        case word[0]
                        #Timer
                        when '#'
                            save.push(word.split("#")[1].to_i)
                        when '@'
                            recup = false
                        else
                            save.push([word.split(":")[0].to_i,word.split(":")[1].to_i])
                        end
                    end
                end
            end
        end
        return save
    end


    private_class_method:new
end