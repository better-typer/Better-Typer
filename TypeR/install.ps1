# Encodage pour les accents dans la console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = New-Object System.Text.UTF8Encoding

# --- 1. Definition du dossier du script ---
$ScriptDir = $PSScriptRoot
Set-Location -Path $ScriptDir

# --- 2. Verification du Manifest source ---
$ManifestPath = Join-Path $ScriptDir "CSXS\manifest.xml"
if (-not (Test-Path $ManifestPath)) {
    Write-Host "[ERROR] File not found : $ManifestPath" -ForegroundColor Red
    Write-Host "Please place this script next to 'CSXS', 'app', 'icons', 'locale' folders."
    Read-Host "Press Enter to exit..."
    exit 1
}

# --- 3. Extraction de la version cible ---
$Content = Get-Content $ManifestPath -Raw
if ($Content -match 'Extension Id="typer".*?Version="([^"]+)"') {
    $ExtVersion = $matches[1]
} else {
    $ExtVersion = "2.5.0"
}

# --- 4. Detection d'une installation existante & donnees ---
$AppData = $env:APPDATA
$TargetDir = Join-Path $AppData "Adobe\CEP\extensions\typertools"
$InstalledManifest = Join-Path $TargetDir "CSXS\manifest.xml"
$InstalledStorage = Join-Path $TargetDir "storage"

$IsInstalled = Test-Path $TargetDir
$HasStorage = Test-Path $InstalledStorage
$InstalledVersion = ""

if ($IsInstalled -and (Test-Path $InstalledManifest)) {
    $InstalledContent = Get-Content $InstalledManifest -Raw -ErrorAction SilentlyContinue
    if ($InstalledContent -match 'Extension Id="typer".*?Version="([^"]+)"') {
        $InstalledVersion = $matches[1]
    }
}

# --- 5. Langues et Messages ---
$Lang = $Host.CurrentCulture.TwoLetterISOLanguageName

# Valeurs par defaut (Anglais)
$msg_title          = if ($IsInstalled) { "TypeR - Update" } else { "TypeR - Installation" }
$msg_action         = if ($IsInstalled) {
    if ($InstalledVersion) { "TypeR is already installed (v$InstalledVersion). It will be updated to v$ExtVersion." }
    else { "TypeR is already installed. It will be updated to v$ExtVersion." }
} else {
    "Photoshop extension TypeR v$ExtVersion will be installed."
}
$msg_preserve       = "Your existing data (styles, folders, settings) will be kept intact."
$msg_close          = "Please close Photoshop before continuing."
$msg_running_warn   = "Photoshop is currently running! Please save your work and close Photoshop."
$msg_running_retry  = "Press Enter once Photoshop is closed..."
$msg_complete       = if ($IsInstalled) { "Update completed successfully! All your styles and data have been preserved." } else { "Installation completed successfully." }
$msg_open           = "Open Photoshop and go to: [Window] > [Extensions] > [TypeR]"
$msg_pause          = "Press Enter to continue..."
$msg_credits        = "Many thanks to Swirt for TyperTools and SeanR & Sakushi for this fork."
$msg_discord        = "ScanR's Discord if you need help: https://discord.com/invite/Pdmfmqk"

