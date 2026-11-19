{...}: {
  flake.nixosModules.join_domain = { config, pkgs, lib, ...}: {
  # Join AD: sudo adcli join --domain=engr.colostate.edu --user=ETSTech

  environment.systemPackages = with pkgs; [
    # AD
    adcli
    krb5
    realmd
    samba
    sssd
  ];

  services.realmd.enable = true;

  security = {
    krb5 = {
      enable = true;
      settings = {
        libdefaults = {
          udp_preference_limit = 0;
          default_realm = "ENGR.COLOSTATE.EDU";
        };
      };
    };
    pam = {
      makeHomeDir.umask = "077";
      services.login.makeHomeDir = true;
      services.sshd.makeHomeDir = true;
    };

    sudo = {
      extraConfig = ''
        %lab\ admins ALL=(ALL:ALL) NOPASSWD: ALL
        Defaults:%lab\ admins env_keep+=TERMINFO_DIRS
        Defaults:%lab\ admins env_keep+=TERMINFO
      '';

      # Alternatively, you can use the GID.
      # extraRules = [
      #   { groups = [ "domain admins" ];
      #     commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; }  ]; }
      # ];
    };
  };

  # Ensures that this system is discoverable to others on the network.
  # Akin to setting network discovery in windows.
  # I MAY need to override system.nssDatabases.hosts to ensure this works.
  services.samba-wsdd = {
    enable = true;
    discovery = false;
    hostname = "FORTNITE";
  };
  services.samba = {
    enable = true;
    nsswins = true;
    smbd.enable = true;
  };

  security.pam.services.sddm.makeHomeDir = true;

  #
  # Services
  #
  services = {
    nscd = {
      enable = true;
      config = ''
        server-user nscd
        enable-cache hosts yes
        positive-time-to-live hosts 0
        negative-time-to-live hosts 0
        shared hosts yes
        enable-cache passwd no
        enable-cache group no
        enable-cache netgroup no
        enable-cache services no
      '';
    };

    sssd = {
      enable = true;
      config = ''
        [sssd]
        domains = engr.colostate.edu
        config_file_version = 2
        services = nss, pam

        [pam]
        offline_credentials_expiration = 365

        [domain/engr.colostate.edu]
        override_shell = ${lib.getExe pkgs.zsh}
        override_homedir = /home/%u
        krb5_store_password_if_offline = true
        cache_credentials = true
        account_cache_expiration = 365
        entry_cache_timeout = 14400

        krb5_realm = ENGR.COLOSTATE.EDU
        realmd_tags = manages-system joined-with-samba
        use_fully_qualified_names = false
        ldap_id_mapping = true

        ad_domain = engr.colostate.edu
        id_provider = ad
        auth_provider = ad
        access_provider = ad
        chpass_provider = ad
        ad_gpo_access_control = permissive

        dyndns_update = true
        dyndns_refresh_interval = 43200
        dyndns_update_ptr = true
        dyndns_ttl = 3600

        enumerate = true
        ignore_group_members = true
      '';
      };
    };
  };
}