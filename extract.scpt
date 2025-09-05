-- Version 1.4
-- Obtenir les chemins des ressources dans le bundle
set monChemin to POSIX path of (path to me)
set appPath to do shell script "dirname " & quoted form of monChemin
set ffmpegPath to appPath & "/ffmpeg"
set bipPath to appPath & "/BIP.wav"

-- Vérifie si les fichiers nécessaires existent
try
	do shell script "if [ ! -f " & quoted form of ffmpegPath & " ] || [ ! -f " & quoted form of bipPath & " ]; then exit 1; fi"
on error
	display dialog "FFmpeg ou BIP.wav est introuvable dans l'application." buttons {"OK"} default button "OK"
	return
end try

-- Demande à l'utilisateur de sélectionner plusieurs fichiers vidéo
set videoFiles to choose file with prompt "Choisissez les vidéos pour extraire l'audio :" with multiple selections allowed

-- Traite chaque fichier vidéo
repeat with videoFile in videoFiles
	try
		-- Obtenir le chemin POSIX de la vidéo
		set videoPath to POSIX path of videoFile
		
		-- Utiliser System Events pour obtenir le nom du fichier
		set videoAlias to videoFile as alias
		tell application "System Events"
			set videoFileName to name of videoAlias
		end tell
		
		-- Obtenir le dossier de la vidéo
		set videoFolderPath to do shell script "dirname " & quoted form of videoPath
		set videoBaseName to text 1 thru ((offset of "." in videoFileName) - 1) of videoFileName
		
		-- Définir le chemin pour le fichier audio extrait
		set outputAudio to videoFolderPath & "/" & videoBaseName & "_extrait.wav"
		
		-- Définir le chemin pour le fichier final
		set finalAudio to videoFolderPath & "/" & videoBaseName & ".wav"
		
		-- Commande pour extraire l'audio de la vidéo au format WAV
		set extractCommand to quoted form of ffmpegPath & " -i " & quoted form of videoPath & " -q:a 0 -map a -y -c:a copy " & quoted form of outputAudio
		
		-- Commande pour combiner l'audio extrait avec le fichier BIP.wav
		set combineCommand to quoted form of ffmpegPath & " -i " & quoted form of outputAudio & " -i " & quoted form of bipPath & " -filter_complex \"[1:0][0:0]concat=n=2:v=0:a=1[out]\" -map \"[out]\" -y -c:a pcm_s24le " & quoted form of finalAudio
		
		-- Exécute les commandes dans le terminal
		do shell script extractCommand
		do shell script combineCommand
		
		-- Supprime le fichier intermédiaire "_extrait.wav"
		do shell script "rm -f " & quoted form of outputAudio
	on error errMsg
		display dialog "Une erreur est survenue lors du traitement de la vidéo " & videoFileName & ": " & errMsg buttons {"OK"} default button "OK"
	end try
end repeat

-- Avertit l'utilisateur que le processus est terminé
display dialog "Traitement terminé ! Les fichiers audio combinés sont enregistrés dans les dossiers d'origine." buttons {"OK"} default button "OK"
