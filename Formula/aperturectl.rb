class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.24.1.tar.gz"
  sha256 "13a82deb27f024b07f16af0562aadfaaa4da8c543583992e3892391074b63270"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.24.1"
    sha256 cellar: :any_skip_relocation, monterey:     "637327d609aa142f8d58886b4c644590a25cc284470fd4b4a8f801b507464180"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7586905e52bd30b32567c78cff31ab9355ff1fad47e17b25f49b37ae40489c41"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.24.x"
    git_commit_hash="dbe38f5f65ea2c87e5a0347a09adca678ffc2670"

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
