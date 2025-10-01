#-----------------------------------------------------------------------------
# Script Name: Idle Bubble System 1.0.1
# Author: Luxintra
# Date: 2025-05-08
# Description: Displays idle bubble text over an event when the player is nearby.
#-----------------------------------------------------------------------------

def pbIdleBub(str, r = 5, wait_time = 3, event_id = nil, instant = false)
  raise ArgumentError, "pbIdleBub: must supply an event ID" unless event_id
  evt = $game_map.events[event_id]
  $idleBub = Idle_Bub.new(str, r, wait_time, evt, instant)
end

class Idle_Bub
  attr_accessor :event, :string, :radius, :wait_time, :instant

  def initialize(str, r, wait_time, evt, instant)
    @event     = evt
    @string    = str
    @radius    = r
    @wait_time = wait_time
    @instant   = instant
  end

  def should_hide?
    return false unless $game_message
    $game_message.busy?
  end
end

def pbDisposeIdleBub
  return unless $idleBub
  $idleBub.event.clearIdleBubble
  $idleBub = nil
end

class Game_Event < Game_Character
  attr_accessor :idle_msgwindow, :idle_arrow, :idle_time, :idle_wait_time, :bubble_done

  alias idleBubble_update update
  def update
    update_idle_bubble if $idleBub && self.id == $idleBub.event.id
    idleBubble_update
  end

  def update_idle_bubble
    return unless $idleBub
    d = distance_to_player
    fade_step = 5
    min_opacity = 50

    if d > $idleBub.radius
      if @idle_msgwindow
        @idle_msgwindow.opacity -= fade_step
        @idle_arrow.opacity     -= fade_step
        if @idle_msgwindow.opacity <= min_opacity
          dispose_idle_bubble
        end
        reposition_idle_bubble
      end
      return
    end

    if @idle_msgwindow
      @idle_msgwindow.opacity += fade_step if @idle_msgwindow.opacity < 255
      @idle_arrow.opacity     += fade_step if @idle_arrow.opacity < 255
    end
    reposition_idle_bubble

    if !@idle_msgwindow && !@idle_wait_time
      viewport = nil
      @idle_msgwindow = create_idle_msg_window(viewport)
      @idle_arrow     = create_idle_arrow(viewport)
      reposition_idle_bubble
      @bubble_done = false
      return
    end

    if @idle_msgwindow
      @idle_msgwindow.update

      if (!$idleBub.instant && !@idle_msgwindow.busy?) || $idleBub.instant
        unless @bubble_done
          @idle_time = Graphics.frame_count
          @bubble_done = true
        end
      end

      if @bubble_done && Graphics.frame_count - @idle_time > $idleBub.wait_time * Graphics.frame_rate
        dispose_idle_bubble
        @idle_wait_time = Graphics.frame_count
        return
      end
    end

   if @idle_wait_time && Graphics.frame_count - @idle_wait_time > $idleBub.wait_time * Graphics.frame_rate
     @idle_wait_time = nil
   end
  end

  def dispose_idle_bubble
    @idle_msgwindow.dispose if @idle_msgwindow
    @idle_arrow.dispose     if @idle_arrow
    @idle_msgwindow = nil
    @idle_arrow = nil
    @idle_time = nil
    @bubble_done = nil
  end

  def clearIdleBubble
    dispose_idle_bubble
    @idle_wait_time = nil
  end

  def distance_to_player
    Math.hypot($game_player.x - self.x, $game_player.y - self.y)
  end

  def reposition_idle_bubble
    return unless @idle_msgwindow && @idle_arrow
    sx = self.screen_x
    sy = self.screen_y
    @idle_arrow.x = sx - 16
    @idle_arrow.y = sy - 56
    @idle_msgwindow.x = sx - (@idle_msgwindow.width / 2)
    @idle_msgwindow.y = @idle_arrow.y - @idle_arrow.bitmap.height - @idle_msgwindow.height + 24
  end

  def create_idle_arrow(viewport)
    arrow = Sprite.new(viewport)
    arrow.bitmap = RPG::Cache.picture("bubbleArrowDown")
    arrow.z = 200
    arrow
  end

  def create_idle_msg_window(viewport)
    window = Window_AdvancedTextPokemon.new("")
    window.viewport = viewport if viewport
    window.letterbyletter = !$idleBub.instant
    window.back_opacity   = MessageConfig::WINDOW_OPACITY
    window.setSkin(MessageConfig.pbGetSpeechFrame)
    unless $idleBub.instant
  if defined?($PokemonSystem) && $PokemonSystem
    speed_setting = $PokemonSystem.textSpeed rescue 1
    window.textspeed = (MessageConfig.pbSettingToTextSpeed(speed_setting)).ceil
  else
    window.textspeed = 2  # fallback: medium speed
  end
end
    lines = $idleBub.string.include?("\n") || $idleBub.string.size > 20 ? 2 : 1
    window.height = 32 * lines + window.borderY
    window.width  = 200 + window.borderX
    window.text   = $idleBub.string
    window.visible = true
    window.z = 200
    window
  end
end

class Game_Map
  alias idleBubble_setup setup
  def setup(map_id)
    pbDisposeIdleBub
    idleBubble_setup(map_id)
  end
end
