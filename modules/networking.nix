{
  host,
  options,
  ...
}:
{

  # networking
  networking.networkmanager.enable = true;
  networking.hostName = "${host}";
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];

  networking.firewall.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # networking.wireless = {
  #   enable = true;
  #   fallbackToWPA2 = false;
  #   # Declarative
  #   networks = {
  #     "eduroam" = {
  #       authProtocols = [ "WPA-EAP" ];
  #       auth = ''
  #         pairwise=CCMP
  #         group=CCMP TKIP
  #         eap=TTLS
  #         ca_cert="${../ca.pem}"
  #         identity="*****@mau.se"
  #         password="*************"
  #         phase2="auth=MSCHAPV2"
  #       '';
  #     };
  #   };
  # };
  # Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };
}
