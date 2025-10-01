# 🗺️ Tiled Converter für Pokémon Essentials

Konvertiert zwischen Pokémon Essentials `.rxdata` Maps und [Tiled](https://www.mapeditor.org/) `.tmx` Format.

## 🚀 Quick Start

### 1. Ranch Map konvertieren
```bash
# Im Projekt-Root ausführen:
ruby TiledConverter/convert_map022.rb
```

### 2. Tiled öffnen
1. Download [Tiled](https://www.mapeditor.org/) (kostenlos)
2. Öffne `TiledMaps/Map022.tmx` in Tiled
3. Bearbeite die Map
4. Speichere als TMX

### 3. Zurück importieren (später)
```ruby
# Im Essentials Debug Menu:
Debug > Editors > Import Map from Tiled
```

## 📁 Dateien

- `tiled_converter.rb` - Haupt-Converter Klasse
- `convert_map022.rb` - Schnell-Converter für Ranch Map
- `README.md` - Diese Anleitung

## 🔄 Features

### Export (Essentials → Tiled)
- ✅ `.rxdata` zu `.tmx` Konvertierung
- ✅ 3 Tile-Layer (Ground, Layer1, Layer2)
- ✅ Events als Objektebene
- ✅ Tileset-Referenzen
- ✅ Batch-Export aller Maps

### Import (Tiled → Essentials)
- ✅ `.tmx` zu `.rxdata` Konvertierung
- ✅ Layer-Daten preservation
- ✅ Objekte zu Events
- ✅ CSV-Format parsing

## 🛠️ Troubleshooting

### "Nicht erkanntes Dateiformat" in Tiled
- **Problem**: Du versuchst `.rxdata` direkt zu öffnen
- **Lösung**: Erst mit Converter zu `.tmx` konvertieren!

### "File not found" Fehler
- **Problem**: Script im falschen Verzeichnis
- **Lösung**: Im Projekt-Root ausführen (`Projekt2025/`)

### "LoadError" beim Ruby Script
- **Problem**: Essentials Klassen nicht verfügbar
- **Lösung**: Im Essentials Debug Menu verwenden

## 📋 Workflow

```
Essentials Map (.rxdata)
         ↓ [Export]
    Tiled Map (.tmx)
         ↓ [Edit in Tiled]
    Modified Map (.tmx)
         ↓ [Import]
    Essentials Map (.rxdata)
```

## 🎯 Supported

- ✅ Tile Layers (3 Ebenen)
- ✅ Events (als Objekte)
- ✅ Map Größe/Eigenschaften
- ✅ Basic Event Properties
- ⚠️  Custom Event Commands (geplant)
- ⚠️  Auto-Tileset Detection (geplant)

## 🔧 Debug Menu Commands

Verfügbar unter `Debug > Editors`:

- **Export Map to Tiled** - Aktuelle Map exportieren
- **Export All Maps to Tiled** - Alle Maps exportieren
- **Import Map from Tiled** - TMX importieren

## 📞 Support

Bei Problemen:
1. Console-Output prüfen
2. Dateipfade kontrollieren
3. Tiled Version prüfen (1.11+ empfohlen)

---

**Made for Pokémon Essentials v21.1** 🎮

