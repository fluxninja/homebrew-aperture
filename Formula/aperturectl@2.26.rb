class AperturectlAT226 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.26.0.tar.gz"
  sha256 "c1e13ff08e5305ce7f41ecefdd6e4f8891a4dbcb094545c2163e96381ea4b69f"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.26-2.26.0-rc.3"
    sha256 cellar: :any_skip_relocation, monterey:     "8808e96a71f88941a29ade65e6381a20ba4f6fe9e6bf50699d1a7312eb9447c0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b299074f15cb6218c56053c45796c0ecefaa436edbaf2d599ceeba7f1539e2a4"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.26.x"
    git_commit_hash="3acb6b6272f361e25d68aabe6d1c737dfb59a1bc"

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
