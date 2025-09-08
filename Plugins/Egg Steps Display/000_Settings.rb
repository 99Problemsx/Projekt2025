#===============================================================================
# Egg Steps Display EX - Configuration Settings
#===============================================================================

module EggStepsDisplay
  #-----------------------------------------------------------------------------
  # Display Settings
  #-----------------------------------------------------------------------------
  
  # Show exact step counts in party screen
  SHOW_IN_PARTY = false
  
  # Show detailed step information in summary screen
  SHOW_IN_SUMMARY = true
  
  # Show visual progress bars
  SHOW_PROGRESS_BAR = true
  
  # Show live overlay while walking (can impact performance)
  SHOW_LIVE_OVERLAY = false
  
  # Show percentage in addition to steps
  SHOW_PERCENTAGE = true
  
  # Show total steps needed for context
  SHOW_TOTAL_STEPS = true
  
  #-----------------------------------------------------------------------------
  # Visual Customization
  #-----------------------------------------------------------------------------
  
  # Progress bar colors
  PROGRESS_BAR_EMPTY = Color.new(100, 100, 100)       # Gray background
  PROGRESS_BAR_FULL = Color.new(50, 200, 50)          # Green when progressing
  PROGRESS_BAR_ALMOST = Color.new(255, 200, 0)        # Yellow when close to hatching
  PROGRESS_BAR_READY = Color.new(255, 100, 100)       # Red when ready to hatch
  
  # Text colors based on progress
  COLOR_FAR = Color.new(100, 100, 100)                # Gray - many steps left
  COLOR_MEDIUM = Color.new(200, 100, 0)               # Orange - getting there
  COLOR_CLOSE = Color.new(255, 150, 0)                # Yellow - close
  COLOR_READY = Color.new(0, 150, 0)                  # Green - ready to hatch
  
  # Font sizes
  FONT_SIZE_PARTY = 16                                # Font size in party screen
  FONT_SIZE_SUMMARY = 18                              # Font size in summary screen
  FONT_SIZE_OVERLAY = 18                              # Font size in live overlay
  
  #-----------------------------------------------------------------------------
  # Step Thresholds for Color Changes
  #-----------------------------------------------------------------------------
  
  # When to show "close to hatching" colors
  CLOSE_THRESHOLD = 100
  
  # When to show "getting there" colors  
  MEDIUM_THRESHOLD = 500
  
  #-----------------------------------------------------------------------------
  # Display Format Options
  #-----------------------------------------------------------------------------
  
  # Text formats (use {1} for numbers)
  TEXT_READY = "Ready to hatch!"
  TEXT_ONE_STEP = "1 step remaining"
  TEXT_MULTIPLE_STEPS = "{1} steps remaining"
  TEXT_WITH_PERCENTAGE = "{1} steps ({2}%)"
  TEXT_WITH_TOTAL = "{1}/{2} steps remaining"
  
  #-----------------------------------------------------------------------------
  # Overlay Settings
  #-----------------------------------------------------------------------------
  
  # Overlay position (from top-right corner)
  OVERLAY_X_OFFSET = 10
  OVERLAY_Y_OFFSET = 10
  
  # Overlay size
  OVERLAY_WIDTH = 200
  OVERLAY_HEIGHT = 60
  
  # Overlay transparency (0-255, 0 = transparent, 255 = opaque)
  OVERLAY_BACKGROUND_OPACITY = 180
  
  # Auto-hide overlay when no eggs in party
  AUTO_HIDE_OVERLAY = true
  
  #-----------------------------------------------------------------------------
  # Party Screen Settings
  #-----------------------------------------------------------------------------
  
  # Vertical offset from Pokemon icon
  PARTY_Y_OFFSET = 5
  
  # Progress bar dimensions in party screen
  PARTY_PROGRESS_BAR_WIDTH = 160
  PARTY_PROGRESS_BAR_HEIGHT = 8
  
  #-----------------------------------------------------------------------------
  # Summary Screen Settings
  #-----------------------------------------------------------------------------
  
  # Position of egg info panel
  SUMMARY_PANEL_X = 20
  SUMMARY_PANEL_Y = Graphics.height - 120
  SUMMARY_PANEL_WIDTH = Graphics.width - 40
  SUMMARY_PANEL_HEIGHT = 80
  
  # Panel colors
  SUMMARY_PANEL_BACKGROUND = Color.new(0, 0, 0, 100)
  SUMMARY_PANEL_FOREGROUND = Color.new(255, 255, 255, 200)
  
  #-----------------------------------------------------------------------------
  # Debug and Development
  #-----------------------------------------------------------------------------
  
  # Show debug information in console
  DEBUG_MODE = false
  
  # Log step changes for eggs
  LOG_STEP_CHANGES = false
  
  #-----------------------------------------------------------------------------
  # Compatibility Settings
  #-----------------------------------------------------------------------------
  
  # Disable certain features if other plugins conflict
  DISABLE_IF_PLUGIN_PRESENT = [
    # Add plugin names here if compatibility issues arise
    # Example: "SomeOtherEggPlugin"
  ]
  
  # Custom positioning for different UI plugins
  CUSTOM_PARTY_POSITIONS = {
    # Plugin name => [x_offset, y_offset]
    # Example: "EnhancedPartyScreen" => [0, 10]
  }
  
  #-----------------------------------------------------------------------------
  # Performance Settings
  #-----------------------------------------------------------------------------
  
  # Update frequency for live overlay (higher = less frequent updates, better performance)
  OVERLAY_UPDATE_FREQUENCY = 5
  
  # Maximum number of eggs to track simultaneously
  MAX_TRACKED_EGGS = 6
  
  #-----------------------------------------------------------------------------
  # Language Support
  #-----------------------------------------------------------------------------
  
  # Custom text for different languages (if needed)
  CUSTOM_TEXTS = {
    # "en" => {
    #   TEXT_READY => "Ready to hatch!",
    #   TEXT_ONE_STEP => "1 step remaining"
    # },
    # Add other languages as needed
  }
  
  #-----------------------------------------------------------------------------
  # Advanced Options
  #-----------------------------------------------------------------------------
  
  # Use alternative calculation method (for modded egg mechanics)
  USE_ALTERNATIVE_CALCULATION = false
  
  # Show fractional steps (e.g., "1.5 steps remaining")
  SHOW_FRACTIONAL_STEPS = false
  
  # Include Flame Body/Magma Armor effects in calculations
  ACCOUNT_FOR_ABILITIES = true
  
  # Custom step multipliers for different conditions
  STEP_MULTIPLIERS = {
    :flame_body => 0.5,    # Flame Body halves steps needed
    :magma_armor => 0.5,   # Magma Armor halves steps needed
    :steam_engine => 0.5   # Steam Engine also affects egg hatching (if modded)
  }
