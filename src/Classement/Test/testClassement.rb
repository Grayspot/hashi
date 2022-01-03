require_relative '../Classement.rb'

require 'Gtk3'

Gtk.init
    window = Gtk::Window.new()

    Classement.new(window,nil)

Gtk.main



