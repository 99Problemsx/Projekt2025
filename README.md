# 🎮 Pokemon Projekt 2025

Ein Pokemon Fangame mit professionellem Auto-Update Launcher und Graphics-Verschlüsselung.

## ✨ Features

- 🔐 **Graphics Encryption System** - Alle Grafiken sind XOR-verschlüsselt (184 MB Graphics.pack)
- 🚀 **Professional Launcher** - XVLauncher mit Auto-Update Funktion
- 🎨 **Custom Pokemon Game** - Basierend auf Pokemon Essentials
- 🔄 **Automatische Updates** - Launcher lädt Updates automatisch von GitHub

## 📥 Installation (für Spieler)

1. Lade `XVLauncher.exe` von den [Releases](https://github.com/99Problemsx/Projekt2025/releases) herunter
2. Starte `XVLauncher.exe`
3. Der Launcher lädt automatisch alle Spieldateien (~300 MB)
4. Klicke auf "SPIELEN"
5. Viel Spaß! 🎉

## 🛠️ Entwickler-Setup

### Voraussetzungen

- Visual Studio 2019+ mit C# und WPF
- Ruby (für Graphics-Pack Erstellung)
- Git

### Repository klonen

```bash
git clone https://github.com/99Problemsx/Projekt2025.git
cd Projekt2025
```

### XVLauncher konfigurieren

1. **GitHub Personal Access Token erstellen:**
   - Gehe zu https://github.com/settings/tokens
   - "Generate new token" → Scope: `public_repo`
   - Token kopieren

2. **Token lokal einfügen:**
   - Öffne `XVLauncher-main/LOCAL_CONFIG.txt`
   - Kopiere Token von dort nach `XVLauncher-main/Properties/Resources.resx`:
     ```xml
     <data name="AccessToken">
       <value>DEIN_TOKEN_HIER</value>
     </data>
     ```
   - **WICHTIG:** Niemals `Resources.resx` mit Token zu GitHub committen!

3. **Visual Studio öffnen:**
   ```bash
   cd XVLauncher-main
   start XVLauncher.sln
   ```

4. **NuGet Packages wiederherstellen:**
   - Tools → NuGet Package Manager → Package Manager Console
   - `Update-Package -reinstall`

5. **Build & Test:**
   - Build → Build Solution (F6)
   - Debug → Start (F5)

## 📦 Neues Release erstellen

### 1. Graphics verschlüsseln

```bash
cd XVLauncher-main/Game
ruby create_graphics_pack.rb
```

### 2. Änderungen committen

```bash
cd ../..
git add XVLauncher-main/Game/
git commit -m "Update v1.0.X - Beschreibung"
git push origin main
```

### 3. GitHub Release erstellen

1. Gehe zu: https://github.com/99Problemsx/Projekt2025/releases/new
2. Tag: `v1.0.X`
3. Title: `Pokemon Projekt 2025 v1.0.X`
4. Beschreibung mit Changelog
5. "Publish release"

### 4. Users bekommen automatisch Updates!

Der XVLauncher erkennt neue Releases automatisch und lädt nur geänderte Dateien herunter.

## 📁 Projekt-Struktur

```
Projekt2025/
└── XVLauncher-main/
    ├── XVLauncher.sln          # Visual Studio Solution
    ├── MainWindow.xaml.cs      # Launcher UI Logic
    ├── UpdateHandler.cs        # GitHub API Integration
    ├── Properties/
    │   ├── Resources.resx      # Config (Token hier lokal einfügen)
    │   └── Settings.settings   # ProjectID: 99Problemsx/Projekt2025
    ├── Resources/              # Launcher Hintergrundbilder
    ├── Game/                   # Pokemon Spiel Dateien
    │   ├── Graphics.pack       # 184 MB verschlüsselt
    │   ├── Game.exe            # Decryptor/Launcher
    │   ├── PokemonGame.exe     # Eigentliches Spiel
    │   ├── Audio/              # Sound-Dateien
    │   ├── Data/               # Scripts, Maps, Pokemon Daten
    │   └── Fonts/              # Schriftarten
    ├── GITHUB_SETUP.md         # Vollständige Setup-Anleitung
    ├── GITHUB_QUICK_REF.txt    # Quick Reference
    ├── SETUP_CHECKLIST.md      # Step-by-Step Checklist
    └── LOCAL_CONFIG.txt        # Dein Token (nicht in Git!)
```

## 🔒 Sicherheit

- **Graphics Encryption:** XOR-Verschlüsselung mit anpassbarem Key
- **Token Management:** Tokens werden NICHT in Git committed
- **Local Config:** `LOCAL_CONFIG.txt` ist in `.gitignore`
- **Runtime Decryption:** Graphics.pack wird zur Laufzeit entschlüsselt

## 🐛 Troubleshooting

### Launcher zeigt "401 Unauthorized"
- Token in `Resources.resx` überprüfen
- Token muss `public_repo` Scope haben

### Launcher findet kein Release
- Mindestens ein Release auf GitHub erstellen
- Tag muss mit `v` beginnen (z.B. `v1.0.0`)

### Graphics nicht sichtbar
- `Game.exe` muss der Decryptor sein (106 KB)
- `Graphics.pack` muss existieren (184 MB)

### NuGet Errors
```powershell
Update-Package -reinstall
```

## 📚 Dokumentation

- [GITHUB_SETUP.md](XVLauncher-main/GITHUB_SETUP.md) - Vollständige Setup-Anleitung
- [SETUP_CHECKLIST.md](XVLauncher-main/SETUP_CHECKLIST.md) - Schritt-für-Schritt Anleitung
- [GITHUB_QUICK_REF.txt](XVLauncher-main/GITHUB_QUICK_REF.txt) - Befehle & Quick Reference

## 🤝 Contributing

Pull Requests sind willkommen! Für größere Änderungen bitte zuerst ein Issue öffnen.

## 📝 License

Dieses Projekt nutzt XVLauncher (MIT License). Pokemon und alle Pokemon-Assets sind Eigentum von Nintendo/Game Freak/The Pokemon Company.

## 🌟 Credits

- **XVLauncher:** [sasso-effe/XVLauncher](https://github.com/sasso-effe/XVLauncher)
- **Pokemon Essentials:** Community
- **Graphics Encryption System:** Custom implementation

---

**Version:** 1.0.0  
**Letztes Update:** Oktober 2025  
**Status:** ✅ In Entwicklung
