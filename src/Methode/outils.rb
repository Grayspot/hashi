
##
# Méthode de création plus simple pour les Gtk::ComboBoxText à partir d'un tableau.
# @param elts [Gtk::Array] un tableau
# @return [Gtk::ComboBoxText]
def creerListeComboText(elts)
	listeDiff = Gtk::ComboBoxText.new()
	cpt = 0
	for i in elts
		listeDiff.insert_text(cpt,i)
		cpt+=1
	end
	listeDiff.set_active(0)
end

##################################################################
# Pops a message dialog with text given in parameter
# Arguments:
# parent -> parent widget (most of the time @window)
# type -> "true" will create a window with YES/NO buttons, "false" will create a dialog with "OK" button
# message -> text message that will be displayed. String expected.
# Returns:
# In case of dialog type 2, returns 1.
# In case of dialog type 1, returns 1 if you click YES, 0 otherwise
##################################################################
def popup_message(parent,type,message)

	dialog = Gtk::MessageDialog.new(:parent => parent,
											:flags=> :destroy_with_parent,
											:type => :warning,
											:buttons_type => :none,
											:message => message)
	if type
		dialog.add_buttons([$local["dialog_yes"],1],[$local["dialog_no"],0])
	else
		dialog.add_buttons(["OK",1])
	end

	response = dialog.run
	dialog.destroy

	return response

end
