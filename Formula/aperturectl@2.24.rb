class AperturectlAT224 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.24.0-rc.1.tar.gz"
  sha256 "4fae42d3f9324b820edc80c5256d9b6455fef559292473127b3bcadcad8748e5"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.23.3"
    sha256 cellar: :any_skip_relocation, monterey:     "49664ab96275e7c05ccd79e5f9f5e220298ffbc7ad34743ff5d29aa38f18d6d6"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0cfb756549bb2c85629ecbc5957a07fb160d16caa016fff27013233a42ee7747"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.24.x"
    git_commit_hash="1eeb140ca600fa7b208e3bce1311c04547732a6d"

    require "open3"
    if build.head?
      head_branch="stable/v2.24.x"
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
