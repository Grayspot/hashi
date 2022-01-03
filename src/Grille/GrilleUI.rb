require 'gtk3'
require_relative 'Grille.rb'
require_relative 'Erreur.rb'
require_relative 'Chrono.rb'
require_relative 'Sauvegarde.rb'
require_relative 'Aides.rb'

##
# Représente la grille du jeu en mode normal permettant d'afficher et de jouer au jeu.
# @author DEROUAULT Baptiste
class GrilleUI
    ##
    # Les variables d'instances sont :
    # grid    		    : Le container grid du classement
    # window  		    : La fenêtre
    # fenetre_prec      : Le container précédent
    # button            : Tableau à deux dimensions contenant autant de boutons que de cases
    # cases             : Tableau à deux dimensions contenant toutes les cases du jeu
    # spacerHor         : Tableau contenant tous les boutons permettant la séparation horizontale entre le jeu et les commandes
    # spaceVer          : Tableau contenant tous les boutons permettant la séparation verticale entre le jeu et les commandes
    # undo              : Tableau contenant toutes les actions faites par le joueur
    # redo              : Tableau contenant toutes les actions dé-faites par le joueur
    # timer             : Correspond au chrono du jeu
    # btnQuitter        : Bouton permettant de quitter le jeu
    # buttonAfficher    : Bouton permettant d'afficher le chrono
    # btnHypothese      : Bouton permettant d'éméttre une hypothèse
    # btnBTHyothese     : Bouton permettant de revenir à l'hypothèse
    # btnRedo           : Bouton permettant de défaire un coup
    # btnUndo           : Bouton permettant de refaire le dernier coup défait
    # btnReset          : Bouton permettant de remettre à zéro la partie
    # btnShow           : Bouton permettant d'afficher toutes les erreurs de la partie
    # btnJouer          : Bouton permettant de lancer le jeu
    # btnCheck          : Bouton permettant de vérifier la grille
    # btnHelp           : Bouton permettant d'afficher les aides
    # btnParametres     : Bouton permettant d'afficher les paramêtres
    # verif             : Boolean permettant de savoir si l'on a déjà vérifier la grille pour permettre d'afficher les erreurs
    # sauvegarde        : Tableau contenant toutes les actions pour pouvoir sauvegarder la partie
    # hypothese         : Tableau contenant toutes les actions jusqu'à l'hypothèse
    # retourHypothese   : Boolean permettant de savoir si l'on a déjà fait une hypothèse pour permettre d'y retourner
    # aides             : Instance de la classe aides
    

    ##
    # Permet de récupérer les cases
    attr_reader:cases
    ##
    # Permet de récupérer les boutons de jeu
    attr_reader:button
    ##
    # Permet de récupérer le timer
    attr_reader:timer

    ##
    # Permet d'activer ou non les boutons de jeu.
    # @param eval [Boolean]
    def setSensitiveBoutonsJeu(eval)
        taille = @button.length
        for i in 0..(taille-1)
            for j in 0..(taille-1)
                @button[i][j].set_sensitive(eval)
            end
        end
        return self
    end

    ##
    # Permet d'afficher tous les boutons dans leur forme initiale.
    def razBg()
        #Taille de la matrice carré
        taille = @button.length

        #Boucle afin de parcourir tous les boutons
        for i in 0..(taille-1)
            for j in 0..(taille-1)
                @button[i][j].set_sensitive(true)
                #Cas île
                if(@cases[i][j].estIle?)
                    @button[i][j].set_name("#{$theme}Circle")
                #Cas Pont
                else
                    case @cases[i][j].typeCourant

                    when '|'
                        @button[i][j].set_name("#{$theme}LineVer")
                    when 'H'
                        @button[i][j].set_name("#{$theme}LineDoubleVer")
                    when '-'
                        @button[i][j].set_name("#{$theme}LineHor")
                    when '='
                        @button[i][j].set_name("#{$theme}LineDoubleHor")
                    else
                        @button[i][j].set_name("#{$theme}Custom")
                    end
                end
            end
        end

        return self
    end

    ##
    # Permet de cacher tous les boutons de jeu afin de mettre en pause la partie.
    def hideBtn()
        #Taille de la matrice carée
        taille = @button.length

        #Boucle afin de parcourir tous les boutons
        for i in 0..(taille-1)
            for j in 0..(taille-1)
                #On leur donne la classe hide qui les rends invisibles
                @button[i][j].set_name("hide")
                #On les rends incliquables
                @button[i][j].set_sensitive(false)
            end
        end

        return self
    end

    ##
    # Permet d'afficher une image pour un bouton de jeu suivant sa couleur.
    # @param c [Case] La case concerné
    # @param button [Gtk::Button] Le bouton concerné
    # @param color [String] La couleur voulu
    def imagePourCase(c,button,color)
        #Cas île
        if(c.estIle?)
            if(c.end == 1 && color == "")
                button.set_name("#{$theme}CircleEnd")
            else
                button.set_name("#{$theme}Circle#{color}")
            end
        #Cas Pont
        else
            sens = c.typeCourant

            #On teste le type et le nombre de lien du pont
            case c.nbLiens
            when 0
                button.set_name("#{$theme}Custom")
            when 1
                if(sens == '-')
                    button.set_name("#{$theme}LineHor#{color}")
                else
                    button.set_name("#{$theme}LineVer#{color}")
                end
            when 2
                if(sens == '=')
                    button.set_name("#{$theme}LineDoubleHor#{color}")
                else
                    button.set_name("#{$theme}LineDoubleVer#{color}")
                end
            end
        end

        return self
    end

    ##
    # Permet d'afficher une image pour les boutons de jeu suivant une couleur.
    # @param color [String] La couleur voulu
    def imagePourJeux(color)
        #Taille de la matrice carrée
        taille = @button.length

        #Remise à zéro des boutons de jeu
        for i in 0..(taille-1)
            for j in 0..(taille-1)
                imagePourCase(@cases[i][j],@button[i][j],color)
            end
        end

        return self
    end

    ##
    # Permet de créer une ligne de délimitation entre le jeu et les boutons utilitaires.
    # @param i [Integer] La ligne ou la délimitation doit être
    # @param j [Integer] La taille de la délimitation
    def delimitation(i,j)
        @spacerHor = []
        @spaceVer = []
        #Délimitation des boutons du bas
        #Boucle permettante d'aller jusqu'a la grandeur donnée
        for x in 0..(j-1)
            #On crée un boutons en désactivant ses effets et on le rends incliquables
            @spacerHor[x] = Gtk::Button.new()
            @spacerHor[x].set_name("#{$theme}Custom")
            @spacerHor[x].relief = Gtk::ReliefStyle::NONE
            @spacerHor[x].focus_on_click = false
            @spacerHor[x].set_name("#{$theme}LineHorGray")
            @spacerHor[x].set_sensitive(false)
            @grid.attach(@spacerHor[x],x,j,1,1)
        end

        #Délimitation des boutons de droites
        for y in 0..(i-1)
            @spaceVer[y] = Gtk::Button.new()
            @spaceVer[y].set_name("#{$theme}Custom")
            @spaceVer[y].relief = Gtk::ReliefStyle::NONE
            @spaceVer[y].focus_on_click = false
            @spaceVer[y].set_name("#{$theme}LineVerGray")
            @spaceVer[y].set_sensitive(false)
            @grid.attach(@spaceVer[y],j,y,1,1)
        end

        return self
    end

    ##
    # Retourne vrai si le pont est entravé.
    # @param i [Integer] la coordonnée en hauteur
    # @param j [Integer] la coordonnée en largeur
    # @return [boolean]
    def estEntrave?(i,j)
        #On vérifie que l'on est pas sur un bord car dans ce cas on ne peux pas être en entrave
        if(i > 0 && i < @grille.largeur-1 && j > 0 && j < @grille.hauteur-1)
            #On vérifie que les cases autour soient des îles pour vérifier l'entrave
            if(@cases[i-1][j].estIle? && @cases[i+1][j].estIle? && @cases[i][j-1].estIle? && @cases[i][j+1].estIle?)
                return true
            end
        end
        return false
    end

    ##
    # Traite le cas d'un pont lorsqu'il est entouré d'îles et retourne vrai si le pont est entravé.
    # @param i [Integer] la coordonnée en hauteur
    # @param j [Integer] la coordonnée en largeur
    # @return [boolean]
    def entrave(i,j)
        if(estEntrave?(i,j))
            #Le pattern est de la forme  - = | H 0
            case @cases[i][j].nbLiens
            when 0
                #On ajoute un lien : on est sur -
                @cases[i][j].ajouterLien
                @button[i][j].set_name("#{$theme}LineHor")
                @cases[i][j].typeCourant = "-"
                #On incrémente le nombre de lien des deux îles
                @cases[i][j-1].ajouterLien()
                @cases[i][j+1].ajouterLien()
            when 1
                #On est soit dans le cas - ou |
                if(@cases[i][j].typeCourant == '-')
                    @button[i][j].set_name("#{$theme}LineDoubleHor")
                    @cases[i][j].typeCourant = '='
                    #On incrémente le nombre de lien des deux îles
                    @cases[i][j-1].ajouterLien()
                    @cases[i][j+1].ajouterLien()
                else
                    @button[i][j].set_name("#{$theme}LineDoubleVer")
                    @cases[i][j].typeCourant = 'H'
                    #On incrémente le nombre de lien des deux îles
                    @cases[i-1][j].ajouterLien()
                    @cases[i+1][j].ajouterLien()
                end
                @cases[i][j].ajouterLien
            when 2
                #On est soit dans le case = ou H
                if(@cases[i][j].typeCourant == '=')
                    @button[i][j].set_name("#{$theme}LineVer")
                    @cases[i][j].typeCourant = "|"
                    @cases[i][j].nbLiens = 1

                    #Ici on change de sens du pont vertical à horizontal
                    @cases[i][j-1].enleverLien()
                    @cases[i][j+1].enleverLien()
                    @cases[i][j-1].enleverLien()
                    @cases[i][j+1].enleverLien()

                    @cases[i-1][j].ajouterLien()
                    @cases[i+1][j].ajouterLien()
                else
                    @button[i][j].set_name("#{$theme}Custom")
                    @cases[i][j].typeCourant = ""
                    @cases[i][j].nbLiens = 0

                    @cases[i-1][j].enleverLien()
                    @cases[i+1][j].enleverLien()
                    @cases[i-1][j].enleverLien()
                    @cases[i+1][j].enleverLien()

                end
            end
            @undo.push([i,j])
            return true
        end
        return false
    end

    ##
    # Permet de créer toutes les cases de jeu.
    # Pour les îles pouvoir les afficher / changer leur état fini ou non, un hover qui lorsque que la souris est dessus afficher toutes les ponts possibles.
    # Pour les ponts lorsque l'on clique dessus, met le pont et lorsque l'on place la souris dessus afficher un pont qui peut être mit.
    # Définit également un hover lorsque l'on entre sur la case et le retire quand l'on repart.
    # @param i [Integer] la coordonnée en hauteur
    # @param j [Integer] la coordonnée en largeur
    # @return [Gtk::Button] Le bouton correspondant
    def creerCase(i, j)
        button = Gtk::Button.new()
        button.set_name("#{$theme}Custom")
        button.relief = Gtk::ReliefStyle::NONE
        button.focus_on_click = false

        #Définition du hover lorsque que la souris rentre sur une case
        button.signal_connect("leave"){
            #On a quatres voie à chercher
            #Nord - Sud - Est - Ouest
            if(@cases[i][j].estIle?)
                hover = @cases[i][j].ilePont()

                for c in hover
                    if(@cases[c[0]][c[1]].nbLiens == 0)
                        @button[c[0]][c[1]].set_name("#{$theme}Custom")
                    end
                end
            #On a que deux voie à chercher
            #Soit c'est un pont horizontal
            #Soit c'est un pont vertical
            elsif(@cases[i][j].estLien?)
                #On cherche deux pont, horizontal et vertical
                pontY = @cases[i][j].pontHauteurExiste?()
                pontX = @cases[i][j].pontLargeurExiste?()

                #On regarde si le pont peut être contruit == qu'il est plus grand que 0 et que tous les éléments du pont ont le même nombre de lien
                if(pontY.length != 0)
                    pontY = @cases[i][j].homogenePont?(pontY) ? pontY : []
                end
                if(pontX.length != 0)
                    pontX = @cases[i][j].homogenePont?(pontX) ? pontX : []
                end

                #On vérifie que le pont est vide, sinon le hover n'a pas de sens ici
                if(pontY.length != 0)
                    pontY = @cases[i][j].pontVide?(pontY) ? pontY : []
                end
                if(pontX.length != 0)
                    pontX = @cases[i][j].pontVide?(pontX) ? pontX : []
                end

                if((pontY.length < pontX.length && pontY.length != 0) ||(pontY.length != 0 && pontX.length == 0))
                    #On traite pont de Y car Y < X et Y != 0 ou X = 0 et Y != 0
                    for c in pontY
                        @button[c[0]][c[1]].set_name("#{$theme}Custom")
                    end
                else
                    #Ici Y = 0 et Y > X
                    if(pontX.length != 0)
                        #On traite pont de X
                        for c in pontX
                            @button[c[0]][c[1]].set_name("#{$theme}Custom")
                        end
                    end
                end
            end
        }

        #Suppression du hover lorsque que la souris sort sur une case
        button.signal_connect("enter"){
            #On a quatres voie à chercher
            if(@cases[i][j].estIle? && @cases[i][j].end == 0)
                hover = @cases[i][j].ilePont()

                for c in hover
                    if(@cases[c[0]][c[1]].nbLiens == 0)
                        #Vertical
                        if(c[0] - i != 0)
                            @button[c[0]][c[1]].set_name("#{$theme}LineVerGreen")
                        #Horizontal
                        else
                            @button[c[0]][c[1]].set_name("#{$theme}LineHorGreen")
                        end
                    end
                end
            #On a que deux voie à chercher
            elsif(@cases[i][j].estLien?)
                pontY = @cases[i][j].pontHauteurExiste?()
                pontX = @cases[i][j].pontLargeurExiste?()

                if(pontY.length != 0)
                    pontY = @cases[i][j].homogenePont?(pontY) ? pontY : []
                end
                if(pontX.length != 0)
                    pontX = @cases[i][j].homogenePont?(pontX) ? pontX : []
                end

                if(pontY.length != 0)
                    pontY = @cases[i][j].pontVide?(pontY) ? pontY : []
                end
                if(pontX.length != 0)
                    pontX = @cases[i][j].pontVide?(pontX) ? pontX : []
                end

                if((pontY.length < pontX.length && pontY.length != 0) ||(pontY.length != 0 && pontX.length == 0))
                    #On traite pont de Y car Y < X et Y != 0 ou X = 0 et Y != 0
                    for c in pontY
                        @button[c[0]][c[1]].set_name("#{$theme}LineVerGreen")
                    end
                else
                    #Ici Y = 0 et Y > X
                    if(pontX.length != 0)
                        #On traite pont de X
                        for c in pontX
                            @button[c[0]][c[1]].set_name("#{$theme}LineHorGreen")
                        end
                    end
                end
            end
        }

        #Lorsque que la case est une ile alors on met une image du numéro desus
        if(@cases[i][j].estIle?)
            button.label = @cases[i][j].to_s
            button.set_name("#{$theme}Circle")
        end

        #Lorsque que l'on clique sur la case
        button.signal_connect("clicked"){
            imagePourJeux("")
            #Event sur une ile lorsque l'on clique dessus
            if(@cases[i][j].estIle?)
                @undo.push([i,j])

                #Échangeur d'état
                @cases[i][j].end = @cases[i][j].end == 1 ? 0 : 1

                #On regarde si l'île est complété ou non afin de changer son état
                if(@cases[i][j].end == 1)
                    button.set_name("#{$theme}CircleEnd")
                else
                    button.set_name("#{$theme}Circle")
                end




            #Event sur un lien potentioel lorsque l'on clique dessus
            elsif(@cases[i][j].estLien?)
                if(!entrave(i,j))

                    #On demande à la case de nous renvoyer un tableau à deux dimensions de coordonées avec toutes les coordonnées qui corresponde au ponts ainsi qu'ajoute un lien au compteur de toutes les @cases ainsi qu'au deux iles
                    tab = @cases[i][j].creerPont()

                    if(tab.length > 0)
                        sens = ""
                        @undo.push([i,j])

                        #On doit regarder si le pont est horizontal ou vertical
                        #Première condition : tab.length == 1 && i>=1 && @cases[i-1][j].estIle? on test si le pont est de longueur 1 qu'il n'est pas au bord en haut et que la case d'au dessus est une ile alors c'est un pont vertical
                        #Deuxième condition : tab.first[0] - tab.last[0] != 0 on test si la valeur changeant est celle de la hauteur
                        if((tab.length == 1 && i>=1 && i < @grille.hauteur-1 && @cases[i-1][j].estIle? && @cases[i+1][j].estIle?) || (tab.first[0] - tab.last[0] != 0))
                            sens = "|"
                        elsif((tab.length == 1 && j>=1 && j < @grille.largeur-1 && @cases[i][j-1].estIle?) || (tab.first[1] - tab.last[1] != 0))
                            sens = "-"
                        end
                        for val in tab
                            case @cases[val[0]][val[1]].nbLiens
                            when 0
                                @button[val[0]][val[1]].set_name("#{$theme}Custom")
                                @cases[val[0]][val[1]].typeCourant = ""
                            when 1
                                if(sens == '-')
                                    @button[val[0]][val[1]].set_name("#{$theme}LineHor")
                                else
                                    @button[val[0]][val[1]].set_name("#{$theme}LineVer")
                                end
                                @cases[val[0]][val[1]].typeCourant = sens
                            when 2
                                if(sens == '-')
                                    @button[val[0]][val[1]].set_name("#{$theme}LineDoubleHor")
                                    @cases[val[0]][val[1]].typeCourant = "="
                                else
                                    @button[val[0]][val[1]].set_name("#{$theme}LineDoubleVer")
                                    @cases[val[0]][val[1]].typeCourant = "H"
                                end
                            end
                        end
                    end
                end
            end
        }
        return button
    end

    ##
    # Permet de stopper les threads en cours.
    def stopThread()
        if(@timer != nil)
            @timer.stop()
        end

        return self
    end

    ##
    # Comportement lorsque l'on clique sur le bouton quitter, stop le thread et enlève le container et le remplace par le précédent.
    def comportementQuitter()
        if(@timer != nil)
            sauvegarde()
            stopThread()
        end
        @window.set_title($local["w_main_menu"])
        @window.remove(@grid)
        @window.add(@fenetre_prec)
        @window.show_all

        return self
    end

    ##
    # Permet de créer le bouton quitter et sa routine lorsqu'il est cliqué.
    # @return [Gtk::Button]
    def quitter()
        #Bouton au quitter et placement
        button = Gtk::Button.new(:label => "✖")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            comportementQuitter()
        }
        return button
    end

    ##
    # Permet de créer le bouton Jouer et sa routine.
    # @return [Gtk::Button]
    def jouer()
        #Bouton au quitter et placement
        button = Gtk::Button.new(:label => "▶")
        button.set_name("#{$theme}BtnIcon")
        return button
    end

    ##
    # Permet de compter les erreurs et les afficher.
    # @param tab [Array] Le tableau contenant toutes les coordonnées
    def compteErreurs(tab)
        #On compte les erreurs
        cptErreurIle = 0
        cptErreurPont = 0
        for coord in tab
            #Ile on incrémente le compte
            if(@cases[coord[0]][coord[1]].estIle?())
                cptErreurIle+=1
            #Pont on incrémente le compteur et on enlève tous les composants du pont
            else
                cptErreurPont+=1

                #Horizontal
                if(@cases[coord[0]][coord[1]].typeCourant == '-' || @cases[coord[0]][coord[1]].typeCourant == '=')
                    i = coord[0]
                    j = coord[1]-1
                    #gauche
                    while(!@cases[i][j].estIle?)
                        tab.delete([i,j])
                        j-=1
                    end

                    i = coord[0]
                    j = coord[1]+1
                    #droite
                    while(!@cases[i][j].estIle?)
                        tab.delete([i,j])
                        j+=1
                    end


                #Vertical
                elsif(@cases[coord[0]][coord[1]].typeCourant == '|' || @cases[coord[0]][coord[1]].typeCourant == 'H')
                    i = coord[0]-1
                    j = coord[1]
                    #haut
                    while(!@cases[i][j].estIle?)
                        tab.delete([i,j])
                        i-=1
                    end

                    i = coord[0]+1
                    j = coord[1]
                    #bas
                    while(!@cases[i][j].estIle?)
                        tab.delete([i,j])
                        i+=1
                    end
                end
            end
        end
        @verif = true
        rendreAccessibleShow()
        popup_message(@window,false,"#{$local["ilY"]} #{cptErreurIle+cptErreurPont} #{$local["erreur"]}\n -#{cptErreurIle} #{$local["ile"]}\n -#{cptErreurPont} #{$local["pont"]}")

        return self
    end

    ##
    # Permet de quitter le jeu.
    def finPartie()
        @btnQuitter.clicked

        return self
    end

    ##
    # Définit le comportement lorsque que l'on clique sur le bouton check.
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
            finPartie()
        end

        return self
    end

    ##
    # Permet de créer le bouton Check et sa routine.
    # @return [Gtk::Button]
    def check()
        #Bouton check et placement
        button = Gtk::Button.new(:label => "✔️")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            comportementCheck()
        }
        return button
    end

    ##
    # Permet de créer le bouton afficher pour le chrono.
    # @return [Gtk::Button]
    def creerButtonAfficher()
        buttonAfficher = Gtk::Button.new()
        buttonAfficher.set_name("#{$theme}BtnIcon")
        return buttonAfficher
    end

    ##
    # Permet de créer le timer pour le jeu.
    # @return [Chrono]
    def creerTimer()
        timer = Chrono.creer(@buttonAfficher).start()
        timer.pause()
        timer.raz()
        return timer
    end

    ##
    # Définit le comportement lorsque l'on clique sur le bouton undo, retire le dernier coup.
    def comportementUndo()
        if(@undo.length>0)

            i=@undo[@undo.length-1][0]
            j=@undo[@undo.length-1][1]


            #Dans le hashi pour annuler un coup on doit faire le nombre de position - 1
            #   Lien : 0 - = ou 0 | H donc 3 - 1
            #   Pont : fini ou Non Fini donc 2 - 1
            #   Cas Entrave : 0 - = | H donc 5 - 1

            if(estEntrave?(i,j))
                time = 4
            elsif(@cases[i][j].estLien?)
                time = 2
            else
                time = 1
            end

            for n in 0..(time-1)
                @button[i][j].clicked
                @undo.pop()
            end

            @redo.push(@undo.pop())

        end

        return self
    end

    ##
    # Permet de créer le bouton undo - Retour En Arrière.
    # @return [Gtk::Button]
    def setUndo()
        #Bouton undo
        button = Gtk::Button.new(:label => "↶")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            comportementUndo()
        }
        return button
    end

    ##
    # Définit le comportement lorsque l'on clique sur le bouton redo, remet le dernier coup retiré.
    def comportementRedo()
        if(@redo.length>0)
            i=@redo[@redo.length-1][0]
            j=@redo[@redo.length-1][1]


            @button[i][j].clicked
            @undo.pop()

            @undo.push(@redo.pop())
        end

        return self
    end

    ##
    # Permet de créer le bouton redo - Retour En Avant.
    # @return [Gtk::Button] Le bouton redo
    def setRedo()
        #Bouton redo
        button = Gtk::Button.new(:label => "↷")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            comportementRedo()
        }
        return button
    end

    ##
    # Définit le comportement lorsque l'on clique sur le bouton lancer, met en pause ou reprend la partie.
    def comportementLancer()
        if(@timer.estPause?)
            @buttonLancer.label="‖"
            @timer.reprendre()
            razBg()
            @btnHypothese.set_sensitive(true)
            @btnBTHypothese.set_sensitive(true)
            @btnRedo.set_sensitive(true)
            @btnUndo.set_sensitive(true)
            @btnReset.set_sensitive(true)
            @btnCheck.set_sensitive(true)
            @btnHelp.set_sensitive(true)
        else
            @buttonLancer.label="▶"
            @timer.pause()
            hideBtn()
            @btnHypothese.set_sensitive(false)
            @btnBTHypothese.set_sensitive(false)
            @btnRedo.set_sensitive(false)
            @btnUndo.set_sensitive(false)
            @btnReset.set_sensitive(false)
            @btnCheck.set_sensitive(false)
            @btnHelp.set_sensitive(false)
        end
        
        return self
    end

    ##
    # Permet de créer le boutton lancer.
    # @return [Gtk::Button]
    def creerButtonLancer()
        buttonLancer = Gtk::Button.new(:label => "‖")
        buttonLancer.set_name("#{$theme}BtnIcon")
        buttonLancer.signal_connect("clicked"){
            comportementLancer()
        }
        return buttonLancer
    end

    ##
    # Défini le comportement lorsque l'on clique sur le bouton montrer : montre toutes les erreurs.
    def comportementShow()
        if(@verif)
            @verif = false
            rendreAccessibleShow()

            imagePourJeux("")

            tab = @erreur.donneLesErreurs()

            etat = tab.shift()

            if(etat == 0)
                for coord in tab
                    imagePourCase(@cases[coord[0]][coord[1]],@button[coord[0]][coord[1]],"Red")
                end
            end
        end
        return self
    end

    ##
    # Permet de créer le bouton montrer.
    # @return [Gtk::Button]
    def show()
        #Bouton show et placement
        button = Gtk::Button.new(:label => "👁")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            comportementShow()
        }
        return button
    end

    ##
    # Définit le comportement lorsque l'on clique sur le bouton aides : affiche une nouvelle page pour choisir son aide.
    def comportementHelp()
        @aides.lancer()
        return self
    end

    ##
    # Permet de créer le bouton aides.
    # @return [Gtk::Button]
    def help()
        button = Gtk::Button.new(:label => "❓")
        button.set_name("#{$theme}BtnIcon")

        button.signal_connect("clicked"){
            comportementHelp()
        }
        return button
    end

    ##
    # Permet de rendre accessible ou non le bouton montrer.
    def rendreAccessibleShow()
        if(@verif)
            @btnShow.set_name("#{$theme}BtnIcon")
        else
            @btnShow.set_name("#{$theme}BtnDisable")
        end

        return self
    end

    ##
    # Permet de sauvegarder la partie en l'état, le temps et les actions.
    def sauvegarde()
        @timer.pause()
        @sauvegarde.enregistrer(@timer.temps,@undo)

        return self
    end

    ##
    # Permet de rejouer les coups.
    # @param tab [Array] Tableau contenant toutes les positions ou les coups doivent être joués
    def rejouerCoups(tab)
        #Coups à joueur

        for c in tab
            if(@cases[c[0]][c[1]].estLien?)

                if(!entrave(c[0],c[1]))

                    #On demande à la case de nous renvoyer un tableau à deux dimensions de coordonées avec toutes les coordonnées qui corresponde au ponts ainsi qu'ajoute un lien au compteur de toutes les @cases ainsi qu'au deux iles
                    tab = @cases[c[0]][c[1]].creerPont()

                    if(tab.length > 0)
                        sens = ""
                        @undo.push([c[0],c[1]])

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

    ##
    # Permet de charger la partie depuis la sauvegarde.
    def restitue()
        tab = @sauvegarde.restituer()

        #Présence de sauvegarde
        if(tab.length != 0)
            @timer.ajouterTemps(tab.shift())

            rejouerCoups(tab)
        end

        return self
    end

    ##
    # Définit le comportement lorsque l'on clique sur le bouton reset : retire tous les coups joués et remet à zéro le chrono.
    def comportementReset()
        if(@undo.length>0 || @timer.temps != 0)
            #On remet à 0 le jeu
            resetCases()
            imagePourJeux("")

            #On remet à 0 le undo redo
            @undo = []
            @redo = []

            @buttonLancer.label="⏵"

            @timer.start()
            sleep(0.1)
            @timer.pause()
            hideBtn()
        end

        return self
    end

    ##
    # Permet de remettre à zéro toutes les îles.
    def resetCases()
        taille = @button.length
        #On remet à 0 le jeu
        for i in 0..(taille-1)
            for j in 0..(taille-1)
                @cases[i][j].resetLien()
            end
        end

        return self
    end

    ##
    # Permet de créer le bouton reset.
    # @return [Gtk::Button]
    def reset()
        #Bouton redo
        button = Gtk::Button.new(:label => "⟲")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            comportementReset()
        }
        return button

    end

    ##
    # Permet de créer le bouton paramètres.
    # @return [Gtk::Button]
    def parametres()
        #Bouton parametres
        button = Gtk::Button.new(:label => "⚙")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
            @window.remove(@grid)
            Parametre.creer(@window,@grid,$local["ingame"],self)
        }
        return button
    end

    ##
    # Définit le comportement lorsque l'on clique sur le bouton hypothèses : crée un point de sauvegarde.
    def comportementHypothese()
        @hypothese = []
        #On sauvegarde le bouton undo c'est à dire toutes les actions
        for coup in @undo
            @hypothese.push(coup)
        end
        @retourHypothese = true
        rendreAccessibleHypothese()
        popup_message(@window,false,$local["hypothese"])
        
        return self
    end

    ##
    # Permet de créer le bouton hypothese.
    # @return [Gtk::Button]
    def hypothese()
        #Bouton hypothese
        button = Gtk::Button.new(:label => "⚑")
        button.set_name("#{$theme}BtnIcon")
        button.signal_connect("clicked"){
           comportementHypothese()
        }
        @retourHypothese = false
        return button
    end

    ##
    # Permet de rendre accessible le bouton retour à l'hypothèse ou non.
    def rendreAccessibleHypothese()
        if(@retourHypothese)
            @btnBTHypothese.set_name("#{$theme}BtnIcon")
        else
            @btnBTHypothese.set_name("#{$theme}BtnDisable")
        end

        return self
    end

    ##
    # Définit le comportement lorsque l'on clique sur le bouton retour à l'hypothèse : retour au point de sauvegarde.
    def comportementRetourToHypothese()
        if(@retourHypothese)
            @retourHypothese = false
            rendreAccessibleHypothese()
            imagePourJeux("")

            resetCases()
            @undo = []
            @redo = []

            rejouerCoups(@hypothese)

            imagePourJeux("")
        end

        return self
    end

    ##
    # Permet de créer le bouton retour à l'hypothèse.
    # @return [Gtk::Button]
    def retourToHypothese()
        #Bouton show et placement
        button = Gtk::Button.new(:label => "⚐")
        button.set_name("#{$theme}BtnDisable")
        button.signal_connect("clicked"){
           comportementRetourToHypothese()
        }
        return button
    end

    ##
    # Permet de mettre à jour le texte si la langue change.
    def refreshBtn()
        if(@timer != nil)
            imagePourJeux("")
            @btnCheck.set_name("#{$theme}BtnIcon")
            rendreAccessibleShow()
            @buttonLancer.set_name("#{$theme}BtnIcon")
            @buttonAfficher.set_name("#{$theme}BtnIcon")
            @btnUndo.set_name("#{$theme}BtnIcon")
            @btnRedo.set_name("#{$theme}BtnIcon")
            @btnReset.set_name("#{$theme}BtnIcon")
            @btnHypothese.set_name("#{$theme}BtnIcon")
            rendreAccessibleHypothese()
            @btnHelp.set_name("#{$theme}BtnIcon")
        end

        
        @btnJouer.set_name("#{$theme}BtnIcon")
        @btnQuitter.set_name("#{$theme}BtnIcon")
        @btnParametres.set_name("#{$theme}BtnIcon")

        return self
	end

    @Override
    ##
    # Méthode d'initialisation pour la classe GrilleUI.
    # @param file [String] le fichier contenant la grille
    # @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
    def initialize(file,window,fenetre_prec)
        @window = window
        @fenetre_prec = fenetre_prec

        @window.set_title($local["ingame"])

        @undo=[]
        @redo=[]

        @sauvegarde = Sauvegarde.creer(file)


        @grid = Gtk::Grid.new()

        timer = nil

        @window.signal_connect('destroy'){
            stopThread()
            Gtk.main_quit
        }

        #On défini que toutes les colonnes sont homogènes
        @grid.set_column_homogeneous(@grid)
        @grid.set_row_homogeneous(@grid)
        #On met du padding entre les lignes
        @window.add(@grid)

        @grille = Grille.creer("#{file}.txt")
        @grille.chargerGrille()
        @cases = @grille.cases
        gridJ = @grille.largeur
        gridI = @grille.hauteur


        delimitation(gridI,gridJ)
        gridI+=1
        @btnJouer = jouer()

        @button = Array.new(@grille.hauteur) { Array.new(@grille.largeur) }

        for i in 0..(@grille.hauteur-1)
            for j in 0..(@grille.largeur-1)
                @button[i][j] = creerCase(i, j)
                @grid.attach(@button[i][j],j,i,1,1)
            end
        end

        @btnQuitter = quitter()
        @grid.attach(@btnQuitter,gridJ+1,gridI,1,1)

        cptVertical = 0

        @btnParametres = parametres()
        @grid.attach(@btnParametres,gridJ+1,cptVertical,1,1)

        hideBtn()
        @btnJouer.signal_connect("clicked"){

            razBg()

            @buttonAfficher = creerButtonAfficher()
            @timer = creerTimer()
            @aides = Aides.creer(self)
            @buttonLancer = creerButtonLancer()
            @timer.reprendre()
            @grid.attach(@buttonLancer,3,gridI, 1, 1)
            @grid.attach(@buttonAfficher, 4, gridI, 2, 1)

            @btnReset = reset()
            @grid.attach(@btnReset,gridJ-1,gridI,1,1)

            @verif = false
            @erreur = Erreur.creer(@cases)

            @btnShow = show()
            @grid.attach(@btnShow,1,gridI,1,1)
            rendreAccessibleShow()

            @btnUndo = setUndo()
            @grid.attach(@btnUndo,6,gridI,1,1)

            @btnRedo = setRedo()
            @grid.attach(@btnRedo,7,gridI,1,1)

            @btnCheck = check()
            @grid.attach(@btnCheck,0,gridI,1,1)

            cptVertical+=2

            #Utiliser cptVertical pour afficher a gauche

            @btnHypothese = hypothese()
            @grid.attach(@btnHypothese,gridJ+1,cptVertical,1,1)
            cptVertical+=1

            @btnBTHypothese = retourToHypothese()
            @grid.attach(@btnBTHypothese,gridJ+1,cptVertical,1,1)
            rendreAccessibleHypothese()

            cptVertical+=2
            @btnHelp = help()
            @grid.attach(@btnHelp,gridJ+1,cptVertical,1,1)

            gridI+=1
            @window.show_all
            @grid.remove(@btnJouer)

            restitue()

            imagePourJeux("")
        }
        @grid.attach(@btnJouer,gridJ/2,gridI,1,1)
        @window.show_all
    end

    ##
    # Constructeur de la casse GrilleUI.
    # @param file [String] le fichier contenant la grille
    # @param window [Gtk::Window] La fenêtre
	# @param fenetre_prec [Gtk::Container] Le container précédent
    def GrilleUI.creer(file,window,fenetre_prec)
        new(file,window,fenetre_prec)
    end

    private_class_method:new
end
