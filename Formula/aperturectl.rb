class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/v2.19.2.tar.gz"
  sha256 "cf39a39fa1c24b0193f28747949dcc44088ce9b86fce8662cb8a9f16dc4f32a2"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.19.1"
    sha256 cellar: :any_skip_relocation, monterey:     "0d0dbe8085b0d5c1e70c7b30d59ca4ba57455670c00e889686a267076865218e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "63e642fa5d225b3997bc2f8c9f0cb5b7543b58e365d40f8fce25717b50bab8a4"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.19.x"
    git_commit_hash="1829c579af924d2474a2557d1cb12cebacd134a3"

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
