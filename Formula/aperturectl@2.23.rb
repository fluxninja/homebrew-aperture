class AperturectlAT223 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.23.2.tar.gz"
  sha256 "4dd0aa93b75821ef1db7614261801350d820d7a9615c57c0a46f0d63760d313b"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.23-2.23.2"
    sha256 cellar: :any_skip_relocation, monterey:     "ccc913cad7a51de6878d1552771ca4280147c48b3843db311a9fb5fc2b4eb4fd"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0a23b2bb8f0cd6629e9dc81b6203a80e1683053271909a7441c6ec3f1432fa9f"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.23.x"
    git_commit_hash="ef6f2361e30fa8b1febb0ca4e93e7af758a015a2"

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
