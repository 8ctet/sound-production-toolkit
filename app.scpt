--Version 1.0.1
set appPath to POSIX path of (path to me)
repeat
	-- Créer la fenêtre principale avec deux boutons et un titre
	set userChoice to button returned of (display dialog "Choisissez une action :" buttons {"Extraire l'audio et ajouter un bip", "Remplacer l'audio d'une vidéo", "Quitter"} default button 3 with title "The Toolkit")
	
	-- Exécuter le script correspondant au bouton cliqué
	if userChoice is "Extraire l'audio et ajouter un bip" then
		run script appPath & "Contents/Resources/extract.scpt"
	else if userChoice is "Remplacer l'audio d'une vidéo" then
		-- Appeler le script AppleScript pour plaquer l'audio sur la vidéo
		run script appPath & "Contents/Resources/replace.scpt"
	else if userChoice is "Quitter" then
		exit repeat
		
	end if
end repeat
