class AperturectlAT221 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.21.0.tar.gz"
  sha256 "cf1ffa4691644a424077f7f20ef4c0c0228de5858f9d772649c2e4bb7bfc2b5c"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "stable/v2.21.x"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.21-2.21.0"
    rebuild 1
    sha256 cellar: :any_skip_relocation, monterey:     "d67bb69a7f0179d92e84a10bf3fa23dc15cd2b8e0037dc2071bbfb1d1058d442"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1fc5af4f658c85743aa71ec2ce8c1ab71d8f8b96c2afbe8a6379460b1ad23874"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.21.x"
    git_commit_hash="60288a78053542f8a3a4fbf8b654ada63d76bcfc"

    require "open3"
    if build.head?
      head_branch="stable/v2.21.x"
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
