class AperturectlAT226 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.26.0-rc.1.tar.gz"
  sha256 "7f9ef79c102efda1cc3cebf78395a49bd165b0bf20363beaf5310826417420f4"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.26-2.26.0-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "b2217bc96132a7a855c4319c0edaca4d793512c02b40c27bff03517750b2ee4a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4e61b2ec1c5dae98d97b216722cf25bd5b7fb6fa627962ebc13dd11f5913839f"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.26.x"
    git_commit_hash="0a2469568077d90aeb7216d5dc00178003896fb9"

    require "open3"
    if build.head?
      head_branch="stable/v2.26.x"
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
