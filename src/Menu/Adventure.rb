require 'gtk3'
require 'yaml'
require_relative "../Methode/outils.rb"
require_relative '../Grille/GrilleAventureUI.rb'

##
# Classe permettante de représenter le sélecteur du mode aventure.
# @author Moustapha TSAMARAYEV
class Adventure
	##
    # Les variables de classe sont :
	# curLVL		: Le niveau courant
	# progression	: Le tableau qui représente la progression dans le mode aventure
	# preview		: Le widget qui contient l'image-preview de niveau courant
	# barre			: La barre de progression
	# lvlName		: Le widget qui contient le texte avec le nom de niveau
	# path			: Le chemin vers le fichier de niveau courant
	#

	##########################################
	# This variable represents current level #
	##########################################
	@@curLVL = 0

	#############################################################
	# @@progression is an array of form "2,2,1,0,0,0,0,0,"		#
	# Numbers in this array represent progression of each level.#
	# 0 -> player haven't started this level yet				#
	# 1 -> player is currently on this level					#
	# 2 -> player have succesfully finished this level			#
	#############################################################
	@@progression ||= []


	##
    # Permet de créer le container et l'affecter à la fenêtre.
    def creerFenetreEtFormat()
        #On met du padding entre les lignes
        @grid.set_row_spacing(10)
        @window.add(@grid)
        return self
	end

    ##
    # Constructeur de la classe Parametre.
    # @param window [Gtk::Window] Fenêtre
	# @param fenetrePrec [Gtk::Grid] Le container précédent
    def Adventure.creer(window,fenetrePrec)
        new(window,fenetrePrec)
    end

	@Override
 	##
	# Ré-définition de la méthode initialize.
    # @param window [Gtk::Window] Fenêtre
	# @param fenetrePrec [Gtk::Grid] Le container précédent
    def initialize(window,fenetrePrec)

		#######################
		# BASE INITIALIZATION #
		#######################

        @window = window
        @fenetrePrec = fenetrePrec
        @grid = Gtk::Grid.new
        creerFenetreEtFormat()
		@title = Gtk::Label.new($local["mode_adv"])
		@title.set_name("#{$theme}Title")
		@grid.attach(@title,0,0,3,1)
        @grid.set_column_homogeneous(true)
		@grid.set_row_homogeneous(false)
		@grid.set_row_spacing(10)
        @window.set_title($local["w_adv_title"])
        @title = Gtk::Label.new($local["adv_title"])

		###################################
		# BUTTON AND LABEL INITIALIZATION #
		###################################


		chargerProgression()
		@@curLVL=Adventure.progressionCourant

		#Bouton qui contient l'image de niveau courant
		@@preview=Gtk::Button.new(:label=>"")
		@@preview.set_name("#{$theme}Preview#{@@curLVL}")
		@@preview.set_alignment(1,0.5)
		@grid.attach(@@preview, 0, 1, 3, 1)


		#La barre de progression
		@@barre=Gtk::ProgressBar.new().set_fraction(@@curLVL/8.0)
		@grid.attach(@@barre, 0, 2, 3, 1)

		#Label de niveau courant
		str_curLVL=@@curLVL+1
		lvl_display=$local['level']+"#{str_curLVL}"
		@@lvlName = Gtk::Label.new(lvl_display)
		@grid.attach(@@lvlName,1,3,1,1)

		#Bouton 'precedent'
		prev_lvl = Gtk::Button.new(:label=>"⇐")
		prev_lvl.set_name("#{$theme}BoutonAdv")
    	prev_lvl.relief = Gtk::ReliefStyle::NONE
		@grid.attach(prev_lvl,0,3,1,1)

		#Bouton 'suivant'
		next_lvl = Gtk::Button.new(:label=>"⇒")
		next_lvl.set_name("#{$theme}BoutonAdv")
    	next_lvl.relief = Gtk::ReliefStyle::NONE
		@grid.attach(next_lvl,2,3,1,1)

		#Bouton 'jouer'
		start = Gtk::Button.new(:label=>$local["btnJouer"])
		start.set_name("#{$theme}BoutonAdv")
    	start.relief = Gtk::ReliefStyle::NONE
		@grid.attach(start,1,4,1,1)

		#Bouton 'remise à zero'
		reset = Gtk::Button.new(:label => "⟲")
		reset.set_alignment(0.76,0.5)
		reset.set_name("#{$theme}UnderButton")
		reset.relief = Gtk::ReliefStyle::NONE
		@grid.attach(reset,1,4,2,1)

		#Bouton 'retour'
        button = Gtk::Button.new(:label => $local["back"])
		button.set_name("#{$theme}BoutonAdv")
        @grid.attach(button,1,5,1,1)

		##########################
		# PATH TO CURRENT LEVEL  #
		##########################

        @@path="./ressources/maps/Aventure/#{@@curLVL}"

		#########################
		# CLICK EVENT LISTENERS #
		#########################

		#Bouton 'jouer'
		start.signal_connect("clicked"){
			@@path= "./ressources/maps/Aventure/#{@@curLVL}"
			@window.remove(@grid)
			GrilleAventureUI.creer(@@path,@window,@grid)
		}

		#Bouton 'remise à zero'
		reset.signal_connect("clicked"){
			response=popup_message(@window,true, $local["reset_message"])
			if response==1
				@@curLVL=0
				@@progression=['1','0','0','0','0','0','0','0','0']
				@@curLVL=Adventure.progressionCourant()
				Adventure.refresh()
				Adventure.sauvegarderProgression()
				supprimerFichiersSauvegarde()
			end
		}

		#Bouton 'precedent'
		prev_lvl.signal_connect("clicked"){
			#Incremente le niveau courant si possible
			if @@curLVL>0
				@@curLVL-=1
				@@path="./ressources/maps/Aventure/#{@@curLVL}"
				Adventure.refresh()
			end
		}

		#Bouton 'suivant'
		next_lvl.signal_connect("clicked"){
			#Decremente le niveau courant si possible
			if @@curLVL<8 && @@progression[@@curLVL+1]!="0"
				@@curLVL+=1
				@@path="./ressources/maps/Aventure/#{@@curLVL}"
				Adventure.refresh()
			end
		}

        #Bouton 'retour'
        button.signal_connect("clicked"){
            @window.set_title($local["w_main_menu"])
            @window.remove(@grid)
            @window.add(@fenetrePrec)
            @window.show_all
        }
        @window.show_all
    end


	##
	# Permet de charger la progression depuis le fichier progression.txt.
	def chargerProgression()

		path='./ressources/maps/Aventure/progression.txt'
		if(File.exist?(path))
			input=File.read(path).split(',')
			input.each{|c| @@progression << c.dup}
		else
			File.write(path,"1,0,0,0,0,0,0,0,0")
			input=File.read(path,).split(',')
			input.each{|c| @@progression << c.dup}
		end

		return self
	end

	##
	# Permet de sauvegarder la progression dans le fichier.
	def self.sauvegarderProgression()
		path='./ressources/maps/Aventure/progression.txt'
		File.open(path,'w') do |input|
			input.puts(@@progression.join(','))
		end
		return self
	end

	##
	# Permet de récupérer la progression courante.
	# @return [Integer] L'indice de la progression
	def self.progressionCourant()
		@@progression.each_with_index do |status, position|
			if status == "1"
				return position
			end
		end
		return 8
	end


	##
	# Permet de faire avancer la progression.
	# Avant : 2,1,0,0,0.
	# Après : 2,2,1,0,0.
	def self.avance
		if @@progression[@@curLVL] != '2'
			@@progression[@@curLVL] = '2'
			if @@curLVL < 8 && (@@progression[@@curLVL += 1]!='2' || @@progression[@@curLVL += 1]!=nil)
		  		@@progression[@@curLVL] = '1'
			end
			@@path="./ressources/maps/Aventure/#{@@curLVL}"
		end
		return self
	end

	##
	# Permet de rafraichir tous les boutons et les labels.
	def self.refresh
		str_curLVL=@@curLVL+1
		lvl_display=$local['level']+"#{str_curLVL}"
		@@lvlName.set_label(lvl_display)
		@@preview.set_name("#{$theme}Preview#{@@curLVL}")
		@@barre.set_fraction(@@curLVL/8.0)
		return self
	end


	##
	# Permet d'afficher la progression.
	def self.getProgress
		puts "==="
		puts @@progression
		puts "==="
		return self
	end


	##
	# Dans le cas d'une remise à zéro, permet de détruire tous les fichiers de sauvegarde.
	def supprimerFichiersSauvegarde()
		for i in 0..8
			supprimerFichierSauvegarde(i)
		end
		return self
	end


	##
	# Permet de supprimer le fichier de sauvegarde en fonction d'un id donné.
	# @param id [Integer] Le niveau
	def supprimerFichierSauvegarde(id)
		path="./ressources/maps/Aventure/#{id}save.txt"
		File.delete(path) if File.exist?(path)
		return self
	end
	private_class_method:new
end
