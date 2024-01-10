class AperturectlAT231 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.31.0-rc.1.tar.gz"
  sha256 "1086d3fb5d4202364380e9264ac1e1e18d1b090ba6d4c2061583f7b50074d229"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.30.0"
    sha256 cellar: :any_skip_relocation, monterey:     "8882aad5c31578a175dfe2e99c08b61055d3804c5b1d4aa1e02ea656a0ca8029"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a181f4f3ae1d216079c6420eb7889658f4063461b48557381d339865ba63e643"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.31.x"
    git_commit_hash="8e8a47796650ddf1f51c461aea1f213c2a99aa55"

    require "open3"
    if build.head?
      head_branch="stable/v2.31.x"
      stdout, status = Open3.capture2("git", "log", "-n1", "--format=%H")
      odie "Unable to get commit hash for head build" if status != 0
      git_commit_hash=stdout
      git_branch=head_branch
    end

    ENV["APERTURECTL_BUILD_VERSION"]=version
    ENV["APERTURECTL_BUILD_GIT_BRANCH"]=git_branch
    ENV["APERTURECTL_BUILD_GIT_COMMIT_HASH"]=git_commit_hash

    stdout, status = Open3.capture2("./scripts/build_aperturectl.sh", buildpath/"cmd/aperturectl")
    odie "Failed to build aperturectl" if status != 0

    # Move the binary into the final location
    makedirs bin
    mv stdout, bin/"aperturectl"

    generate_completions_from_executable(bin/"aperturectl", "completion")
  end

  test do
    assert_match "aperturectl version #{version}", shell_output("#{bin}/aperturectl --version")
  end
end
