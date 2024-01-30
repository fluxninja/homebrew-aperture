class AperturectlAT234 < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.34.0-rc.2.tar.gz"
  sha256 "3814c62401ebd2599ce6e5e4d89df38638bb5a599534a3143663b5af0a1ec561"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl@2.34-2.34.0-rc.2"
    sha256 cellar: :any_skip_relocation, monterey:     "928bf5d4c6cb3bd45234a694ad22bfb03b5c2877c23b5248c9d3aa28ba7b139a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "028b59ee012c10aaed8d49deeec943c22fe5c4c86630f04776c44cc83aa0768b"
  end

  keg_only :versioned_formula

  depends_on "go" => :build

  def install
    git_branch="stable/v2.34.x"
    git_commit_hash="a944906adcf905e66c4ae27f27edc7a76fe57435"

    require "open3"
    if build.head?
      head_branch="stable/v2.34.x"
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
