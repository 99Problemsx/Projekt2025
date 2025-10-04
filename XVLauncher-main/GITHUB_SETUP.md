# XVLauncher - GitHub Setup Guide

Dein XVLauncher ist jetzt für **GitHub** konfiguriert! 🎉

## ✅ Was wurde geändert?

- UpdateHandler.cs: Nutzt jetzt GitHub Releases API statt GitLab
- Resources.resx: GitHub Personal Access Token
- Settings.settings: GitHub Repository Format (USERNAME/REPONAME)

---

## 📋 Setup-Schritte

### 1. GitHub Personal Access Token erstellen

1. Gehe zu: https://github.com/settings/tokens
2. Klicke **"Generate new token"** → **"Generate new token (classic)"**
3. Einstellungen:
   - **Note:** `XVLauncher Pokemon Projekt 2025`
   - **Expiration:** `No expiration` (oder weit in der Zukunft)
   - **Scopes:** Aktiviere:
     - ✅ `repo` (für private Repos) ODER
     - ✅ `public_repo` (für öffentliche Repos)
4. Klicke **"Generate token"**
5. **WICHTIG:** Kopiere den Token sofort (wird nur einmal angezeigt!)

### 2. XVLauncher konfigurieren

Öffne `Properties/Resources.resx` und füge ein:

```xml
<data name="AccessToken" xml:space="preserve">
  <value>ghp_DEIN_TOKEN_HIER</value>
</data>
```

Öffne `Properties/Settings.settings` und ändere:

```xml
<Setting Name="ProjectID" Type="System.String" Scope="User">
  <Value Profile="(Default)">99Problemsx/Projekt2025</Value>
</Setting>
```

**Format:** `GithubUsername/RepositoryName`

Öffne `Properties/Resources.resx` und ändere UpdateUrl:

```xml
<data name="UpdateUrl" xml:space="preserve">
  <value>https://raw.githubusercontent.com/99Problemsx/Projekt2025/{0}/</value>
</data>
```

---

## 🚀 GitHub Release erstellen

### Vorbereitung: Release-Ordner bauen

```powershell
cd "c:\Users\Marcel Weidenauer\Documents\GitHub\Projekt2025\XVLauncher-main\Game"
ruby create_release.rb
```

Das erstellt einen `Release/` Ordner mit:
- ✅ Graphics.pack (184 MB verschlüsselt)
- ✅ Game.exe (Launcher)
- ✅ PokemonGame.exe
- ✅ Audio/, Data/, Fonts/ Ordner

### GitHub Release erstellen

1. **Dateien committen:**
   ```powershell
   cd "c:\Users\Marcel Weidenauer\Documents\GitHub\Projekt2025"
   git add XVLauncher-main/Game/*
   git commit -m "Release v1.0.0 - Initial Release mit Graphics Encryption"
   git push origin main
   ```

2. **GitHub Release erstellen:**
   - Gehe zu deinem GitHub Repository
   - Klicke **"Releases"** → **"Create a new release"**
   - **Tag version:** `v1.0.0`
   - **Release title:** `Pokemon Projekt 2025 v1.0.0`
   - **Description:**
     ```
     ## 🎮 Pokemon Projekt 2025 - Initial Release
     
     ### Features
     - ✨ Graphics Encryption System (184 MB Graphics.pack)
     - 🚀 Professional Launcher mit Auto-Update
     - 🔐 XOR Verschlüsselung für alle Grafiken
     
     ### Installation
     1. XVLauncher.exe herunterladen und starten
     2. Launcher lädt automatisch alle Dateien herunter
     3. Auf "SPIELEN" klicken
     
     ### Hinweis
     Beim ersten Start wird Graphics.pack entschlüsselt (10-15 Sekunden).
     ```
   - Klicke **"Publish release"**

---

## 🧪 XVLauncher testen

### Visual Studio Build

1. Öffne `XVLauncher.sln` in Visual Studio
2. **NuGet Packages wiederherstellen:**
   - Tools → NuGet Package Manager → Package Manager Console
   - Führe aus: `Update-Package -reinstall`
3. Build → Build Solution (F6)
4. Starte den Launcher: Debug → Start (F5)

### Test mit test_launcher.bat

```powershell
cd "c:\Users\Marcel Weidenauer\Documents\GitHub\Projekt2025\XVLauncher-main"
.\test_launcher.bat
```

### Was sollte passieren:

✅ Launcher startet  
✅ Kontaktiert GitHub API  
✅ Zeigt neueste Release-Version an  
✅ Button "SPIELEN" erscheint  
✅ Klick auf SPIELEN startet Game.exe  
✅ Graphics.pack wird entschlüsselt  
✅ PokemonGame.exe startet mit Grafiken  

---

## 🔄 Update-Workflow

### Neues Update veröffentlichen

1. **Änderungen im Game/ Ordner machen**
2. **Graphics.pack neu erstellen** (wenn Grafiken geändert):
   ```powershell
   cd Game
   ruby create_graphics_pack.rb
   ```
3. **Release bauen:**
   ```powershell
   ruby create_release.rb
   ```
4. **Git Commit & Push:**
   ```powershell
   git add Game/*
   git commit -m "Update v1.0.1 - Beschreibung der Änderungen"
   git push origin main
   ```
5. **GitHub Release erstellen:**
   - Tag: `v1.0.1`
   - Beschreibung mit Changelog

### User Experience:

