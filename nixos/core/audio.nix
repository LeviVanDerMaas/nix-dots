{
  services.pipewire = {
    enable = true;
    pulse.enable = true; # Comptatibility with pulseaudio apps
    alsa.enable = true; # Compatiblity with ALSA apps; older cli stuff, emulators, etc.
    alsa.support32Bit = true;
  };

  security.rtkit.enable = true; # With this pipewire can request real time scheduling priority

  # TODO: Use actkbd to make binds at the system level for audio
  #wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
  #wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
  #wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  #wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}
