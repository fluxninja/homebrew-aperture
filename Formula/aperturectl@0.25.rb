class AperturectlAT025 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v0.25.1-rc.1.tar.gz"
  sha256 "77afe2d4b09b500cdc43f545207455fa1c8d5bdafdc441132918b6e38e76b26f"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v0.25.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    ENV["GIT_BRANCH"]="stable/v0.25.x"
    ENV["GIT_COMMIT_HASH"]="c820d6daa0b2591948e439794fc190a8b2fcf71c"
    ENV["SOURCE"]="./cmd/aperturectl"
    ENV["TARGET"]=bin/"aperturectl"
    ENV["VERSION"]=version
    ENV["PREFIX"]="aperture"
    ENV["LDFLAGS"]="-s -w"
    if build.head?
      head_branch="stable/v0.25.x"
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
