class AperturectlAT223 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.23.3.tar.gz"
  sha256 "548dc19c8ab5041288f10b6665f6e43e33154be6faf3f6043955efc5b7aea6a5"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.23-2.23.3-rc.1"
    sha256 cellar: :any_skip_relocation, monterey:     "8a27ffe01db382e4aa28892abc2787c770b0d7f6addd503d533f29979d949c5e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "173b1413bf9878b165e562ef65b22190e229b44e20654f88446acf9048e5e123"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.23.x"
    git_commit_hash="63940cef3ca6a55671b6c56c7a02d0b1dca665a6"

    require "open3"
    if build.head?
      head_branch="stable/v2.23.x"
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