if ($Lang -eq "fr") {
    $msg_title          = if ($IsInstalled) { "TypeR - Mise à jour" } else { "TypeR - Installation" }
    $msg_action         = if ($IsInstalled) {
        if ($InstalledVersion) { "TypeR est déjà installé (v$InstalledVersion). Il sera mis à jour vers la v$ExtVersion." }
        else { "TypeR est déjà installé. Il sera mis à jour vers la v$ExtVersion." }
    } else {
        "L'extension Photoshop TypeR v$ExtVersion sera installée."
    }
    $msg_preserve       = "Vos données existantes (styles, dossiers, réglages) seront conservées intactes."
    $msg_close          = "Fermez Photoshop avant de continuer."
    $msg_running_warn   = "Photoshop est en cours d'exécution ! Sauvegardez vos travaux et fermez Photoshop."
    $msg_running_retry  = "Appuyez sur Entrée une fois Photoshop fermé..."
    $msg_complete       = if ($IsInstalled) { "Mise à jour terminée avec succès ! Tous vos styles et données sont préservés." } else { "Installation terminée avec succès." }
    $msg_open           = "Ouvrez Photoshop et allez dans : [Fenêtre] > [Extensions] > [TypeR]"
    $msg_pause          = "Appuyez sur Entrée pour continuer..."
    $msg_credits        = "Merci beaucoup à Swirt pour TyperTools et SeanR & Sakushi pour ce fork."
    $msg_discord        = "Discord de ScanR si besoin d'aide : https://discord.com/invite/Pdmfmqk"
}
elseif ($Lang -eq "es") {
    $msg_title          = if ($IsInstalled) { "TypeR - Actualización" } else { "TypeR - Instalación" }
    $msg_action         = if ($IsInstalled) {
        if ($InstalledVersion) { "TypeR ya está instalado (v$InstalledVersion). Se actualizará a v$ExtVersion." }
        else { "TypeR ya está instalado. Se actualizará a v$ExtVersion." }
    } else {
        "La extensión de Photoshop TypeR v$ExtVersion se instalará."
    }
    $msg_preserve       = "Tus datos existentes (estilos, carpetas, ajustes) se mantendrán intactos."
    $msg_close          = "Cierra Photoshop antes de continuar."
    $msg_running_warn   = "¡Photoshop se está ejecutando! Guarda tu trabajo y cierra Photoshop."
    $msg_running_retry  = "Presiona Enter una vez cerrado Photoshop..."
    $msg_complete       = if ($IsInstalled) { "¡Actualización completada con éxito! Todos tus estilos y datos se han conservado." } else { "Instalación completada con éxito." }
    $msg_open           = "Abre Photoshop y ve a: [Ventana] > [Extensiones] > [TypeR]"
    $msg_pause          = "Presiona Enter para continuar..."
    $msg_credits        = "Muchas gracias a Swirt por TyperTools y a SeanR & Sakushi por este fork."
    $msg_discord        = "Discord de ScanR si necesitas ayuda: https://discord.com/invite/Pdmfmqk"
}
elseif ($Lang -eq "pt") {
    $msg_title          = if ($IsInstalled) { "TypeR - Atualização" } else { "TypeR - Instalação" }
    $msg_action         = if ($IsInstalled) {
        if ($InstalledVersion) { "TypeR já está instalado (v$InstalledVersion). Será atualizado para v$ExtVersion." }
        else { "TypeR já está instalado. Será atualizado para v$ExtVersion." }
    } else {
        "A extensão de Photoshop TypeR v$ExtVersion será instalada."
    }
    $msg_preserve       = "Seus dados existentes (estilos, pastas, configurações) serão mantidos intactos."
    $msg_close          = "Feche o Photoshop antes de continuar."
    $msg_running_warn   = "O Photoshop está em execução! Salve seus trabalhos e feche o Photoshop."
    $msg_running_retry  = "Pressione Enter quando o Photoshop estiver fechado..."
    $msg_complete       = if ($IsInstalled) { "Atualização concluída com sucesso! Todos os seus estilos e dados foram preservados." } else { "Instalação concluída com sucesso." }
    $msg_open           = "Abra o Photoshop e vá em: [Janela] > [Extensões] > [TypeR]"
    $msg_pause          = "Pressione Enter para continuar..."
    $msg_credits        = "Muito obrigado a Swirt pelo TyperTools e a SeanR & Sakushi por este fork."
    $msg_discord        = "Discord do ScanR se precisar de ajuda: https://discord.com/invite/Pdmfmqk"
}

Clear-Host
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Cyan
Write-Host ("| {0,-64} |" -f $msg_title) -ForegroundColor Cyan
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Cyan
Write-Host ""
Write-Host "-> $msg_action"
if ($IsInstalled -and $HasStorage) {
    Write-Host "-> $msg_preserve" -ForegroundColor Green
}
Write-Host ""
Write-Host "-> $msg_close" -ForegroundColor Yellow
Write-Host ""

