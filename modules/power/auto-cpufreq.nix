{...}: {
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = false;
  powerManagement.powertop.enable = false;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
      scaling_max_freq = 1500000;
      energy_performance_preference = "power";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
}
