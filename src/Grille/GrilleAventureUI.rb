require 'gtk3'

require_relative 'GrilleUI'

##
# Représente la grille aventure qui hérite de la GrilleUI.
# @author Moustapha TSAMARAYEV
class GrilleAventureUI < GrilleUI

    @Override
    ##
    # Re-définit le comportement lorsque que l'on clique sur le bouton check.
    def comportementCheck()
        tab = @erreur.donneLesErreurs()

        etat = tab.shift()
        if(etat == 0)
            compteErreurs(tab)
        elsif(etat == 1)
            popup_message(@window,false,"#{$local["aucuneErreur"]}")
        elsif(etat == 2 && tab.length != 0)
            for coord in tab
                #On enlève l'affichage des @cases ou il y a rien dessus quand tout est bon
                if(@cases[coord[0]][coord[1]].nbLiens != 0)
                    imagePourCase(@cases[coord[0]][coord[1]],@button[coord[0]][coord[1]],"Green")
                end
            end
            @timer.pause
            popup_message(@window,false,"#{$local["gagne"]} #{@timer.temps}s !")
            Adventure.avance()
            Adventure.refresh()
            Adventure.sauvegarderProgression()
            finPartie()
        end

        return self
    end
end