# Verification si Photoshop est ouvert
$psProcesses = Get-Process -Name "Photoshop*" -ErrorAction SilentlyContinue
while ($psProcesses) {
    Write-Host "[!] $msg_running_warn" -ForegroundColor Red
    Read-Host -Prompt "    $msg_running_retry"
    $psProcesses = Get-Process -Name "Photoshop*" -ErrorAction SilentlyContinue
}

Read-Host -Prompt "-> $msg_pause"

# --- 6. Configuration du Mode Debug (CSXS 6 a 16) ---
Write-Host ""
Write-Host "-> Configuring Adobe CEP PlayerDebugMode..." -ForegroundColor Gray
6..16 | ForEach-Object {
    $RegPath = "HKCU:\Software\Adobe\CSXS.$_"
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Set-ItemProperty -Path $RegPath -Name "PlayerDebugMode" -Value 1 -Type String -Force -ErrorAction SilentlyContinue
}

# --- 7. Gestion de la sauvegarde securisee des donnees ---
$BackupRootDir = Join-Path $AppData "Adobe\CEP\extensions\typertools_backups"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFolder = Join-Path $BackupRootDir "backup_$Timestamp"

if ($HasStorage) {
    Write-Host "-> Securing backup of your data (storage)..." -ForegroundColor Cyan
    if (-not (Test-Path $BackupFolder)) {
        New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
    }
    Copy-Item -Path $InstalledStorage -Destination (Join-Path $BackupFolder "storage") -Recurse -Force -ErrorAction SilentlyContinue
    # Sauvegarde locale additionnelle
    Copy-Item -Path $InstalledStorage -Destination (Join-Path $TargetDir "storage.bak") -Recurse -Force -ErrorAction SilentlyContinue
}

# --- 8. Mise a jour ou Installation des fichiers ---
if (-not (Test-Path $TargetDir)) {
    New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
}

# Si on met a jour, on supprime seulement les anciens dossiers de code/ressources
# en laissant 'storage' intact directement a sa place!
$SubItemsToRefresh = @("app", "CSXS", "icons", "locale", "themes", ".debug")
foreach ($item in $SubItemsToRefresh) {
    $ItemPath = Join-Path $TargetDir $item
    if (Test-Path $ItemPath) {
        Remove-Item -Path $ItemPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "-> Copying updated extension files..." -ForegroundColor Gray
$FoldersToCopy = @("app", "CSXS", "icons", "locale")
foreach ($folder in $FoldersToCopy) {
    $Source = Join-Path $ScriptDir $folder
    $Dest = Join-Path $TargetDir $folder
    if (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Dest -Recurse -Force
    }
}

# Cas particulier: themes
if (Test-Path "$ScriptDir\themes") {
    $ThemeDest = "$TargetDir\app\themes"
    if (-not (Test-Path $ThemeDest)) { New-Item $ThemeDest -ItemType Directory -Force | Out-Null }
    Copy-Item "$ScriptDir\themes\*" -Destination $ThemeDest -Recurse -Force
}

# Fichier .debug
if (Test-Path "$ScriptDir\.debug") {
    Copy-Item "$ScriptDir\.debug" -Destination "$TargetDir\.debug" -Force
}

# Verification ultime: si storage etait absent mais existait en backup, on le retablit
if ($HasStorage -and (-not (Test-Path $InstalledStorage))) {
    $SavedStorage = Join-Path $BackupFolder "storage"
    if (Test-Path $SavedStorage) {
        Copy-Item -Path $SavedStorage -Destination $InstalledStorage -Recurse -Force
    }
}

# --- 9. Fin ---
Write-Host ""
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Green
Write-Host ("| {0,-64} |" -f $msg_complete) -ForegroundColor Green
Write-Host "+------------------------------------------------------------------+" -ForegroundColor Green
Write-Host ""
Write-Host "-> $msg_open" -ForegroundColor Cyan
Write-Host ""
Write-Host "+------------------------------------------------------------------+"
Write-Host "| Credits:                                                         |"
Write-Host "+------------------------------------------------------------------+"
Write-Host ("  {0}" -f $msg_credits)
Write-Host ("  {0}" -f $msg_discord)
Write-Host ""
Read-Host -Prompt $msg_pause
