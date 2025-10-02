# 🚀 Git Release Workflow

## Quick Start - Neues Release erstellen

### 1. Release vorbereiten
```powershell
# 1. Version erhöhen und Release bauen
ruby release_builder.rb 1.0.1

# Oder für Patch:
ruby release_builder.rb 1.0.1 --patch
```

### 2. Release in Git committen
```powershell
# 2. Alle Änderungen stagen
git add .

# 3. Commit mit Version
git commit -m "Release v1.0.1"

# 4. Tag erstellen
git tag -a v1.0.1 -m "Version 1.0.1"

# 5. Zu GitHub pushen
git push origin main
git push origin v1.0.1
```

### 3. GitHub Release erstellen

1. Gehe zu: https://github.com/99Problemsx/Projekt2025/releases/new
2. Wähle den Tag: `v1.0.1`
3. Release-Titel: `v1.0.1 - [Titel]`
4. Kopiere Inhalt aus `RELEASE_NOTES_v1.0.1.md`
5. Lade `Projekt2025_v1.0.1.zip` hoch
6. Klicke "Publish release"

---

## 📋 Detaillierter Workflow

### Entwicklung

```powershell
# Feature Branch erstellen
git checkout -b feature/neue-funktion

# Arbeiten...
git add .
git commit -m "feat: Neue Funktion hinzugefügt"

# Zu main mergen
git checkout main
git merge feature/neue-funktion

# Branch löschen
git branch -d feature/neue-funktion
```

### Bugfix

```powershell
# Hotfix Branch
git checkout -b hotfix/bugfix-name

# Fix implementieren
git add .
git commit -m "fix: Bug behoben"

# Mergen
git checkout main
git merge hotfix/bugfix-name
```

### Release Cycle

```powershell
# 1. CHANGELOG.md aktualisieren
# 2. Release bauen
ruby release_builder.rb 1.1.0

# 3. Committen
git add .
git commit -m "chore: Release v1.1.0"

# 4. Tag erstellen
git tag -a v1.1.0 -m "Release v1.1.0"

# 5. Pushen
git push origin main --tags
```

---

## 🏷️ Git Tag Konventionen

- `v1.0.0` - Vollständiges Release
- `v1.0.1-beta` - Beta Version
- `v1.0.1-rc1` - Release Candidate 1
- `v1.0.1-hotfix` - Hotfix

### Tag erstellen
```powershell
git tag -a v1.0.0 -m "Initial Release"
```

### Tag pushen
```powershell
git push origin v1.0.0
```

### Tag löschen (lokal)
```powershell
git tag -d v1.0.0
```

### Tag löschen (remote)
```powershell
git push origin :refs/tags/v1.0.0
```

---

## 📝 Commit Message Konventionen

Verwende [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - Neues Feature
- `fix:` - Bugfix
- `docs:` - Dokumentation
- `style:` - Formatierung
- `refactor:` - Code-Umstrukturierung
- `test:` - Tests
- `chore:` - Maintenance

### Beispiele:
```
feat: Neues Pokémon hinzugefügt
fix: Kampf-Bug bei Dynamax behoben
docs: README aktualisiert
chore: Release v1.0.1
```

---

## 🔄 Update Workflow

### Kleines Update (Patch)
```powershell
# 1. Build
ruby release_builder.rb 1.0.1 --patch

# 2. Commit & Tag
git add .
git commit -m "chore: Patch v1.0.1"
git tag v1.0.1
git push origin main --tags
```

### Großes Update (Minor/Major)
```powershell
# 1. Build
ruby release_builder.rb 1.1.0

# 2. Commit & Tag
git add .
git commit -m "chore: Release v1.1.0"
git tag v1.1.0
git push origin main --tags
```

---

## 🛠️ Nützliche Git Commands

```powershell
# Status prüfen
git status

# Letzte Commits anzeigen
git log --oneline -10

# Alle Tags anzeigen
git tag -l

# Diff anzeigen
git diff

# Änderungen verwerfen
git restore <datei>

# Letzten Commit rückgängig (behält Änderungen)
git reset --soft HEAD~1

# Branch wechseln
git checkout <branch-name>

# Neuen Branch erstellen und wechseln
git checkout -b <branch-name>
```

---

## 📦 GitHub Releases Best Practices

1. **Immer einen Git Tag** verwenden
2. **Release Notes** aus Datei kopieren
3. **ZIP-Datei** als Asset hochladen
4. **SHA256 Checksumme** in Beschreibung
5. **Pre-release** für Beta-Versionen markieren
6. **Latest release** für stabile Version

### SHA256 erstellen:
```powershell
Get-FileHash Projekt2025_v1.0.0.zip -Algorithm SHA256 | Format-List
```

---

## 🔒 .gitignore Wichtige Dateien

Folgende Dateien NICHT committen:
- `GameData.pack` (zu groß, generiert)
- `Release/` (Build-Output)
- `*.zip` (Distribution-Files)
- `*.log` (Logs)
- `Game.rxdata` (Spielstände)

Wichtig ZU committen:
- `game_packager.rb`
- `game_loader.rb` (oder in Scripts)
- `Data/Scripts/`
- `PBS/`
- Source-Assets (klein genug)
