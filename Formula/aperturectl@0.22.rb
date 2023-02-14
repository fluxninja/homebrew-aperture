class AperturectlAT022 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v0.22.0.tar.gz"
  sha256 "fc9898e6c1fede384abfe6da67c571f8cba5df22e235d7f792c2dd997656336c"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v0.22.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    ENV["GIT_BRANCH"]="stable/v0.22.x"
    ENV["GIT_COMMIT_HASH"]="d9e2d93361c672b81bff0d623f7c4407a13e9299"
    ENV["SOURCE"]="./cmd/aperturectl"
    ENV["TARGET"]=bin/"aperturectl"
    ENV["VERSION"]=version
    ENV["PREFIX"]="aperture"
    ENV["LDFLAGS"]="-s -w"
    if build.head?
      head_branch="stable/v0.22.x"
      require "open3"
      stdout, status = Open3.capture2("git", "log", "-n1", "--format=%H")
      odie "Unable to get commit hash for head build" if status != 0
      ENV["GIT_COMMIT_HASH"]=stdout
      ENV["GIT_BRANCH"]=head_branch
    end

    system "./pkg/info/build.sh"

    generate_completions_from_executable(bin/"aperturectl", "completion")
  end

  test do
    assert_match "aperturectl version #{version}", shell_output("#{bin}/aperturectl --version")
  end
end
