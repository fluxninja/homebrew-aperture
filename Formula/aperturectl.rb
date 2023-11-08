class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.23.1.tar.gz"
  sha256 "84cf74222f6355353749809c1a0da96887c61126247ad9363683728242740d74"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.23.1"
    sha256 cellar: :any_skip_relocation, monterey:     "4c3e5cf2e5ed7a81e3558df3e7072e9d2ef0b3def1e0174d6e0d297765650f0a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c1c3d17439e315e6a6d265682016a3b18f79ccf91fa6d23b91b19e2a87b4c8bc"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.23.x"
    git_commit_hash="87ea2fefc34bdce26bf0ca5a42d74e46efa8facc"

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
