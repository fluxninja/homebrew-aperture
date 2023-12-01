class AperturectlAT225 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.25.2-rc.1.tar.gz"
  sha256 "4a3342a408d5f60c77806dc8917669a0ccd6337b784c9fe8f896d88387ea4ab2"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.25-2.25.2-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "d94ae8083360eb98c260efabdb4bd534678850fdef64e1b152d0024341039c81"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7f38946f0e6cb14b9d04e972b1cb9f840f109235175387e403e30713398f4488"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.25.x"
    git_commit_hash="cf6cee46be8d0800f5c539df07953b0757cfccfb"

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
