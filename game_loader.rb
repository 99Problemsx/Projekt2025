# ============================================================================
# Game Loader - Lädt verschlüsselte Assets zur Laufzeit
# ============================================================================
# Dieses Script wird beim Spielstart geladen und stellt die verschlüsselten
# Assets transparent zur Verfügung
# ============================================================================

require 'zlib'
require 'digest'

module GameLoader
  VERSION = "1.0.0"
  
  # WICHTIG: Diese müssen EXAKT mit game_packager.rb übereinstimmen!
  ENCRYPTION_KEY = "MeinGeheimesSpielProjekt2025_XYZ123"
  SALT = "CustomSaltValue987654321"
  MAGIC_HEADER = "GMPK"
  PACKAGE_FILE = "GameData.pack"
  
  # Cache für geladene Dateien
  @@file_cache = {}
  @@package_loaded = false
  @@file_table = {}
  @@package_data = nil
  
  # ============================================================================
  # Verschlüsselungs-Engine (identisch mit Packager)
  # ============================================================================
  class Encryptor
    def self.generate_key(base_key, salt, length = 256)
      Digest::SHA256.digest(base_key + salt).bytes.cycle.first(length)
    end
    
    def self.decrypt(data, key_base)
      return data if data.nil? || data.empty?
      
      key = generate_key(key_base, SALT)
      key_len = key.length
      original_size = data.length
      
      # Layer 3 rückwärts (optimiert)
      key_reversed = key.reverse
      bytes = data.bytes
      decrypted_bytes = []
      bytes.each_with_index do |byte, i|
        decrypted_bytes << ((byte ^ key_reversed[i % key_len]) & 0xFF)
      end
      decrypted = decrypted_bytes.pack('C*')
      
      # Layer 2 rückwärts (nur wenn shuffled)
      decrypted = unshuffle_bytes(decrypted, key) if original_size < 1_000_000
      
      # Layer 1 rückwärts (optimiert)
      bytes = decrypted.bytes
      decrypted_bytes = []
      bytes.each_with_index do |byte, i|
        decrypted_bytes << ((byte ^ key[i % key_len] ^ (i % 256)) & 0xFF)
      end
      decrypted_bytes.pack('C*')
    end
    
    def self.unshuffle_bytes(data, key)
      bytes = data.bytes
      length = bytes.length
      return data if length <= 1
      
      rng_state = key.sum
      swaps = []
      (length - 1).downto(1) do |i|
        rng_state = (rng_state * 1103515245 + 12345) & 0x7FFFFFFF
        j = rng_state % (i + 1)
        swaps << [i, j]
      end
      
      swaps.reverse.each do |i, j|
        bytes[i], bytes[j] = bytes[j], bytes[i]
      end
      
      bytes.pack('C*')
    end
    
    def self.verify_checksum(data, checksum)
      Digest::SHA256.hexdigest(data) == checksum
    end
  end
  
  # ============================================================================
  # Package Loader
  # ============================================================================
  def self.load_package
    return true if @@package_loaded
    
    # Verwende File-Methoden direkt um Rekursion zu vermeiden
    package_path = File.expand_path(PACKAGE_FILE, Dir.pwd)
    unless File.original_exist?(package_path)
      # Kein Package gefunden - stille Rückkehr
      return false
    end
    
    # Lade Package still im Hintergrund
    
    @@package_data = File.original_binread(package_path)
    
    if @@package_data.nil? || @@package_data.empty?
      puts "\nFEHLER: Package-Datei konnte nicht gelesen werden!"
      return false
    end
    
    offset = 0
    
    # Lese Header
    magic = @@package_data[offset, 4]
    offset += 4
    
    unless magic == MAGIC_HEADER
      puts "\nFEHLER: Ungültige Package-Datei!"
      return false
    end
    
    version = @@package_data[offset, 3].unpack('C3')
    offset += 3
    
    file_count = @@package_data[offset, 4].unpack('N')[0]
    offset += 4
    
    # Lese TOC
    toc_length = @@package_data[offset, 4].unpack('N')[0]
    offset += 4
    
    if toc_length.nil? || toc_length == 0
      puts "\nFEHLER: TOC-Länge ist ungültig!"
      return false
    end
    
    toc_data = @@package_data[offset, toc_length]
    
    if toc_data.nil? || toc_data.empty?
      puts "\nFEHLER: TOC-Daten konnten nicht gelesen werden!"
      return false
    end
    
    offset += toc_length
    
    # Parse TOC und erstelle File Table
    parse_toc(toc_data, file_count, offset)
    
    @@package_loaded = true
    # Stille Ladung - keine Ausgabe
    
    true
  end
  
  def self.parse_toc(toc_data, file_count, data_offset)
    return false unless toc_data && toc_data.size > 0
    
    offset = 0
    current_data_offset = data_offset
    
    file_count.times do |i|
      # Ruby 3.x: toc_data[offset] already returns Integer
      if offset >= toc_data.size
        puts "\nFEHLER: TOC offset out of bounds at file #{i}/#{file_count}"
        return false
      end
      
      # Read category length and ensure it's an integer
      category_len = toc_data[offset].ord  # Use .ord to get byte value as integer
      offset = offset.to_i + 1
      
      # Safety check
      if offset + category_len > toc_data.size
        puts "\nFEHLER: Category read would exceed TOC size (offset=#{offset}, len=#{category_len}, toc_size=#{toc_data.size})"
        return false
      end
      
      # Read category string
      category = toc_data[offset, category_len]
      offset = offset.to_i + category_len.to_i
      
      # Safety check for path_len read
      if offset + 2 > toc_data.size
        puts "\nFEHLER: Path length read would exceed TOC size"
        return false
      end
      
      # Read path length
      path_len_data = toc_data[offset, 2]
      if path_len_data.nil? || path_len_data.length < 2
        puts "\nFEHLER: Could not read path length"
        return false
      end
      path_len = path_len_data.unpack('n')[0].to_i
      offset = offset.to_i + 2
      
      # Safety check for path read
      if offset + path_len > toc_data.size
        puts "\nFEHLER: Path read would exceed TOC size (offset=#{offset}, len=#{path_len}, toc_size=#{toc_data.size})"
        return false
      end
      
      # Read path string
      path = toc_data[offset, path_len]
      offset = offset.to_i + path_len.to_i
      
      # Safety check for size read
      if offset + 4 > toc_data.size
        puts "\nFEHLER: Size read would exceed TOC size at file #{i}"
        return false
      end
      
      # Read file size
      size_data = toc_data[offset, 4]
      if size_data.nil? || size_data.length < 4
        puts "\nFEHLER: Could not read file size"
        return false
      end
      size = size_data.unpack('N')[0].to_i
      offset = offset.to_i + 4
      
      # Read checksum
      checksum = toc_data[offset, 64]
      offset = offset.to_i + 64
      
      # Ruby 3.x: toc_data[offset] returns single char string, use .ord for byte value
      encrypted = toc_data[offset].ord == 1
      offset = offset.to_i + 1
      
      compressed = toc_data[offset].ord == 1
      offset = offset.to_i + 1
      
      # Erstelle Lookup-Keys
      full_path = "#{category}/#{path}"
      normalized_path = full_path.gsub('\\', '/')
      
      file_info = {
        offset: current_data_offset,
        size: size,
        checksum: checksum,
        encrypted: encrypted,
        compressed: compressed,
        category: category,
        path: path
      }
      
      @@file_table[normalized_path] = file_info
      @@file_table[normalized_path.downcase] = file_info  # Case-insensitive
      
      current_data_offset += size
    end
  end
  
  # ============================================================================
  # File Access Methods
  # ============================================================================
  def self.get_file(path)
    load_package unless @@package_loaded
    
    # Normalisiere Pfad
    normalized = path.gsub('\\', '/').downcase
    
    # Prüfe Cache
    return @@file_cache[normalized] if @@file_cache.key?(normalized)
    
    # Finde in File Table
    file_info = @@file_table[normalized]
    
    unless file_info
      # Versuche alternative Pfade
      ["Data/Scripts/", "Data/", "PBS/", "Graphics/"].each do |prefix|
        alt_path = "#{prefix}#{path}".gsub('\\', '/').downcase
        file_info = @@file_table[alt_path]
        break if file_info
      end
    end
    
    return nil unless file_info
    
    # Extrahiere Daten
    data = @@package_data[file_info[:offset], file_info[:size]]
    
    # Verifiziere Checksum
    unless Encryptor.verify_checksum(data, file_info[:checksum])
      puts "WARNUNG: Checksum-Fehler bei #{path}"
    end
    
    # Entschlüssele
    data = Encryptor.decrypt(data, ENCRYPTION_KEY) if file_info[:encrypted]
    
    # Dekomprimiere
    data = Zlib::Inflate.inflate(data) if file_info[:compressed]
    
    # Cache
    @@file_cache[normalized] = data
    
    data
  end
  
  def self.file_exists?(path)
    load_package unless @@package_loaded
    normalized = path.gsub('\\', '/').downcase
    @@file_table.key?(normalized)
  end
  
  def self.list_files(category = nil)
    load_package unless @@package_loaded
    
    if category
      @@file_table.select { |_, info| info[:category] == category.to_s }.keys
    else
      @@file_table.keys
    end
  end
  
  # ============================================================================
  # Integration mit RPG Maker
  # ============================================================================
  
  # Überschreibe File.read für verschlüsselte Dateien
  class << File
    alias_method :original_read, :read
    alias_method :original_binread, :binread
    alias_method :original_exist?, :exist?
    
    def read(path, *args)
      # Versuche zuerst aus Package zu laden
      if GameLoader.file_exists?(path)
        data = GameLoader.get_file(path)
        return data if data
      end
      
      # Fallback auf normale Datei
      original_read(path, *args)
    end
    
    def binread(path, *args)
      # Versuche zuerst aus Package zu laden
      if GameLoader.file_exists?(path)
        data = GameLoader.get_file(path)
        return data if data
      end
      
      # Fallback auf normale Datei
      original_binread(path, *args)
    end
  end
  
  # Marshal.load Unterstützung für .rxdata
  module Marshal
    class << self
      alias_method :original_load, :load
      
      def load(source, proc = nil)
        # Wenn source ein String ist (Dateiname), versuche aus Package
        if source.is_a?(String) && source.end_with?('.rxdata')
          data = GameLoader.get_file(source)
          if data
            return original_load(StringIO.new(data), proc)
          end
        end
        
        # Normale Marshal.load
        original_load(source, proc)
      end
    end
  end
end

# ============================================================================
# Auto-Load beim Start (wird von 001_Settings.rb aufgerufen)
# ============================================================================
# Lade Package automatisch wenn verfügbar
if File.exist?(GameLoader::PACKAGE_FILE)
  GameLoader.load_package
end
