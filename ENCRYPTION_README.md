# Game Encryption System - Anleitung
===============================================================================

## Übersicht

Dieses System verschlüsselt dein RPG Maker XP Spiel mit einer custom 
Multi-Layer-Verschlüsselung, die deutlich schwerer zu knacken ist als die
Standard RPG Maker Verschlüsselung.

## Features

✅ **Multi-Layer Verschlüsselung**
   - XOR mit rotierendem Schlüssel
   - Byte-Shuffling (Fischer-Yates)
   - Doppelte XOR-Schicht
   
✅ **Kompression**
   - Zlib-Kompression für Scripts und Daten
   - Reduziert Dateigröße signifikant
   
✅ **Integritätsprüfung**
   - SHA256 Checksums für jede Datei
   - Erkennt Manipulation
   
✅ **Transparent für RPG Maker**
   - Überschreibt File.read und Marshal.load
   - Keine Änderungen am restlichen Code nötig

## Dateien

- `game_packager.rb` - Tool zum Verschlüsseln und Packen
- `game_loader.rb` - Lädt verschlüsselte Daten zur Laufzeit
- `build_encrypted_game.rb` - Automatisiertes Build-Script

## Schritt-für-Schritt Anleitung

### 1. Konfiguration

Öffne `game_packager.rb` und ändere diese Werte (WICHTIG!):

```ruby
ENCRYPTION_KEY = "MeinGeheimesSpielProjekt2025_XYZ123"  # Ändere dies!
SALT = "CustomSaltValue987654321"                       # Ändere dies!
```

⚠️ **WICHTIG:** Die gleichen Werte müssen in `game_loader.rb` stehen!

Je einzigartiger und länger dein Schlüssel, desto schwerer zu knacken.
Verwende mindestens 32 Zeichen mit Zahlen, Buchstaben und Sonderzeichen.

### 2. Was wird verschlüsselt?

Standard-Konfiguration in `PACK_RULES`:

- ✅ Alle Scripts (Data/Scripts/**/*.rb)
- ✅ Alle RXData Dateien (Data/*.rxdata)
- ✅ PBS Dateien (PBS/**/*.txt)
- ✅ Grafiken (Graphics/**/*.png)
- ⬜ Audio (auskommentiert, wird groß)

Du kannst die Regeln in `game_packager.rb` anpassen.

### 3. Verschlüsselung durchführen

```powershell
# Einfaches Packen
ruby game_packager.rb pack

# Test: Pack + Unpack
ruby game_packager.rb test
```

Dies erstellt `GameData.pack` - deine verschlüsselte Spieldatei.

### 4. Integration ins Spiel

**Manuell:**

Füge ganz oben in dein Haupt-Script ein (vor allem anderen):

```ruby
require_relative 'game_loader'
```

**Automatisch mit Scripts:**

Wenn du `scripts_extract.rb` verwendest, füge in die extrahierten Scripts
am Anfang hinzu (z.B. in `001_Start.rb` oder ähnlich).

### 5. Distribution

Für die finale Spielversion:

**Dateien die BENÖTIGT werden:**
- Game.exe
- game_loader.rb
- GameData.pack
- Alle .dll Dateien (RGSS104E.dll, ruby.dll, etc.)
- Audio Dateien (falls nicht verschlüsselt)

**Dateien die NICHT mitgeliefert werden:**
- game_packager.rb (Development-Tool)
- Originale Data/, PBS/, Scripts/ Ordner
- .rxdata Dateien (sind in GameData.pack)

### 6. Automatisches Build

Nutze das Build-Script:

```powershell
ruby build_encrypted_game.rb
```

Dies erstellt einen `Release/` Ordner mit allen benötigten Dateien.

## Sicherheits-Tipps

### ✅ DO's:

1. **Ändere die Schlüssel** - Verwende einzigartige, lange Keys
2. **Speichere Keys sicher** - Nicht in Git committen!
3. **Teste gründlich** - Nutze `test` Modus
4. **Backup** - Behalte Originaldateien
5. **Versioniere** - Ändere Schlüssel pro Release wenn nötig

