class Aperturectl < Formula
  desc "CLI for flow control and reliability management for modern web applications"
  homepage "https://www.fluxninja.com"
  url "https://github.com/fluxninja/aperture/archive/refs/tags/v2.34.0.tar.gz"
  sha256 "b0a4ce5ee1364c12d31039246c9840d2bc9a249915d5915035b8b3ed8e9dc6d7"
  license "Apache-2.0"
  head "https://github.com/fluxninja/aperture.git", branch: "main"

  bottle do
    root_url "https://github.com/fluxninja/homebrew-aperture/releases/download/aperturectl-2.34.0"
    sha256 cellar: :any_skip_relocation, monterey:     "929212b36830186014cbf8c994c54891a0bc2cefa539a04ccf880c78a8c21798"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "792beda6b5dd23f6cf42ea7176a4cec938c078b856b19382014c04fd556e44db"
  end

  depends_on "go" => :build

  def install
    git_branch="stable/v2.34.x"
    git_commit_hash="a944906adcf905e66c4ae27f27edc7a76fe57435"

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
