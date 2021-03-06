{ stdenv, lib, fetchFromGitHub
, go, libapparmor, apparmor-parser, libseccomp }:

with lib;

stdenv.mkDerivation rec {
  name = "containerd-${version}";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "docker";
    repo = "containerd";
    rev = "v${version}";
    sha256 = "16p8kixhzdx8afpciyf3fjx43xa3qrqpx06r5aqxdrqviw851zh8";
  };

  buildInputs = [ go ];

  preBuild = ''
    ln -s $(pwd) vendor/src/github.com/docker/containerd
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/* $out/bin
  '';

  preFixup = ''
    # remove references to go compiler
    while read file; do
      sed -ri "s,${go},$(echo "${go}" | sed "s,$NIX_STORE/[^-]*,$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,"),g" $file
    done < <(find $out/bin -type f 2>/dev/null)
  '';

  meta = {
    homepage = https://containerd.tools/;
    description = "A daemon to control runC";
    license = licenses.asl20;
    maintainers = with maintainers; [ offline ];
    platforms = platforms.linux;
  };
}
