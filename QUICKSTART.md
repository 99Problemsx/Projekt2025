# ============================================================================
# SCHNELLSTART - Game Encryption System
# ============================================================================

## 🚀 In 5 Minuten einsatzbereit:

### 1. SCHLÜSSEL ÄNDERN (WICHTIG!)

Öffne `game_packager.rb` UND `game_loader.rb` und ändere:

```ruby
ENCRYPTION_KEY = "DeinSuperGeheimesPasswort123!@#"
SALT = "IrgendeinAndererWert456$%^"
```

⚠️ BEIDE Dateien müssen die GLEICHEN Werte haben!


### 2. VERSCHLÜSSELN

```powershell
ruby game_packager.rb pack
```

Das erstellt `GameData.pack` (~Dateigröße abhängig von deinem Spiel)


### 3. INTEGRATION

Füge in dein erstes Script-File (z.B. `Data/Scripts/001_Start.rb`) ein:

```ruby
require_relative '../../game_loader'
```

ODER wenn du scripts_extract.rb benutzt, füge es in die erste .rb Datei ein.


### 4. TESTEN

```powershell
# Teste lokal
.\Game.exe

# Oder erstelle Release-Build
ruby build_encrypted_game.rb build
```


### 5. VERTEILEN

Kopiere aus dem `Release/` Ordner:
- Game.exe
- game_loader.rb  
- GameData.pack
- Alle .dll Dateien
- Audio/ und Fonts/ Ordner


## ✅ Checkliste vor Release:

- [ ] Eigene ENCRYPTION_KEY gesetzt
- [ ] Eigenen SALT gesetzt
- [ ] Spiel getestet (läuft mit GameData.pack?)
- [ ] Keine game_packager.rb im Release-Ordner
- [ ] README.txt für Spieler erstellt
- [ ] Backup der Originaldateien gemacht


## 🔧 Häufige Befehle:

```powershell
# Verschlüsseln
ruby game_packager.rb pack

# Test (Pack + Unpack)
ruby game_packager.rb test

# Kompletter Build
ruby build_encrypted_game.rb build

# Aufräumen
ruby build_encrypted_game.rb clean

# Alles neu
ruby build_encrypted_game.rb rebuild
```


## ⚠️ WICHTIG:

1. **Schlüssel geheim halten!** Nicht auf GitHub hochladen!
2. **Backup machen!** Behalte immer die Originaldateien
3. **Testen!** Vor Release immer testen ob alles funktioniert


## 💡 Tipps:

**Große Spiele:** Audio-Verschlüsselung deaktivieren (wird riesig)
**Kleine Spiele:** Alles verschlüsseln für maximalen Schutz
**Updates:** Neu packen und GameData.pack ersetzen


## 🆘 Probleme?

Siehe `ENCRYPTION_README.md` für detaillierte Hilfe!
