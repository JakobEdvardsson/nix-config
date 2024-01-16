{lib, ...}: {
  services.tlp.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = lib.mkForce false;
  powerManagement.powertop.enable = lib.mkForce false;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
      #scaling_max_freq = 1500000;
      energy_performance_preference = "power";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
}
