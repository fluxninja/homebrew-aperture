class AperturectlAT224 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.24.1-rc.1.tar.gz"
  sha256 "7f46a30b7a6d43017236f0ac1b2db8fe6470a296722a305d3265e9755a8bdf10"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.24-2.24.0"
    sha256 cellar: :any_skip_relocation, monterey:     "44c8a890f56268fe706c32d4c946c55cfbb41c5afc74728bd45a6f6bb5a98323"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "25ce243d34fc425c4a3b1d7b184ad69c378866f1b1a8a45c0409713a1cbcad60"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.24.x"
    git_commit_hash="dbe38f5f65ea2c87e5a0347a09adca678ffc2670"

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
