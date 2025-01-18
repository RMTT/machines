{ ... }: {
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    raopOpenFirewall = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
