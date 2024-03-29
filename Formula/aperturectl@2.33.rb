class AperturectlAT233 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.33.1.tar.gz"
  sha256 "367abc49b1caaf56b3274b8df4a5a0f5c38ff1ec27a56081c2a6f3d490c43675"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.33-2.33.1"
    sha256 cellar: :any_skip_relocation, monterey:     "66bf15c298cfc1d40280bf71ec5f04734a4a60c918e41107fb29491c30c24e42"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b31d4c0eaa465d251742cefd13fa9a90de1698614a2667b44f7c022c3964ea4b"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.33.x"
    git_commit_hash="3834d85f6655f64d3b9bd845fc79347f19fbe338"

    require "open3"
    if build.head?
      head_branch="stable/v2.33.x"
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
