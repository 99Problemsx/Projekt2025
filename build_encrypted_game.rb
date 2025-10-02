# ============================================================================
# Automatisches Build-Script für verschlüsseltes Spiel
# ============================================================================
# Erstellt einen Release-Ordner mit allen benötigten Dateien
# ============================================================================

require 'fileutils'

module GameBuilder
  RELEASE_DIR = "Release"
  GAME_NAME = "Projekt2025"
  
  # Dateien die kopiert werden müssen
  REQUIRED_FILES = [
    "Game.exe",
    "Game.ini",
    "RGSS104E.dll",
    "x64-msvcrt-ruby310.dll",
    "zlib1.dll",
    "game_loader.rb",
    "mkxp.json"
  ]
  
  # Optional: Soundfont wenn vorhanden
  OPTIONAL_FILES = [
    "soundfont.sf2"
  ]
  
  # Ordner die komplett kopiert werden (falls nicht verschlüsselt)
  COPY_FOLDERS = [
    "Audio",  # Falls Audio nicht verschlüsselt wurde
    "Fonts"
  ]
  
  # Optional: Spezielle Dateien
  COPY_OPTIONAL_FOLDERS = [
    # "Graphics",  # Nur wenn nicht verschlüsselt
  ]
  
  def self.build
    puts "=" * 70
    puts "Game Builder für #{GAME_NAME}"
    puts "=" * 70
    puts
    
    # Schritt 1: Verschlüssele das Spiel
    puts "[1/4] Verschlüssele Spieldaten..."
    unless system('ruby game_packager.rb pack')
      puts "FEHLER: Verschlüsselung fehlgeschlagen!"
      return false
    end
    puts
    
    # Schritt 2: Erstelle Release-Ordner
    puts "[2/4] Erstelle Release-Ordner..."
    if Dir.exist?(RELEASE_DIR)
      puts "Lösche alten Release-Ordner..."
      FileUtils.rm_rf(RELEASE_DIR)
    end
    FileUtils.mkdir_p(RELEASE_DIR)
    puts "✓ Release-Ordner erstellt"
    puts
    
    # Schritt 3: Kopiere Dateien
    puts "[3/4] Kopiere Dateien..."
    
    # Benötigte Dateien
    REQUIRED_FILES.each do |file|
      if File.exist?(file)
        FileUtils.cp(file, RELEASE_DIR)
        puts "  ✓ #{file}"
      else
        puts "  ⚠ #{file} nicht gefunden!"
      end
    end
    
    # Optionale Dateien
    OPTIONAL_FILES.each do |file|
      if File.exist?(file)
        FileUtils.cp(file, RELEASE_DIR)
        puts "  ✓ #{file}"
      end
    end
    
    # GameData.pack
    if File.exist?("GameData.pack")
      FileUtils.cp("GameData.pack", RELEASE_DIR)
      puts "  ✓ GameData.pack (#{File.size('GameData.pack') / (1024.0 * 1024).round(2)} MB)"
    else
      puts "  ✗ GameData.pack nicht gefunden!"
      return false
    end
    
    puts
    
    # Ordner kopieren
    puts "[4/4] Kopiere Ordner..."
    COPY_FOLDERS.each do |folder|
      if Dir.exist?(folder)
        dest = File.join(RELEASE_DIR, folder)
        FileUtils.cp_r(folder, dest)
        file_count = Dir.glob("#{dest}/**/*").select { |f| File.file?(f) }.count
        puts "  ✓ #{folder}/ (#{file_count} Dateien)"
      else
        puts "  ⚠ #{folder}/ nicht gefunden"
      end
    end
    
    COPY_OPTIONAL_FOLDERS.each do |folder|
      if Dir.exist?(folder)
        dest = File.join(RELEASE_DIR, folder)
        FileUtils.cp_r(folder, dest)
        file_count = Dir.glob("#{dest}/**/*").select { |f| File.file?(f) }.count
        puts "  ✓ #{folder}/ (#{file_count} Dateien)"
      end
    end
    
    puts
    
    # Erstelle README
    create_readme
    
    # Statistiken
    puts "=" * 70
    puts "Build erfolgreich abgeschlossen!"
    puts "=" * 70
    
    total_size = calculate_folder_size(RELEASE_DIR)
    file_count = Dir.glob("#{RELEASE_DIR}/**/*").select { |f| File.file?(f) }.count
    
    puts
    puts "Statistiken:"
    puts "  Ordner: #{RELEASE_DIR}/"
    puts "  Dateien: #{file_count}"
    puts "  Größe: #{format_bytes(total_size)}"
    puts
    puts "Nächste Schritte:"
    puts "  1. Teste das Spiel: #{RELEASE_DIR}/Game.exe"
    puts "  2. Erstelle ZIP für Distribution"
    puts "  3. Optional: Erstelle Installer mit NSIS/Inno Setup"
    puts
    puts "=" * 70
    
    true
  end
  
  def self.create_readme
    readme_path = File.join(RELEASE_DIR, "README.txt")
    
    content = <<~README
      ========================================================================
      #{GAME_NAME}
      ========================================================================
      
      Danke fürs Spielen!
      
      INSTALLATION:
      -------------
      Einfach Game.exe starten. Keine Installation notwendig.
      
      SYSTEMANFORDERUNGEN:
      --------------------
      - Windows 7 oder höher
      - 512 MB RAM
      - DirectX 9.0c
      
      STEUERUNG:
      ----------
      Pfeiltasten - Bewegung
      Enter/Space - Bestätigen
      ESC/X       - Abbrechen
      F12         - Titel-Bildschirm
      Alt+Enter   - Vollbild
      
      PROBLEME?:
      ----------
      Falls das Spiel nicht startet:
      - Stelle sicher, dass alle .dll Dateien vorhanden sind
      - Installiere Microsoft Visual C++ Redistributable
      - Deaktiviere Antivirus temporär (Fehlalarm möglich)
      
      COPYRIGHT:
      ----------
      © #{Time.now.year}
      Alle Rechte vorbehalten.
      
      ========================================================================
    README
    
    File.write(readme_path, content)
    puts "  ✓ README.txt erstellt"
  end
  
  def self.calculate_folder_size(folder)
    Dir.glob("#{folder}/**/*").select { |f| File.file?(f) }.sum { |f| File.size(f) }
  end
  
  def self.format_bytes(bytes)
    if bytes < 1024
      "#{bytes} B"
    elsif bytes < 1024 * 1024
      "#{(bytes / 1024.0).round(2)} KB"
    else
      "#{(bytes / (1024.0 * 1024)).round(2)} MB"
    end
  end
  
  # Clean-up Funktion
  def self.clean
    puts "Lösche Build-Artefakte..."
    
    FileUtils.rm_f("GameData.pack")
    puts "  ✓ GameData.pack gelöscht"
    
    if Dir.exist?("unpacked")
      FileUtils.rm_rf("unpacked")
      puts "  ✓ unpacked/ gelöscht"
    end
    
    if Dir.exist?(RELEASE_DIR)
      FileUtils.rm_rf(RELEASE_DIR)
      puts "  ✓ #{RELEASE_DIR}/ gelöscht"
    end
    
    puts "Fertig!"
  end
end

# ============================================================================
# Main Execution
# ============================================================================
if __FILE__ == $0
  command = ARGV[0] || 'build'
  
  case command
  when 'build'
    GameBuilder.build
  when 'clean'
    GameBuilder.clean
  when 'rebuild'
    GameBuilder.clean
    puts
    GameBuilder.build
  else
    puts "Game Builder"
    puts
    puts "Verwendung:"
    puts "  ruby build_encrypted_game.rb build    - Baut das verschlüsselte Spiel"
    puts "  ruby build_encrypted_game.rb clean    - Löscht Build-Artefakte"
    puts "  ruby build_encrypted_game.rb rebuild  - Clean + Build"
  end
end
