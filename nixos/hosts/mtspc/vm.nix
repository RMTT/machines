{ lib, ... }: {
  virtualisation.vmVariant = {
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display sdl,gl=on,show-cursor=off"
      # Wire up pipewire audio
      "-audiodev pipewire,id=audio0"
    ];
  };
}