- User startet XVLauncher
- Launcher erkennt neue Version
- Button zeigt "UPDATE" statt "SPIELEN"
- Klick lädt nur geänderte Dateien herunter
- Auto-Update abgeschlossen ✅

---

## 📁 Dateistruktur für GitHub

```
Projekt2025/ (GitHub Repository)
├── XVLauncher-main/
│   ├── XVLauncher.sln
│   ├── MainWindow.xaml.cs
│   ├── UpdateHandler.cs           ← Für GitHub angepasst
│   ├── Properties/
│   │   ├── Resources.resx         ← AccessToken hier
│   │   └── Settings.settings      ← ProjectID hier
│   ├── Resources/
│   │   ├── background1.png
│   │   └── background2.png
│   └── Game/                      ← Wird per Release verteilt
│       ├── Graphics.pack          ← 184 MB verschlüsselt
│       ├── Game.exe               ← Launcher
│       ├── PokemonGame.exe        ← Eigentliches Spiel
│       ├── Audio/
│       ├── Data/
│       └── Fonts/
└── README.md
```

---

## ⚙️ Konfigurationsübersicht

| Datei | Setting | Wert | Beschreibung |
|-------|---------|------|--------------|
| `Resources.resx` | AccessToken | `ghp_...` | GitHub Personal Access Token |
| `Resources.resx` | UpdateUrl | `https://raw.githubusercontent.com/USER/REPO/{0}/` | Raw content URL |
| `Settings.settings` | ProjectID | `USERNAME/REPONAME` | GitHub Repo Format |
| `Settings.settings` | GameDirectory | `Game` | Ordner mit Spieldateien |
| `Settings.settings` | Version | `1.0.0` | Aktuelle Version |

---

## 🐛 Troubleshooting

### Fehler: "API rate limit exceeded"

**Problem:** GitHub API Limit erreicht (60 Anfragen/Stunde ohne Token)  
**Lösung:** AccessToken korrekt in Resources.resx eintragen

### Fehler: "Could not find release"

**Problem:** Kein GitHub Release vorhanden  
**Lösung:** Mindestens ein Release auf GitHub erstellen

### Fehler: "401 Unauthorized"

**Problem:** AccessToken ungültig oder falsche Permissions  
**Lösung:** Neuen Token mit `repo` oder `public_repo` Scope erstellen

### Fehler: "404 Not Found"

**Problem:** ProjectID falsch (Username/Repo)  
**Lösung:** Settings.settings überprüfen, Format: `USERNAME/REPONAME`

### Launcher zeigt "DOWNLOAD" statt "SPIELEN"

**Problem:** Game/ Ordner nicht gefunden  
**Lösung:** Stelle sicher, dass `GameDirectory = "Game"` in Settings.settings

### Graphics nicht sichtbar im Spiel

**Problem:** Game.exe ist nicht der Launcher  
**Lösung:** Überprüfe, ob Game.exe der GraphicsLoader ist (106 KB, nicht die alte Game.exe)

---

## 🎨 Launcher Branding

### Hintergrundbilder ändern

1. Erstelle Bilder:
   - `Resources/background1.png` (beliebige Größe)
   - `Resources/background2.png`
   - `Resources/splash.png` (400x300)
2. In Visual Studio: Rechtsklick auf Bild → Properties → Build Action → **Content**
3. Launcher zeigt Bilder als Slideshow

### Titel ändern

Öffne `MainWindow.xaml` und ändere:

```xml
<TextBlock Text="Pokemon Projekt 2025" />
```

---

## 🚢 Distribution

### Launcher verteilen:

1. Build in **Release** Mode (nicht Debug)
2. Kopiere aus `bin/Release/`:
   - `XVLauncher.exe`
   - `Resources/` Ordner (mit Hintergrundbildern)
3. Erstelle ZIP: `PokemonProjekt2025-Launcher.zip`
4. Verteile auf deiner Website/Discord/etc.

### User Installation:

1. User lädt `PokemonProjekt2025-Launcher.zip` herunter
2. Entpackt irgendwo (z.B. Desktop)
3. Startet `XVLauncher.exe`
4. Launcher lädt automatisch alle Spieldateien von GitHub
5. Fertig! 🎉

---

## 📊 GitHub vs GitLab Vergleich

| Feature | GitHub | GitLab (Original) |
|---------|--------|-------------------|
| API | ✅ GitHub Releases API | GitLab API v4 |
| Token Format | `ghp_...` | `glpat-...` |
| ProjectID Format | `owner/repo` | Numerische ID |
| Raw Content URL | `raw.githubusercontent.com` | `gitlab.com/.../raw/` |
| Auto-Update | ✅ | ✅ |
| Rate Limit | 5000/h mit Token | 2000/min mit Token |
| Kosten | Free für Public Repos | Free für Public Repos |

**Vorteil GitHub:** Einfacher (kein zweites Repo nötig), USERNAME/REPO statt numerische ID

---

## ✨ Nächste Schritte

1. ✅ GitHub Personal Access Token erstellen
2. ✅ Token in Resources.resx einfügen
3. ✅ ProjectID in Settings.settings auf `USERNAME/REPO` setzen
4. ✅ UpdateUrl in Resources.resx anpassen
5. ✅ Visual Studio: Build testen
6. ✅ Ersten GitHub Release erstellen
7. ✅ XVLauncher testen
8. ✅ Launcher verteilen

**Bereit für dein erstes Release! 🚀**
