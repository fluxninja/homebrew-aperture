class AperturectlAT232 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.32.2-rc.1.tar.gz"
  sha256 "90fc7e4766fe3f1bf02edfea9a68d35b5ddf3c71a1552b906dea3c1d5e87bc2e"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.32-2.32.1-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "f62e89d1c2c73022d89523de5f1ed175ea1bf921df270de9d35d5ff568783831"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "54e25e4abda00c50dd4294d4b4c8e218857b16c8633c6cb455bb626152827ec3"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.32.x"
    git_commit_hash="7e6cdb16224b5951e4d89f550026f0cce8ea8c70"

    require "open3"
    if build.head?
      head_branch="stable/v2.32.x"
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
