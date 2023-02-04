class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v0.22.0-rc.1.tar.gz"
  sha256 "20890f3ad84ece9b64cd9c2e382678a9bbe352bc40cca4d5029efb3d0536ac73"
  license "Apache-2.0"

  depends_on "go" => :build

  def install
    ENV["GIT_BRANCH"]="main"
    ENV["GIT_COMMIT_HASH"]="5d995315f54de420645c457676ab8ba7a2b1e518"
    ENV["SOURCE"]="./cmd/aperturectl"
    ENV["TARGET"]=bin/name
    ENV["VERSION"]=version
    ENV["PREFIX"]="aperture"
    ENV["LDFLAGS"]="-s -w"
    system "./pkg/info/build.sh"

    generate_completions_from_executable(bin/name, "completion")
  end

  test do
    assert_match "aperturectl version #{version}", shell_output("#{bin}/aperturectl --version")
  end
end
