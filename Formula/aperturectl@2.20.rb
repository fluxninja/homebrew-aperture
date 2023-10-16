class AperturectlAT220 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.20.0-rc.1.tar.gz"
  sha256 "d85d1c2e809946873aad7981e8e1563839547b57a65ffb04ecf135452f8e5eb1"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.20.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.19.4"
    sha256 cellar: :any_skip_relocation, monterey:     "dc42abd32d3191e0801cd0ede9ed691ed291716fdd0b672f0a454905c7337a84"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "02a5b85dd2445ba8807008e7fc774c971e18f7021d69420e7802f6b5ce6b69e7"
  end
  
  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.20.x"
    git_commit_hash="13ed5a2edfa4e01f6b25dd3302778f40ff211173"

    require "open3"
    if build.head?
      head_branch="stable/v2.20.x"
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
