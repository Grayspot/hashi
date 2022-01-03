##
# Représente le fonctionnnement d'un chronomêtre thread.
# @author CHAUVIN Lucien
class Chrono
    ##
    #   Ses variables d'instances sont :
    #   temps           : Représente le temps passé
    #   button          : Représente le bouton que le chrono doit modifier
    #   thread          : Représente le thread du chrono
    #   etat            : Représente l'état du chrono : pause ou en cours
    #   tempsPenalite   : Représente le temps de pénalité 
    #   tempsPause      : Représente le temps de la pause
    #   tempPauseDebut  : Représente le début de la pause
    #   tempsInit       : Représente le temps initial
    #   tempsAct        : Représente le temps actuel
    #   raz             : Représente si on doit mettre à zéro le chrono

    ##
    #   Représente le temps passé
    attr_accessor:temps

    ##
    # Permet de construire le chrono en fonction d'un bouton.
    # @param button [Gtk::Button] Le bouton que le chrono doit mettre à jour
    def Chrono.creer(button)
        new(button)
    end

    @Override
    ##
    # Re-définition de la méthode initialize.
    # @param button [Gtk::Button] Le bouton que le chrono doit mettre à jour
    def initialize(button)
        @tempsPenalite = 0
        @tempPause = 0
        @tempPauseDebut = nil
        @button = button
        @temps = 0
        @etat = false
        @thread = nil
    end

    ##
    # Permet de lancer le chrono.
    def start()
        if(@thread != nil)
            @thread.exit()
        end
        #Initialize toutes les variables dont l'on a besoin
        #Temps intial
        @tempsInit = getTime(Time.now)
        #Temps ou l'on va compté la durée de la pause
        @tempPause = 0
        #Temps ou l'on va compté les pénalités
        @tempsPenalite = 0
        #Temps du début de la pause
        @tempPauseDebut = nil
        @etat = true
        @raz = false
        #Lancement du chrono
        @thread = Thread.new do
            Thread.current["stop"] = false
            Thread.current["raz"] = false
                while true
                    #pause
                    if Thread.current["stop"]
                        Thread.current["stop"] = false
                        @tempPauseDebut = getTime(Time.now)
                        #remise à zéro
                        if Thread.current["raz"]
                            Thread.current["raz"] = false
                            @tempPause = -1
                            @tempsInit = @tempPauseDebut
                            @button.label = "00:00"
                            @tempsPenalite = 0
                            @raz = true
                        end
                        Thread.stop
                    else
                        @tempsAct = getTime(Time.now)

                        #Si on sort de la pause
                        if(@tempPauseDebut != nil)
                            @tempPause += (@tempsAct - @tempPauseDebut)
                        end

                        #Permet de calculer le temps passé en fonction de tous les paramêtres, intial, actuelle pause et pénalité
                        @tempPauseDebut = nil
                        @temps = (@tempsAct - @tempsInit - @tempPause + @tempsPenalite)

                        #Permet de convertir un affichage en secondes en minutes:secondes
                        tmp = @temps
                        nbMin = (@temps / 60).round
                        tmp -= (nbMin*60)
                        @button.label = sprintf("%02i:%02i",nbMin,tmp)
                    end
                    sleep(1)
                end
        end
        return self
    end

    ##
    # Retourne vrai si le chrono est en pause.
    # @return [boolean]
    def estPause?()
        return @etat
    end

    ##
    # Permet de mettre en pause le chrono.
    def pause()
        @thread["stop"] = true
        @etat = true
        return self
    end

    ##
    # Permet de mettre à zéro le chrono.
    def raz()
        @thread["raz"] = true
        pause()
        return self
    end

    ##
    # Permet de reprendre le chrono après une pause.
    def reprendre()
        @thread.run()
        @etat = false
        if(@raz)
            @tempsInit = getTime(Time.now)
            @raz = false
        end
        return self
    end

    ##
    # Permet d'ajouter du temps au chrono.
    # @param temps [Integer] Le temps à ajouter
    def ajouterTemps(temps)
        @tempsPenalite += temps

        return self
    end

    ##
    # Permet de récupérer le temps d'une instance de la classe Time.
    # @return [Integer] le temps en secondes
    def getTime(temps)
        return temps.hour * 3600 + temps.min * 60  + temps.sec
    end

    ##
    # Permet de stopper le chrono.
    def stop()
        @thread.kill()
        return self
    end

    private_class_method:new
end
