class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.28.0.tar.gz"
  sha256 "a0e7898743d640b9b7e5f87a6d9d9acd13af984c0ac1ce2397933e4d4e2cb61f"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.27.1"
    sha256 cellar: :any_skip_relocation, monterey:     "a3ff4fa72b9fff5d2c9a073ecc82db17bb71d048d1531fd47b47a83fa9194fed"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4c48a9a4c932772aed6b79174abe6fd71e0a8f6a1f2b69eee3d44762330ae993"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.28.x"
    git_commit_hash="c857905d73cbb7f962469da142ff407763537811"

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
