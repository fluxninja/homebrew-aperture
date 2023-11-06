class AperturectlAT222 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.22.1.tar.gz"
  sha256 "25d69625f53e9aeaee1f87a96f67b2c879d3a6efb0b16d04781cc43bfc4320a9"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.22-2.22.1"
    sha256 cellar: :any_skip_relocation, monterey:     "f7690f9954309306b7fcd0168fd222143e357b1226f1daa28811757222506ea0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c67e75feef724a79c2d12d551a0fc8f9b1384895ac030ff7845fd54053ae23df"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.22.x"
    git_commit_hash="4fbd606098c604389a30d29b5322b73f2f47d734"

    require "open3"
    if build.head?
      head_branch="stable/v2.22.x"
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
