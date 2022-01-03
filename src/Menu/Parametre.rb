
require 'gtk3'
require 'yaml'

##
#	Classe permettante d'afficher le menu des paramètres.
#	Autheur : GIROD Valentin
class Parametre

  ##
	#	Permet de créer le container et l'affecter à la fenêtre.
  def creerFenetreEtFormat()
		#On défini que toutes les colonnes sont homogènes
    @grid.set_column_homogeneous(@grid)
    #On met du padding entre les lignes
    @grid.set_row_spacing(20)
    @window.add(@grid)
    return self
	end

  ##
  # Constructeur de la classe Parametre.
  # @param window [Gtk::Window] La fenêtre
	# @param fenetrePrec [Gtk::Container] Le container précédent
  # @param nomFenetrePrec [Gtk::Container] Le nom de la fenêtre précédente
  # @param uiPrec L'affichage précédent
  def Parametre.creer(window,fenetrePrec,nomFenetrePrec,uiPrec)
    new(window,fenetrePrec,nomFenetrePrec,uiPrec)
  end

  @Override
 	##
	# Re-définition de la méthode initialize.
  # @param window [Gtk::Window] La fenêtre
	# @param fenetrePrec [Gtk::Container] Le container précédent
	# @param nomFenetrePrec [Gtk::Container] Le nom de la fenêtre précédente
  # @param uiPrec L'affichage précédent
  def initialize(window,fenetrePrec,nomFenetrePrec,uiPrec)
    @window = window
    @fenetrePrec = fenetrePrec

    @grid = Gtk::Grid.new
    creerFenetreEtFormat()
    param =  YAML.load(File.read("./ressources/parametres.yml"))
    @window.set_title("Paramètres - Hashi")

    #création des labels des paramètres
    titre = Gtk::Label.new($local["settings"])
    titre.set_name("#{$theme}Title")
    labelRes = Gtk::Label.new($local["res"])
    labelRes.set_name("#{$theme}Text")
    labelLang = Gtk::Label.new($local["lang"])
    labelLang.set_name("#{$theme}Text")
    labelTheme = Gtk::Label.new($local["theme"])
    labelTheme.set_name("#{$theme}Text")
    labelFullSc = Gtk::Label.new($local["fscr"])
    labelFullSc.set_name("#{$theme}Text")

    #création des boutons appliquer et plein écran
    boutonFullSc = Gtk::CheckButton.new().set_active(param["fullScreen"])
    boutonAppliquer = Gtk::Button.new(:label=>$local["apply"])
    button = Gtk::Button.new(:label => $local["back"])

    tmp = []

    tmp << "#{@window.size[0]}x#{@window.size[1]}"

    i = 650
    while i <= 1000
      tmp << "#{i}x#{i}"
      i+=50
    end


    #créations des menus de choix de résolution, de langue et de thème
    sizes = tmp.uniq
    boutonRes = creerListeComboText(sizes)
    boutonRes.set_name("#{$theme}ComboBoxText")
    boutonLang = creerListeComboText(['Français', 'English', '简体中文', 'Русский'])
    boutonLang.set_name("#{$theme}ComboBoxText")
    boutonTheme = creerListeComboText(['light', 'dark'])
    boutonTheme.set_name("#{$theme}ComboBoxText")
    boutonAppliquer.set_name("#{$theme}Bouton")
    button.set_name("#{$theme}Bouton")

    currLang=boutonLang.active_text()
    case param["langue"]
    when "fr"
      boutonLang.set_active(0)
    when "en"
      boutonLang.set_active(1)
    when "ch"
      boutonLang.set_active(2)
    when "ru"
      boutonLang.set_active(3)
    end

    case param["theme"]
    when "light"
      boutonTheme.set_active(0)
    when "dark"
      boutonTheme.set_active(1)
    end

    #placement de tous les boutons et labels dans la grille
    @grid.attach(titre,1,0,2,1)
    @grid.attach(labelRes,0,1,2,1)
    @grid.attach(boutonRes,2,1,1,1)
    @grid.attach(labelLang,0,2,2,1)
    @grid.attach(boutonLang,2,2,1,1)
    @grid.attach(labelTheme,0,3,2,1)
    @grid.attach(boutonTheme,2,3,1,1)
    @grid.attach(labelFullSc,0,4,2,1)
    @grid.attach(boutonFullSc,2,4,2,1)
    @grid.attach(boutonAppliquer,1,5,2,1)

    #action du bouton pour appliquer les paramètres
    boutonAppliquer.signal_connect("clicked"){
      if(boutonFullSc.active?)
          @window.fullscreen
      else
        @window.unfullscreen
        @window.resize(boutonRes.active_iter.get_value(0).split("x")[0].to_i, boutonRes.active_iter.get_value(0).split("x")[1].to_i)
      end
      param = {"resolution"=>boutonRes.active_iter.get_value(0), "langue"=>getLangId(boutonLang), "theme"=>boutonTheme.active_text(), "fullScreen"=>boutonFullSc.active?}
      File.open("./ressources/parametres.yml", "w") { |file| file.write(param.to_yaml) }
      $lang=getLangId(boutonLang)
      $theme=boutonTheme.active_text()
      @window.set_name($theme)
		  $local=YAML.load(File.read("./ressources/localisation/#{$lang}.yml"))
      if currLang!=$lang
        MenuPrincipal.refreshBtn()
        uiPrec.refreshBtn
      end
      @window.remove(@grid)
      initialize(@window,@fenetrePrec,nomFenetrePrec,uiPrec)
    }
    #Bouton au quitter et placement
    button.signal_connect("clicked"){
      @window.set_title(nomFenetrePrec)
      @window.remove(@grid)
      @window.add(@fenetrePrec)
      @window.show_all
    }
    @grid.attach(button,1,6,2,1)
    @window.show_all

  end

  ##
  # Permet de retourner la langue du bouton active.
  # @param bouton [Gtk::Button] Le bouton comboBox
  # @return [String]
  def getLangId(bouton)
    case bouton.active_text()
    when 'Français'
      return 'fr'
    when 'English'
      return 'en'
    when '简体中文'
      return 'ch'
    when 'Русский'
      return 'ru'
    end
  end
  private_class_method:new
end
