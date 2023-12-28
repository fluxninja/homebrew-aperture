class AperturectlAT229 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.29.2-rc.2.tar.gz"
  sha256 "b233e62c746778f2d42656cf92bae38e748414155542ec79044111ff6f6fb25d"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.29-2.29.2-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "a4c9d08ff7e0938a8b420e87de2ce78e481d7f2ec560dacd884af5ac60a722e0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2404ea3e36fc73f8ec580458bd2f21fa70fb09da699fbc127d1abd33afd0bf62"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.29.x"
    git_commit_hash="12c4e481aef515f7401a5a8d9553261e112d59aa"

    require "open3"
    if build.head?
      head_branch="stable/v2.29.x"
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
