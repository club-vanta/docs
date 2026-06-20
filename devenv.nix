{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Enable Python support
  languages.python = {
    enable = true;
    # Use latest available version via nixpkgs-python
    version = "3.13";

    # Configure uv
    uv = {
      enable = true;
      package = pkgs.uv;
    };

    # Explicitly enable venv
    venv.enable = true;
  };

  # Packages
  packages = [
    pkgs.uv
  ];

  # Setup hook to install Material MKDocs when the shell starts
  # This assumes a standard uv workflow
  enterShell = ''
    if [ ! -d ".venv" ]; then
      uv venv
      uv add mkdocs-material
    fi
    source .venv/bin/activate
  '';

  # See full reference at https://devenv.sh/reference/options/
}
