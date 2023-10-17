class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.20.1.tar.gz"
  sha256 "06f4ddd0fc01ac3fa392bea95d125a400519d2d172741c74f0a02cedf0a177c3"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.20.0"
    sha256 cellar: :any_skip_relocation, monterey:     "b7643fbd9e55fec403ace743bb1ec9c2b2bb88ea9233eda2899a93c900c68674"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c5e753c627ac7a0b82faabd5f729212646ccc61eb0b9ece7d863dc2f541831a0"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.20.x"
    git_commit_hash="09be7327245d9b7c2f558cc6fb9ffe8b652c8d94"

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
