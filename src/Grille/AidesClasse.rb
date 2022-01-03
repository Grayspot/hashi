##
# Représente les aides pour une grille du mode classés.
# @author Baptiste DUBIN - Anaïs MOTTIER - Dorian RENARD - Baptiste DEROUAULT
class AidesClasse < Aides
  ##
  # Pénalité pour une aide basique
  PENEBASIC = 3
  ##
  # Pénalité pour une aide isolation
  PENEISOLATION = 6
  ##
  # Pénalité pour une aide avancee
  PENEAVANCEE = 9

  @Override
  ##
  # Permets de choisir une aide et de l'afficher en fonction de la catégorie choisie.
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

          #ADD
          @grilleUI.timer.ajouterTemps(PENEBASIC)

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
        #ADD
        @grilleUI.timer.ajouterTemps(PENEISOLATION)
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
        @grilleUI.timer.ajouterTemps(PENEAVANCEE)
      else
        montrerAides([$local['nonAideTitre'], $local['nonAideTexte'], nil],false)
      end
    else
      puts '[-] Erreur : tirerAides'
    end
  end

  @Override
  ##
  # Permet de créer le bouton pour montrer l'aide.
  # @return [Gtk::Button] Le bouton montrer
  def creerBoutonMontrer()
    if(@tabAides.length != 0)
      btnMontrer = Gtk::Button.new(label: "#{$local["btnMontrer"]} : + 10s")
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
end