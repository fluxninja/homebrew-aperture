class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.32.0.tar.gz"
  sha256 "e19f4ffd303bc56538af98b9553bd1b2d517a32e085a8d402a390837010ed68b"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.31.1"
    sha256 cellar: :any_skip_relocation, monterey:     "598f621eb58686a1c2c8a792069bb1ec025fa505e055e1f1694a2313da7dfa75"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "79b83e5438ea939e3bfe622a55c2bc181493a9fbf907d5465f9faaf3084e6d15"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.32.x"
    git_commit_hash="4602e2762f5ec55e04d9ec0457861e85d24c397e"

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
