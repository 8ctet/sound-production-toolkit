-- Version 1.1
-- Obtenir les chemins des ressources dans le bundle
set monChemin to POSIX path of (path to me)
set appPath to do shell script "dirname " & quoted form of monChemin
set ffmpegPath to appPath & "/ffmpeg"
set ffprobePath to appPath & "/ffprobe"
set soxPath to appPath & "/sox"

-- Vérifie si ffmpeg et ffprobe sont présents
try
	do shell script "if [ ! -f " & quoted form of ffmpegPath & " ] || [ ! -f " & quoted form of ffprobePath & " ] || [ ! -f " & quoted form of soxPath & " ]; then exit 1; fi"
on error
	display dialog "FFmpeg, FFprobe ou sox est introuvable dans l'application." buttons {"OK"} default button "OK"
	return
end try

-- Sélectionner la vidéo source
set videoFile to choose file with prompt "Sélectionnez la vidéo source :"

-- Sélectionner les fichiers audio
set audioFiles to choose file with prompt "Sélectionnez les fichiers audio :" with multiple selections allowed

-- Fonction pour détecter la présence de 1000 Hz pendant 40ms
on startsWith1000Hz(audioPath)
	set monChemin to POSIX path of (path to me)
	set appPath to do shell script "dirname " & quoted form of monChemin
	set ffmpegPath to appPath & "/ffmpeg"
	set ffprobePath to appPath & "/ffprobe"
	set soxPath to appPath & "/sox"
	
	-- Commande pour extraire les 40ms premiers millisecondes de l'audio
	set extractAudioCommand to quoted form of ffmpegPath & " -y -i " & quoted form of audioPath & " -t 0.04 -acodec pcm_s24le -ar 48000 -ac 1 /tmp/temp.wav"
	do shell script extractAudioCommand
	
	-- Commande pour analyser la fréquence de l'audio extrait
	set analyzeFrequencyCommand to quoted form of soxPath & " /tmp/temp.wav -n stat -freq 2>&1 | grep 'Rough'"
	set frequencyOutput to do shell script analyzeFrequencyCommand
	
	-- Supprime le fichier temporaire
	do shell script "rm /tmp/temp.wav"
	
	-- Vérifie la présence de la sinusoïde de 1000Hz
	if frequencyOutput contains "995" then
		return true
		--display dialog "True !" buttons {"OK"} default button "OK"
	else if frequencyOutput contains "996" then
		return true
	else if frequencyOutput contains "996" then
		return true
	else if frequencyOutput contains "997" then
		return true
	else if frequencyOutput contains "998" then
		return true
	else if frequencyOutput contains "999" then
		return true
	else if frequencyOutput contains "1000" then
		return true
	else if frequencyOutput contains "1001" then
		return true
	else if frequencyOutput contains "1002" then
		return true
	else if frequencyOutput contains "1003" then
		return true
	else if frequencyOutput contains "1004" then
		return true
	else if frequencyOutput contains "1005" then
		return true
	else
		return false
		--display dialog "False !" buttons {"OK"} default button "OK"
	end if
end startsWith1000Hz

-- Fonction pour récupérer le bit depth du fichier audio
on getAudioBitDepth(audioPath)
	set monChemin to POSIX path of (path to me)
	set appPath to do shell script "dirname " & quoted form of monChemin
	set ffmpegPath to appPath & "/ffmpeg"
	set ffprobePath to appPath & "/ffprobe"
	set soxPath to appPath & "/sox"
	set bitDepthCommand to quoted form of ffprobePath & " -v error -select_streams a:0 -show_entries stream=sample_fmt -of default=noprint_wrappers=1:nokey=1 " & quoted form of audioPath
	try
		set bitDepthFmt to do shell script bitDepthCommand
		-- Associer les formats FFmpeg à leur bit depth
		if bitDepthFmt is "s16le" then
			return "s16le"
		else if bitDepthFmt is "s24le" then
			return "s24le"
		else if bitDepthFmt is "s32le" then
			return "s32le"
		else if bitDepthFmt is "flt" then
			return "flt"
		else if bitDepthFmt is "dbl" then
			return "dbl"
		else
			return "s24le" -- Valeur par défaut si non détecté
		end if
	on error
		return "s24le" -- Valeur par défaut en cas d'erreur
	end try
end getAudioBitDepth

-- Traiter chaque fichier audio
repeat with audioFile in audioFiles
	set audioPath to POSIX path of audioFile
	
	-- Extraire le nom du fichier audio sans l'extension
	tell application "System Events"
		set audioFileName to name of audioFile
	end tell
	set audioFileNameWithoutExt to do shell script "basename " & quoted form of audioPath & " | sed 's/\\.[^.]*$//'"
	
	-- Récupérer le bit depth du fichier audio original
	set audioBitDepth to getAudioBitDepth(audioPath)
	
	-- Vérifier si l'audio commence par 1000 Hz pendant 40ms
	if startsWith1000Hz(audioPath) then
		-- Couper les deux premières secondes de l'audio
		set trimmedAudioPath to "/tmp/" & audioFileNameWithoutExt & "_trimmed.wav"
		set trimCommand to quoted form of ffmpegPath & " -i " & quoted form of audioPath & " -ss 00:00:02 -c:a pcm_" & audioBitDepth & " " & quoted form of trimmedAudioPath
		do shell script trimCommand
		
		-- Utiliser l'audio coupé
		set finalAudioPath to trimmedAudioPath
	else
		-- Utiliser l'audio original
		set finalAudioPath to audioPath
	end if
	
	-- Construire le chemin de sortie en remplaçant le nom par celui de l'audio
	set videoDirectory to do shell script "dirname " & quoted form of (POSIX path of videoFile)
	set outputVideoPath to videoDirectory & "/" & audioFileNameWithoutExt & ".mov"
	
	-- Remplacer l'audio de la vidéo source en conservant le bit depth
	set replaceCommand to quoted form of ffmpegPath & " -i " & quoted form of (POSIX path of videoFile) & " -i " & quoted form of finalAudioPath & " -c:v copy -c:a pcm_" & audioBitDepth & " -map 0:v:0 -map 1:a:0 -shortest " & quoted form of outputVideoPath
	do shell script replaceCommand
end repeat

-- Avertir l'utilisateur que le processus est terminé
display dialog "Traitement terminé ! Les vidéos avec le nouvel audio sont enregistrées dans le dossier d'origine." buttons {"OK"} default button "OK"
