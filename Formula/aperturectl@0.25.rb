class AperturectlAT025 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v0.25.0-rc.2.tar.gz"
  sha256 "fa122d5d05575717a32107c99bbd8e5a7a438bf413cf3042dafb5d1fb9bba7ce"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v0.25.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    ENV["GIT_BRANCH"]="stable/v0.25.x"
    ENV["GIT_COMMIT_HASH"]="d35e4f6843b0fb05768883c54dc22608ad419248"
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
