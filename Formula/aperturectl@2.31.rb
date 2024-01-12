class AperturectlAT231 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.31.1.tar.gz"
  sha256 "aee7bbc9469295d1971c7afbee7c3d829fde67f21cc95ee5f1cbc60a937a94da"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.31-2.31.1"
    sha256 cellar: :any_skip_relocation, monterey:     "9a7533b3eb35559c15c7c06c76ba8685b45d2b280facbbacf6a9e97010a20fcf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9473498e2ef531933bd7a29f6fdf146f6609a8850caa611172782a38c5d2f7fe"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.31.x"
    git_commit_hash="145929cef02253795246e93ff6d66a91026f786f"

    require "open3"
    if build.head?
      head_branch="stable/v2.31.x"
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