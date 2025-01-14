{ lib, pkgs, ... }: {
  virtualisation.vmVariant = {
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display sdl,gl=on,show-cursor=off"
      # Wire up pipewire audio
      "-audiodev pipewire,id=audio0"
    ];
    virtualisation = {
      memorySize = 4096;
      cores = 3;
      diskSize = 20 * 1024;
      forwardPorts = [{
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }];
    };
  };
}
