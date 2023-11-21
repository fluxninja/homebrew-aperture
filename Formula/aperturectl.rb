class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.24.0.tar.gz"
  sha256 "3d1e3652be7fa95df1070a1df3355bb011ecf9659763c7246fb44c1c75898d64"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.24.0"
    sha256 cellar: :any_skip_relocation, monterey:     "ed32abe4891394c3ac5750e4cb1955fe85d2d57ddd73116dbef20393eccfd5db"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "67b356fcb3e4faa59ccf5f17fd4dc9636027a1a05113e9404f1e10780c281352"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.24.x"
    git_commit_hash="1eeb140ca600fa7b208e3bce1311c04547732a6d"

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
