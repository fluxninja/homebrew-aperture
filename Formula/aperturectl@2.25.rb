class AperturectlAT225 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.25.1-rc.1.tar.gz"
  sha256 "4ff7722e4e60e9ac7655912d1a4712fc18e6707b833af2c783b55a8e60da7ce9"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.25-2.25.0-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "7ea62f4be4264703ac2a797aea9f60d4d965c45429ddf50dbb62c929401a1da2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "fc794ffee0f14fb0a73cecd0607dd16f36a44d93e9596394b7990ad09cce681c"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.25.x"
    git_commit_hash="ba4f26aa322a824d02d495e3fec8e4089344869a"

    require "open3"
    if build.head?
      head_branch="stable/v2.25.x"
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
