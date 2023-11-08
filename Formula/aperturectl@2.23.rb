class AperturectlAT223 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.23.1-rc.1.tar.gz"
  sha256 "770f7eefaefb6a71137251e967ff50b868749952036f3e3abc5e1dea5e9cb73c"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.23-2.23.0"
    sha256 cellar: :any_skip_relocation, monterey:     "61f893c629f4ebc7ed5b86c112f080291167b7ac0cf7452432e974829920047f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "22046f75d13a03d58eb44b523cf5f02f188caef2579a1b05d19223332709b0ce"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.23.x"
    git_commit_hash="87ea2fefc34bdce26bf0ca5a42d74e46efa8facc"

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
