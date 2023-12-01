class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.25.2.tar.gz"
  sha256 "37710696215af7a4c589d29cbfe322e4e3c7ad793c3edb92f19ce33873f2e064"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.25.1"
    sha256 cellar: :any_skip_relocation, monterey:     "34530956ceb0d8b6c97b5e5f8fa2bf97bda7315807c38e5fd94b6694d3379c3f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4c76b456c9ff29fa78d5d17b15a7b272396ffdfa0d714c70556c487b02b14e03"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.25.x"
    git_commit_hash="cf6cee46be8d0800f5c539df07953b0757cfccfb"

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
