class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v0.22.0.tar.gz"
  sha256 "fc9898e6c1fede384abfe6da67c571f8cba5df22e235d7f792c2dd997656336c"
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
