# ============================================================================
# Custom Game Packager - Verschlüsselung für RPG Maker XP
# ============================================================================
# Dieses Tool verschlüsselt alle wichtigen Game-Assets in ein sicheres Format
# Verwendung: ruby game_packager.rb pack
#             ruby game_packager.rb unpack (nur für Testing)
# ============================================================================

require 'zlib'
require 'fileutils'
require 'digest'

module GamePackager
  VERSION = "1.0.0"
  
  # ============================================================================
  # WICHTIG: Ändere diese Werte für dein Spiel!
  # Je einzigartiger, desto schwerer zu knacken
  # ============================================================================
  ENCRYPTION_KEY = "MeinGeheimesSpielProjekt2025_XYZ123"  # Ändere dies!
  SALT = "CustomSaltValue987654321"                       # Ändere dies!
  MAGIC_HEADER = "GMPK"  # Game Package Marker
  
  # Verzeichnisse und Dateien die gepackt werden sollen
  PACK_RULES = {
    # Scripts
    scripts: {
      source: "Data/Scripts",
      pattern: "**/*.rb",
      encrypt: true,
      compress: true
    },
    # RXData Files
    rxdata: {
      source: "Data",
      pattern: "*.rxdata",
      encrypt: true,
      compress: true
    },
    # PBS Data
    pbs: {
      source: "PBS",
      pattern: "**/*.txt",
      encrypt: true,
      compress: true
    },
    # Graphics
    graphics: {
      source: "Graphics",
      pattern: "**/*.png",
      encrypt: true,
      compress: false  # PNG sind schon komprimiert
    },
    # Audio (optional - kann groß werden)
    # audio: {
    #   source: "Audio",
    #   pattern: "**/*.{ogg,mp3,wav}",
    #   encrypt: true,
    #   compress: false
    # }
  }
  
  OUTPUT_FILE = "GameData.pack"
  
  # ============================================================================
  # Verschlüsselungs-Engine
  # ============================================================================
  class Encryptor
    def self.generate_key(base_key, salt, length = 256)
      # Erstelle einen stabilen Schlüssel aus Base + Salt
      Digest::SHA256.digest(base_key + salt).bytes.cycle.first(length)
    end
    
    def self.encrypt(data, key_base)
      return data if data.nil? || data.empty?
      
      # Multi-Layer Verschlüsselung
      key = generate_key(key_base, SALT)
      
      # Layer 1: XOR mit rotierendem Schlüssel (optimiert)
      bytes = data.bytes
      key_len = key.length
      encrypted_bytes = []
      bytes.each_with_index do |byte, i|
        encrypted_bytes << ((byte ^ key[i % key_len] ^ (i % 256)) & 0xFF)
      end
      encrypted = encrypted_bytes.pack('C*')
      
      # Layer 2: Byte-Shuffling basierend auf Schlüssel (nur für kleinere Dateien)
      encrypted = shuffle_bytes(encrypted, key) if data.length < 1_000_000
      
      # Layer 3: XOR nochmal mit umgekehrtem Schlüssel (optimiert)
      key_reversed = key.reverse
      bytes = encrypted.bytes
      encrypted_bytes = []
      bytes.each_with_index do |byte, i|
        encrypted_bytes << ((byte ^ key_reversed[i % key_len]) & 0xFF)
      end
      encrypted_bytes.pack('C*')
    end
    
    def self.decrypt(data, key_base)
      return data if data.nil? || data.empty?
      
      key = generate_key(key_base, SALT)
      key_len = key.length
      original_size = data.length
      
      # Layer 3 rückwärts: XOR mit umgekehrtem Schlüssel (optimiert)
      key_reversed = key.reverse
      bytes = data.bytes
      decrypted_bytes = []
      bytes.each_with_index do |byte, i|
        decrypted_bytes << ((byte ^ key_reversed[i % key_len]) & 0xFF)
      end
      decrypted = decrypted_bytes.pack('C*')
      
      # Layer 2 rückwärts: Byte-Unshuffling (nur wenn shuffled)
      decrypted = unshuffle_bytes(decrypted, key) if original_size < 1_000_000
      
      # Layer 1 rückwärts: XOR mit rotierendem Schlüssel (optimiert)
      bytes = decrypted.bytes
      decrypted_bytes = []
      bytes.each_with_index do |byte, i|
        decrypted_bytes << ((byte ^ key[i % key_len] ^ (i % 256)) & 0xFF)
      end
      decrypted_bytes.pack('C*')
    end
    
    def self.shuffle_bytes(data, key)
      bytes = data.bytes
      length = bytes.length
      return data if length <= 1
      
      # Fischer-Yates Shuffle mit deterministischem Seed
      rng_state = key.sum
      (length - 1).downto(1) do |i|
        # Pseudo-random basierend auf Schlüssel
        rng_state = (rng_state * 1103515245 + 12345) & 0x7FFFFFFF
        j = rng_state % (i + 1)
        bytes[i], bytes[j] = bytes[j], bytes[i]
      end
      
      bytes.pack('C*')
    end
    
    def self.unshuffle_bytes(data, key)
      bytes = data.bytes
      length = bytes.length
      return data if length <= 1
      
      # Generiere die gleiche Shuffle-Sequenz
      rng_state = key.sum
      swaps = []
      (length - 1).downto(1) do |i|
        rng_state = (rng_state * 1103515245 + 12345) & 0x7FFFFFFF
        j = rng_state % (i + 1)
        swaps << [i, j]
      end
      
      # Führe Swaps in umgekehrter Reihenfolge aus
      swaps.reverse.each do |i, j|
        bytes[i], bytes[j] = bytes[j], bytes[i]
      end
      
      bytes.pack('C*')
    end
    
    def self.create_checksum(data)
      Digest::SHA256.hexdigest(data)
    end
    
    def self.verify_checksum(data, checksum)
      create_checksum(data) == checksum
    end
  end
  
  # ============================================================================
  # Packager - Erstellt das verschlüsselte Archiv
  # ============================================================================
  class Packer
    def self.pack
      puts "=" * 70
      puts "Game Packager v#{VERSION}"
      puts "=" * 70
      puts
      
      # Sammle alle Dateien
      files_to_pack = collect_files
      
      if files_to_pack.empty?
        puts "FEHLER: Keine Dateien zum Packen gefunden!"
        return false
      end
      
      puts "Gefundene Dateien: #{files_to_pack.length}"
      puts
      
      # Erstelle das Package
      package_data = create_package(files_to_pack)
      
      # Schreibe Package-Datei
      File.open(OUTPUT_FILE, 'wb') do |f|
        f.write(package_data)
      end
      
      original_size = files_to_pack.sum { |f| File.size(f[:full_path]) }
      packed_size = File.size(OUTPUT_FILE)
      ratio = ((1 - packed_size.to_f / original_size) * 100).round(2)
      
      puts
      puts "=" * 70
      puts "Packvorgang abgeschlossen!"
      puts "=" * 70
      puts "Output: #{OUTPUT_FILE}"
      puts "Originalgröße: #{format_bytes(original_size)}"
      puts "Gepackte Größe: #{format_bytes(packed_size)}"
      puts "Kompression: #{ratio}%"
      puts
      puts "WICHTIG: Speichere die ENCRYPTION_KEY und SALT sicher!"
      puts "=" * 70
      
      true
    end
    
    def self.collect_files
      files = []
      
      PACK_RULES.each do |category, rules|
        source = rules[:source]
        pattern = rules[:pattern]
        
        unless Dir.exist?(source)
          puts "WARNUNG: Verzeichnis '#{source}' nicht gefunden, überspringe..."
          next
        end
        
        Dir.glob(File.join(source, pattern)).each do |file_path|
          next if File.directory?(file_path)
          
          files << {
            category: category,
            relative_path: file_path.gsub(/^#{Regexp.escape(source)}[\/\\]?/, ''),
            full_path: file_path,
            encrypt: rules[:encrypt],
            compress: rules[:compress]
          }
        end
      end
      
      files
    end
    
    def self.create_package(files)
      package = StringIO.new
      package.set_encoding('BINARY')
      
      # Header
      package.write(MAGIC_HEADER)
      package.write(VERSION.split('.').map(&:to_i).pack('C3'))
      package.write([files.length].pack('N'))
      
      # File Table of Contents
      toc_data = StringIO.new
      toc_data.set_encoding('BINARY')
      
      file_data_parts = []
      
      files.each_with_index do |file_info, index|
        print "\rVerarbeite: #{index + 1}/#{files.length} - #{file_info[:relative_path]}"
        
        # Lese Datei
        data = File.binread(file_info[:full_path])
        
        # Komprimiere wenn gewünscht
        if file_info[:compress]
          data = Zlib::Deflate.deflate(data, Zlib::BEST_COMPRESSION)
        end
        
        # Verschlüssele wenn gewünscht
        if file_info[:encrypt]
          data = Encryptor.encrypt(data, ENCRYPTION_KEY)
        end
        
        # Erstelle Checksum
        checksum = Encryptor.create_checksum(data)
        
        # TOC Entry
        category_str = file_info[:category].to_s
        toc_data.write([category_str.bytesize].pack('C'))
        toc_data.write(category_str)
        toc_data.write([file_info[:relative_path].bytesize].pack('n'))
        toc_data.write(file_info[:relative_path])
        toc_data.write([data.length].pack('N'))
        toc_data.write(checksum)
        toc_data.write([file_info[:encrypt] ? 1 : 0].pack('C'))
        toc_data.write([file_info[:compress] ? 1 : 0].pack('C'))
        
        file_data_parts << data
      end
      
      puts # Neue Zeile nach Progress
      
      # Schreibe TOC
      toc = toc_data.string
      package.write([toc.length].pack('N'))
      package.write(toc)
      
      # Schreibe Dateidaten
      file_data_parts.each { |data| package.write(data) }
      
      package.string
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
  end
  
  # ============================================================================
  # Unpacker - Nur für Testing!
  # ============================================================================
  class Unpacker
    def self.unpack(output_dir = "unpacked")
      unless File.exist?(OUTPUT_FILE)
        puts "FEHLER: #{OUTPUT_FILE} nicht gefunden!"
        return false
      end
      
      puts "Entpacke #{OUTPUT_FILE}..."
      puts
      
      data = File.binread(OUTPUT_FILE)
      offset = 0
      
      # Lese Header
      magic = data[offset, 4]
      offset += 4
      
      unless magic == MAGIC_HEADER
        puts "FEHLER: Ungültige Package-Datei!"
        return false
      end
      
      version = data[offset, 3].unpack('C3')
      offset += 3
      puts "Package Version: #{version.join('.')}"
      
      file_count = data[offset, 4].unpack('N')[0]
      offset += 4
      puts "Dateien: #{file_count}"
      puts
      
      # Lese TOC
      toc_length = data[offset, 4].unpack('N')[0]
      offset += 4
      
      toc_data = data[offset, toc_length]
      offset += toc_length
      
      # Parse TOC
      files = parse_toc(toc_data, file_count)
      
      # Extrahiere Dateien
      files.each_with_index do |file_info, index|
        print "\rExtrahiere: #{index + 1}/#{file_count} - #{file_info[:path]}"
        
        file_data = data[offset, file_info[:size]]
        offset += file_info[:size]
        
        # Verifiziere Checksum
        unless Encryptor.verify_checksum(file_data, file_info[:checksum])
          puts "\nWARNUNG: Checksum-Fehler bei #{file_info[:path]}"
        end
        
        # Entschlüssele
        if file_info[:encrypted]
          file_data = Encryptor.decrypt(file_data, ENCRYPTION_KEY)
        end
        
        # Dekomprimiere
        if file_info[:compressed]
          file_data = Zlib::Inflate.inflate(file_data)
        end
        
        # Schreibe Datei
        output_path = File.join(output_dir, file_info[:category], file_info[:path])
        FileUtils.mkdir_p(File.dirname(output_path))
        File.binwrite(output_path, file_data)
      end
      
      puts
      puts
      puts "Entpacken abgeschlossen! Dateien in '#{output_dir}/'"
      
      true
    end
    
    def self.parse_toc(toc_data, file_count)
      files = []
      offset = 0
      
      file_count.times do
        category_len = toc_data[offset].unpack('C')[0]
        offset += 1
        category = toc_data[offset, category_len]
        offset += category_len
        
        path_len = toc_data[offset, 2].unpack('n')[0]
        offset += 2
        path = toc_data[offset, path_len]
        offset += path_len
        
        size = toc_data[offset, 4].unpack('N')[0]
        offset += 4
        
        checksum = toc_data[offset, 64]
        offset += 64
        
        encrypted = toc_data[offset].unpack('C')[0] == 1
        offset += 1
        
        compressed = toc_data[offset].unpack('C')[0] == 1
        offset += 1
        
        files << {
          category: category,
          path: path,
          size: size,
          checksum: checksum,
          encrypted: encrypted,
          compressed: compressed
        }
      end
      
      files
    end
  end
end

# ============================================================================
# Main Execution
# ============================================================================
if __FILE__ == $0
  require 'stringio'
  
  command = ARGV[0]
  
  case command
  when 'pack'
    GamePackager::Packer.pack
  when 'unpack'
    GamePackager::Unpacker.unpack
  when 'test'
    puts "Testing encryption..."
    puts
    GamePackager::Packer.pack
    puts
    GamePackager::Unpacker.unpack
  else
    puts "Game Packager v#{GamePackager::VERSION}"
    puts
    puts "Verwendung:"
    puts "  ruby game_packager.rb pack     - Packt und verschlüsselt das Spiel"
    puts "  ruby game_packager.rb unpack   - Entpackt (nur für Testing)"
    puts "  ruby game_packager.rb test     - Pack + Unpack Test"
  end
end
