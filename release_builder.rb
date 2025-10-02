# ============================================================================
# Release Builder für Projekt2025
# ============================================================================
# Verwendung:
#   ruby release_builder.rb 1.0.1
#   ruby release_builder.rb 1.1.0 --patch
# ============================================================================

require 'fileutils'
require 'json'

class ReleaseBuilder
  VERSION_FILE = "version.json"
  
  def initialize(version, is_patch = false)
    @version = version
    @is_patch = is_patch
    @release_name = "Projekt2025_v#{@version}"
    @release_dir = "Release"
    @zip_file = "#{@release_name}.zip"
  end
  
  def build
    puts "=" * 70
    puts "Projekt2025 Release Builder"
    puts "=" * 70
    puts "Version: #{@version}"
    puts "Type: #{@is_patch ? 'PATCH' : 'FULL RELEASE'}"
    puts "=" * 70
    puts
    
    # 1. Update version.json
    update_version_file
    
    # 2. Pack Game Data
    puts "\n[1/5] Packe verschlüsselte Game-Daten..."
    system("ruby game_packager.rb pack")
    
    # 3. Compile Scripts (wenn nicht Patch)
    unless @is_patch
      puts "\n[2/5] Kompiliere Scripts..."
      # Hier könntest du scripts_combine.rb aufrufen wenn nötig
    else
      puts "\n[2/5] Überspringe Script-Kompilierung (Patch-Mode)"
    end
    
    # 4. Create Release Folder
    puts "\n[3/5] Erstelle Release-Ordner..."
    create_release_folder
    
    # 5. Create ZIP
    puts "\n[4/5] Erstelle ZIP-Archiv..."
    create_zip
    
    # 6. Generate Release Notes
    puts "\n[5/5] Erstelle Release Notes..."
    generate_release_notes
    
    puts "\n" + "=" * 70
    puts "✓ Release erfolgreich erstellt!"
    puts "=" * 70
    puts "Dateien:"
    puts "  - #{@zip_file} (#{get_file_size(@zip_file)})"
    puts "  - RELEASE_NOTES_v#{@version}.md"
    puts
    puts "Nächste Schritte:"
    puts "  1. Teste das Release in .\\#{@release_dir}\\"
    puts "  2. Committe version.json zu Git"
    puts "  3. Erstelle Git Tag: git tag v#{@version}"
    puts "  4. Push mit Tags: git push origin main --tags"
    puts "  5. Erstelle GitHub Release und lade ZIP hoch"
    puts "=" * 70
  end
  
  private
  
  def update_version_file
    version_data = {
      version: @version,
      release_date: Time.now.strftime("%Y-%m-%d"),
      build_number: get_next_build_number,
      type: @is_patch ? "patch" : "release"
    }
    
    File.write(VERSION_FILE, JSON.pretty_generate(version_data))
    puts "Version-Datei aktualisiert: #{VERSION_FILE}"
  end
  
  def get_next_build_number
    if File.exist?(VERSION_FILE)
      data = JSON.parse(File.read(VERSION_FILE))
      (data["build_number"] || 0) + 1
    else
      1
    end
  end
  
  def create_release_folder
    # Lösche alten Release-Ordner
    FileUtils.rm_rf(@release_dir) if Dir.exist?(@release_dir)
    FileUtils.mkdir_p(@release_dir)
    
    # Kopiere Basis-Dateien
    [
      "Game.exe",
      "GameData.pack",
      "Game.ini",
      "RGSS104E.dll",
      "x64-msvcrt-ruby310.dll",
      "zlib1.dll",
      "mkxp.json",
      "soundfont.sf2",
      VERSION_FILE
    ].each do |file|
      FileUtils.cp(file, @release_dir) if File.exist?(file)
    end
    
    # Kopiere Ordner
    ["Audio", "Fonts"].each do |dir|
      FileUtils.cp_r(dir, @release_dir) if Dir.exist?(dir)
    end
    
    # Erstelle README
    create_readme
  end
  
  def create_readme
    readme = <<~README
      ========================================
          PROJEKT 2025 - Pokémon Fan Game
      ========================================
      
      VERSION: #{@version}
      RELEASE: #{Time.now.strftime("%d.%m.%Y")}
      
      INSTALLATION:
      -------------
      1. Entpacke alle Dateien
      2. Starte Game.exe
      3. Viel Spaß!
      
      SYSTEMANFORDERUNGEN:
      -------------------
      - Windows 7 oder höher
      - 2 GB RAM
      - 500 MB freier Speicherplatz
      
      UPDATE-ANLEITUNG:
      ----------------
      Für Updates/Patches:
      1. Sichere deinen Spielstand (Game.rxdata)
      2. Ersetze alle Dateien außer Game.rxdata
      3. Starte das Spiel
      
      SUPPORT:
      --------
      GitHub: github.com/99Problemsx/Projekt2025
      Issues: github.com/99Problemsx/Projekt2025/issues
      
      ========================================
         © 2025 - Nur für privaten Gebrauch
      ========================================
    README
    
    File.write("#{@release_dir}/README.txt", readme)
  end
  
  def create_zip
    # Lösche alte ZIP wenn vorhanden
    File.delete(@zip_file) if File.exist?(@zip_file)
    
    # Erstelle ZIP (Windows PowerShell)
    cmd = "powershell -Command \"Compress-Archive -Path '#{@release_dir}\\*' -DestinationPath '#{@zip_file}' -CompressionLevel Optimal\""
    system(cmd)
  end
  
  def generate_release_notes
    notes = <<~NOTES
      # Release Notes v#{@version}
      
      **Release Date:** #{Time.now.strftime("%d.%m.%Y")}
      **Type:** #{@is_patch ? 'Patch' : 'Full Release'}
      
      ## 📦 Downloads
      
      - [Projekt2025_v#{@version}.zip](../../releases/download/v#{@version}/#{@zip_file})
      
      ## ✨ Neue Features
      
      - [ ] Feature 1
      - [ ] Feature 2
      
      ## 🐛 Bug Fixes
      
      - [ ] Fix 1
      - [ ] Fix 2
      
      ## 🔧 Verbesserungen
      
      - [ ] Verbesserung 1
      - [ ] Verbesserung 2
      
      ## 📝 Installation
      
      #{@is_patch ? "### Patch Installation:" : "### Neu-Installation:"}
      
      #{if @is_patch
        "1. Sichere deinen Spielstand (`Game.rxdata`)\n" +
        "2. Entpacke die ZIP-Datei über dein Spielverzeichnis\n" +
        "3. Bestätige das Überschreiben der Dateien\n" +
        "4. Starte das Spiel"
      else
        "1. Entpacke die ZIP-Datei in einen neuen Ordner\n" +
        "2. Starte `Game.exe`\n" +
        "3. Viel Spaß!"
      end}
      
      ## ⚙️ Technische Details
      
      - Build: ##{get_next_build_number}
      - Engine: RPG Maker XP (RGSS1)
      - Essentials: v21.1
      - Kompression: #{get_file_size(@zip_file)}
      
      ## 🔒 Sicherheit
      
      - SHA256: `[Wird nach Upload generiert]`
      
      ---
      
      **Vollständiges Changelog:** [CHANGELOG.md](../../CHANGELOG.md)
    NOTES
    
    File.write("RELEASE_NOTES_v#{@version}.md", notes)
  end
  
  def get_file_size(file)
    return "N/A" unless File.exist?(file)
    size = File.size(file)
    if size > 1024 * 1024
      "#{(size / 1024.0 / 1024.0).round(2)} MB"
    else
      "#{(size / 1024.0).round(2)} KB"
    end
  end
end

# ============================================================================
# Main
# ============================================================================

if ARGV.empty?
  puts "Verwendung: ruby release_builder.rb VERSION [--patch]"
  puts "Beispiel: ruby release_builder.rb 1.0.1"
  puts "Beispiel: ruby release_builder.rb 1.0.2 --patch"
  exit 1
end

version = ARGV[0]
is_patch = ARGV.include?("--patch")

builder = ReleaseBuilder.new(version, is_patch)
builder.build
