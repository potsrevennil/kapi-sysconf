{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/mmcblk1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              # Firmware backoff
              start = "16M";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0022" ];
              };
            };
          };
        };
      };
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "/" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/home";
                  };
                  "/nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
                };

                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
