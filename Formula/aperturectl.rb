class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.20.2.tar.gz"
  sha256 "6c399ee02a1567950bed627542331fdd461aa845c7d765dcc8460664b084c869"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.20.1"
    sha256 cellar: :any_skip_relocation, monterey:     "1c9136d807f6fe948e280227da89b11c105a0c508432bbe15b9faf276feb0f7f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c1ce012d33607617ad284608f08d3585cedb94c98b22934f9653aa00147407b7"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.20.x"
    git_commit_hash="6f0c4e269273659249bdbad68c7c97288db42611"

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
