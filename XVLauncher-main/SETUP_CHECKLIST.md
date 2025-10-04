# ✅ XVLauncher Setup Checklist - GitHub Edition

## Konfiguration (ABGESCHLOSSEN ✅)

- [x] GitHub Personal Access Token erstellt
- [x] Token in `Properties/Resources.resx` eingefügt
- [x] Repository-Name in `Properties/Settings.settings` gesetzt
- [x] UpdateUrl in `Properties/Resources.resx` konfiguriert

### Deine Konfiguration:
```
Repository:  99Problemsx/Projekt2025
Token:       github_pat_11A7TOYEA0LXvhULEZlglu_...
UpdateUrl:   https://raw.githubusercontent.com/99Problemsx/Projekt2025/{0}/
```

---

## Vor dem ersten Release

### 1. Release-Dateien vorbereiten

```powershell
cd "c:\Users\Marcel Weidenauer\Documents\GitHub\Projekt2025\XVLauncher-main\Game"

# Graphics verschlüsseln (falls noch nicht gemacht)
ruby create_graphics_pack.rb

# Release-Ordner erstellen
ruby create_release.rb
```

**Erwartete Dateien im Release/ Ordner:**
- [ ] Graphics.pack (184 MB)
- [ ] Game.exe (Launcher, 106 KB)
- [ ] PokemonGame.exe (Spiel)
- [ ] Audio/ Ordner
- [ ] Data/ Ordner
- [ ] Fonts/ Ordner

### 2. Dateien zu GitHub committen

```powershell
cd "c:\Users\Marcel Weidenauer\Documents\GitHub\Projekt2025"

# XVLauncher-Dateien hinzufügen
git add XVLauncher-main/

# WICHTIG: Game-Dateien hinzufügen
git add XVLauncher-main/Game/Graphics.pack
git add XVLauncher-main/Game/Game.exe
git add XVLauncher-main/Game/PokemonGame.exe
git add XVLauncher-main/Game/Audio/
git add XVLauncher-main/Game/Data/
git add XVLauncher-main/Game/Fonts/

# Committen
git commit -m "Release v1.0.0 - Initial Release mit Graphics Encryption"

# Pushen
git push origin main
```

### 3. GitHub Release erstellen

**Option A: GitHub Website**
1. Gehe zu: https://github.com/99Problemsx/Projekt2025/releases/new
2. Fülle aus:
   - **Tag version:** `v1.0.0`
   - **Target:** `main` (oder dein Standard-Branch)
   - **Release title:** `Pokemon Projekt 2025 v1.0.0`
   - **Description:**
     ```markdown
     ## 🎮 Pokemon Projekt 2025 - Initial Release
     
     ### ✨ Features
     - Graphics Encryption System (184 MB Graphics.pack)
     - Professional Launcher mit Auto-Update
     - XOR Verschlüsselung für alle Grafiken
     
     ### 📥 Installation
     1. XVLauncher.exe herunterladen
     2. Launcher starten
     3. Launcher lädt automatisch alle Spieldateien
     4. Auf "SPIELEN" klicken
     
     ### ⚠️ Hinweis
     Beim ersten Start wird Graphics.pack entschlüsselt (10-15 Sekunden).
     ```
3. Klicke **"Publish release"**

**Option B: Git Command Line**
```powershell
git tag -a v1.0.0 -m "Pokemon Projekt 2025 v1.0.0"
git push origin v1.0.0
# Dann auf GitHub Website Release hinzufügen
```

### 4. Überprüfung

Nach dem Release erstellen, überprüfe:
- [ ] Release ist auf https://github.com/99Problemsx/Projekt2025/releases sichtbar
- [ ] Tag `v1.0.0` existiert
- [ ] Alle Dateien sind im Repository

---

## Launcher bauen und testen

### 1. Visual Studio öffnen

```powershell
cd "c:\Users\Marcel Weidenauer\Documents\GitHub\Projekt2025\XVLauncher-main"
start XVLauncher.sln
```

### 2. NuGet Packages wiederherstellen

In Visual Studio:
1. **Tools** → **NuGet Package Manager** → **Package Manager Console**
2. Führe aus:
   ```powershell
   Update-Package -reinstall
   ```
3. Warte bis alle Packages installiert sind

### 3. Build

1. **Build** → **Build Solution** (oder F6)
2. Warte auf erfolgreichen Build
3. Überprüfe Output: `bin/Debug/XVLauncher.exe` existiert

### 4. Ersten Test

1. **Debug** → **Start Debugging** (F5)
2. Launcher startet