end

#===============================================================================
# Runtime configuration checker
#===============================================================================
module EggStepsDisplay
  def self.check_compatibility
    if DEBUG_MODE
      puts "Egg Steps Display EX: Checking compatibility..."
    end
    
    # Check for conflicting plugins
    DISABLE_IF_PLUGIN_PRESENT.each do |plugin_name|
      if defined?(plugin_name.constantize)
        puts "Warning: #{plugin_name} detected, some features may be disabled"
      end
    end
    
    # Validate settings
    if OVERLAY_WIDTH < 100 || OVERLAY_HEIGHT < 40
      puts "Warning: Overlay dimensions may be too small"
    end
    
    if CLOSE_THRESHOLD >= MEDIUM_THRESHOLD
      puts "Warning: Threshold values may be incorrect"
    end
  end
  
  def self.get_text(key, *args)
    # Support for custom language texts
    current_language = System.language rescue "en"
    
    if CUSTOM_TEXTS[current_language] && CUSTOM_TEXTS[current_language][key]
      text = CUSTOM_TEXTS[current_language][key]
    else
      text = key
    end
    
    # Format with arguments if provided
    args.each_with_index do |arg, i|
      text = text.gsub("{#{i+1}}", arg.to_s)
    end
    
    return text
  end
end

# Run compatibility check on plugin load
EggStepsDisplay.check_compatibility if EggStepsDisplay::DEBUG_MODE 