### ❌ DON'Ts:

1. Verwende NICHT die Default-Keys
2. Teile NICHT die Keys öffentlich
3. Committe NICHT game_packager.rb in öffentliche Repos
4. Verschlüssele NICHT ohne Backup

## Erweiterte Konfiguration

### Eigene Verschlüsselung hinzufügen

In `game_packager.rb` > `Encryptor.encrypt`:

```ruby
# Füge weitere Layer hinzu
encrypted = your_custom_encryption(encrypted)
```

Vergiss nicht, auch `decrypt` anzupassen!

### Performance-Tuning

Cache-Größe in `game_loader.rb`:

```ruby
# Limitiere Cache (für große Spiele)
@@file_cache = {} if @@file_cache.size > 100
```

### Selective Encryption

Verschlüssele nur kritische Dateien:

```ruby
pbs: {
  source: "PBS",
  pattern: "**/*.txt",
  encrypt: true,      # Verschlüsselt
  compress: true
},
graphics: {
  source: "Graphics",
  pattern: "**/*.png",
  encrypt: false,     # Nicht verschlüsselt
  compress: false
}
```

## Troubleshooting

### "Package nicht gefunden"
- Stelle sicher, dass `GameData.pack` im gleichen Ordner wie `Game.exe` ist
- Führe `ruby game_packager.rb pack` aus

### "Checksum-Fehler"
- Package ist beschädigt oder manipuliert
- Neu packen mit `ruby game_packager.rb pack`

### "Datei nicht gefunden" im Spiel
- Datei wurde nicht gepackt
- Prüfe `PACK_RULES` in `game_packager.rb`
- Führe `ruby game_packager.rb test` aus zum Debuggen

### Scripts laden nicht
- Stelle sicher, dass `game_loader.rb` VOR allen anderen Scripts geladen wird
- Prüfe, ob Keys in beiden Dateien identisch sind

## Wie sicher ist das?

**Gegen normale User:** ✅✅✅ Sehr sicher
- Durchschnittliche Spieler können die Dateien nicht extrahieren

**Gegen erfahrene Hacker:** ⚠️ Mittelmäßig sicher
- Mit genug Zeit und Reverse Engineering möglich
- Deutlich schwerer als RPG Maker Standard

**Gegen Profis:** ❌ Nicht unknackbar
- Keine Verschlüsselung ist 100% sicher
- Ziel ist es, den Aufwand zu erhöhen

### Zusätzliche Maßnahmen:

1. **Code Obfuscation** - Ruby-Code verschleiern
2. **Anti-Debug** - Debug-Erkennung einbauen
3. **Online-Checks** - Validierung über Server
4. **Wasserzeichen** - Unique IDs pro Download

## FAQ

**Q: Kann ich Audio-Dateien verschlüsseln?**
A: Ja, aber das macht das Package sehr groß. Entkommentiere in `PACK_RULES`.

**Q: Funktioniert das mit Plugins?**
A: Ja, sofern Plugins geladen werden, nachdem `game_loader.rb` aktiv ist.

**Q: Kann ich mehrere Packages haben?**
A: Ja, passe `PACKAGE_FILE` an und erstelle mehrere Loader.

**Q: Performance-Impact?**
A: Minimal. Erste Ladung dauert etwas länger, danach wird gecacht.

**Q: Updates verteilen?**
A: Neu packen und komplettes Package ersetzen, oder Delta-Updates implementieren.

## Support

Bei Fragen oder Problemen:
1. Prüfe diese README
2. Teste mit `ruby game_packager.rb test`
3. Prüfe die Konsolen-Ausgabe auf Fehler

## Lizenz

Frei verwendbar für deine Projekte.
Keine Garantie, keine Haftung.

===============================================================================
Viel Erfolg mit deinem Spiel! 🎮
===============================================================================
