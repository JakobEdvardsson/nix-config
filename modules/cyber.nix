{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nmap
    metasploit
    john
  ];
}
