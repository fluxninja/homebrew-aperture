class AperturectlAT219 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.19.4.tar.gz"
  sha256 "2502345ab3b65b83480dca55236312b1826a083006e3b61ad455aad798111df3"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.19.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.19-2.19.4-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "d74b086fac29292c4df30dd8e33d2a0702aed99b85fb6e1ddb14983ce564ea88"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8f9cb1941c6d3f967fbcf6dd3a769bf1b4656192b9c44f9faae898e7313d77cc"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.19.x"
    git_commit_hash="93f0df6aae786ff16678d6a2123ea2ddca486056"

    require "open3"
    if build.head?
      head_branch="stable/v2.19.x"
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
