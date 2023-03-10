class AperturectlAT026 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v0.26.1.tar.gz"
  sha256 "0596ccb114ebe5f5a48b809cb80f8ce60e984faede50d8cb884d6938293b303e"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v0.26.x"

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    ENV["GIT_BRANCH"]="stable/v0.26.x"
    ENV["GIT_COMMIT_HASH"]="881652f2b8d6d9850925ff230a559992e51d6c7e"
    ENV["SOURCE"]="./cmd/aperturectl"
    ENV["TARGET"]=bin/"aperturectl"
    ENV["VERSION"]=version
    ENV["PREFIX"]="aperture"
    ENV["LDFLAGS"]="-s -w"
    if build.head?
      head_branch="stable/v0.26.x"
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
