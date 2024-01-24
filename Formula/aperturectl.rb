class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.32.2.tar.gz"
  sha256 "ba63b9f0006d6487d84ffa298598eae0c947fbea1d3840a0b756f390f7268b1c"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.32.2"
    sha256 cellar: :any_skip_relocation, monterey:     "0b365e050261f7882879964be8a314977d9b5d6e2efca90f4a71d28556e28b1a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8e7ada5c34ad2cab9243f7bb788f3c6a6535f0e7fa736cb2951cd33e513e978e"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.32.x"
    git_commit_hash="7e6cdb16224b5951e4d89f550026f0cce8ea8c70"

    require "open3"
    if build.head?
      head_branch="main"
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