**Erwartetes Verhalten:**
- [ ] Launcher-Fenster öffnet sich
- [ ] Kontaktiert GitHub API (ggf. Loading-Animation)
- [ ] Zeigt Release-Info an
- [ ] Button zeigt "DOWNLOAD" (erste Installation)

**Bei Problemen:**
- Überprüfe Output/Errors in Visual Studio
- Siehe Troubleshooting unten

---

## Troubleshooting

### ❌ Fehler: "401 Unauthorized"

**Problem:** GitHub lehnt Token ab

**Lösung:**
1. Überprüfe Token in `Properties/Resources.resx`
2. Stelle sicher, Token hat `repo` oder `public_repo` Scope
3. Token könnte abgelaufen sein - erstelle neuen

### ❌ Fehler: "404 Not Found"

**Problem:** Repository nicht gefunden

**Lösung:**
1. Überprüfe `ProjectID` in `Properties/Settings.settings`
2. Muss exakt sein: `99Problemsx/Projekt2025`
3. Groß-/Kleinschreibung beachten!

### ❌ Fehler: "Could not find release"

**Problem:** Kein GitHub Release vorhanden

**Lösung:**
1. Gehe zu https://github.com/99Problemsx/Projekt2025/releases
2. Erstelle mindestens einen Release (siehe oben)
3. Launcher braucht mindestens 1 Release zum Starten

### ❌ Launcher zeigt nichts an

**Problem:** NuGet Packages fehlen

**Lösung:**
```powershell
# In Package Manager Console
Update-Package -reinstall
```

### ❌ Build Errors

**Problem:** Fehlende Dependencies

**Lösung:**
1. Visual Studio 2019+ installiert?
2. .NET Framework 4.7.2+ installiert?
3. NuGet Packages wiederhergestellt?

---

## Release-Distribution

### Launcher für User verteilen

1. **Release Build erstellen:**
   - Configuration Manager → **Release** (statt Debug)
   - Build → Build Solution
   - Finde: `bin/Release/XVLauncher.exe`

2. **Dateien zusammenstellen:**
   ```
   PokemonProjekt2025-Launcher/
   ├── XVLauncher.exe
   └── Resources/
       ├── background1.png
       ├── background2.png
       └── splash.png
   ```

3. **ZIP erstellen:**
   ```powershell
   Compress-Archive -Path "PokemonProjekt2025-Launcher" -DestinationPath "PokemonProjekt2025-Launcher-v1.0.0.zip"
   ```

4. **Verteilen:**
   - Upload auf Discord/Website/etc.
   - User lädt ZIP herunter
   - User entpackt
   - User startet `XVLauncher.exe`
   - Launcher lädt automatisch alle Spieldateien von GitHub

---

## Update-Workflow (für zukünftige Releases)

### Neues Update veröffentlichen:

```powershell
# 1. Änderungen machen
cd "c:\Users\Marcel Weidenauer\Documents\GitHub\Projekt2025\XVLauncher-main\Game"

# 2. Graphics neu verschlüsseln (wenn geändert)
ruby create_graphics_pack.rb

# 3. Release bauen
ruby create_release.rb

# 4. Committen
cd ../..
git add XVLauncher-main/Game/*
git commit -m "Update v1.0.1 - Neue Features/Bugfixes"
git push origin main

# 5. GitHub Release erstellen
# Gehe zu: https://github.com/99Problemsx/Projekt2025/releases/new
# Tag: v1.0.1
# Publish
```

### User Experience:
- User startet XVLauncher
- Launcher erkennt neue Version v1.0.1
- Button ändert sich zu "UPDATE"
- Klick lädt nur geänderte Dateien
- Auto-Update fertig! ✅

---

## Wichtige Links

- **GitHub Repository:** https://github.com/99Problemsx/Projekt2025
- **Releases:** https://github.com/99Problemsx/Projekt2025/releases
- **Token Management:** https://github.com/settings/tokens
- **GitHub API Docs:** https://docs.github.com/en/rest/releases

---

## Cheat Sheet

```powershell
# Graphics verschlüsseln
cd XVLauncher-main/Game
ruby create_graphics_pack.rb

# Release bauen
ruby create_release.rb

# Committen & Pushen
cd ../..
git add XVLauncher-main/Game/*
git commit -m "Release v1.0.X"
git push origin main

# Launcher bauen
cd XVLauncher-main
# In Visual Studio: F6 (Build)

# Launcher testen
# In Visual Studio: F5 (Debug)
```

---

## Status

- [x] GitHub Token erstellt
- [x] XVLauncher konfiguriert
- [ ] GitHub Release erstellt
- [ ] Visual Studio Build getestet
- [ ] Erster Launcher-Test erfolgreich
- [ ] Launcher verteilt

**Nächster Schritt:** GitHub Release erstellen! 🚀
