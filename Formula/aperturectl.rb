class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.29.1.tar.gz"
  sha256 "0e7b0b02a5caafcd4f4e306667cab7a3d307c6619bd19475b0fab1dbcc96e82d"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.29.1"
    sha256 cellar: :any_skip_relocation, monterey:     "7a2f40053cf90cdd1ff34c8cb12176a80791ee90161861fe07d11ad8b0a907bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "902cae3cfb3942f3eb87b58c263425bed402436c952d702638c3e4328da47e3d"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.29.x"
    git_commit_hash="692842c9f83cb10897861052baf1e9f91e9069b5"

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
