{...}: {
  services.xserver = {
    libinput.touchpad.naturalScrolling = true;
    # synaptics.accelFactor = "1.0";
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      mouse.accelSpeed = "-0.1";
    };
  };
}
